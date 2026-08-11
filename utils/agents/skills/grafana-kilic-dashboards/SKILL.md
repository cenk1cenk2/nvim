---
name: grafana-kilic-dashboards
description: grafana-kilic-dashboards Author and fix Grafana dashboards in the monitoring-view repo - panel layout, table transforms, drilldown links, thresholds. Links break silently when a transform renames the field they read, so the frame is checked before the link. Use on "fix this dashboard", "add a panel". Not for reading metrics, writing alert rules, or editing Grafana directly.
disableModelInvocation: true
argumentHint: '[dashboard or panel] - e.g. ''add a logs button to cluster-workloads'''
references:
  - ../references/grafana-kilic-datasources.md
  - ../references/loki-label-model.md
  - ../references/output-diff.md
---

## Grafana Dashboards

Target repo: `cluster/workloads/monitoring-view`, rubik only, namespace `monitoring`. Datasource uids and the per-cluster model: `grafana-kilic-datasources`. The Loki label model behind every log drilldown is in `loki-label-model` — indexed stream label versus structured metadata decides whether a button returns lines or nothing.

**`README.md` in that repo is the spec for links and drilldowns, and `CLAUDE.md` is the operational context.** Read both before touching anything. They are load-bearing, they were wrong for months, and correcting them when you prove them wrong is part of the job.

## How a Dashboard Reaches Grafana

```
.deploy/rubik/dashboards/<category>/<name>.json     the dashboard
.deploy/rubik/dashboards/<category>/<name>.yaml     GrafanaDashboard CR
.deploy/rubik/dashboards/<category>/kustomization.yaml   configMapGenerator
.deploy/rubik/folders/<category>/                   GrafanaFolder CR
```

The JSON is mounted as a ConfigMap and referenced by a `GrafanaDashboard` CR (`grafana.integreatly.org/v1beta1`) via `configMapRef`, with `folderRef: <category>-folder` and `instanceSelector` matching `monitoring.kilic.dev/grafana: default`. Categories carry a kustomize `namePrefix`, so a CR named `folder` becomes `kubernetes-folder`.

Adding a dashboard means three edits, not one: the JSON, its CR, and a `configMapGenerator` entry with `disableNameSuffixHash: true`.

**Grafana is GitOps-owned.** Never edit a dashboard through the Grafana API or UI, and avoid the write-capable MCP tools entirely. Reads are how you verify; writes would be overwritten and would hide the source of truth.

## ABSOLUTE — Establish What the Frame Contains Before Touching a Link

**Six merged commits each rewrote link interpolation syntax to fix broken drilldowns, and each failed.** They swapped between forms — raw brackets, then `.labels`, then back — while the real cause was that the referenced field did not exist in the frame after its transforms. Changing syntax against a frame you have not inspected is how that happens six times.

So: **read the panel's transforms and work out the resulting field names first.** Only then decide the link.

`indexByName`, `renameByName`, and `displayName` are **not evidence a field exists.** On the broken panels all three were keyed on names no transform produced, and all failed silently. `indexByName` is also not evidence of a field's real index.

## Link Interpolation

| Need | Use | Never |
|---|---|---|
| A table cell's value | `${__data.fields["<raw label name>"]}` | `${__data.fields[0]}` — a join or hidden field shifts indexes |
| A series label on a value field's own link | `${__field.labels.cluster}` | `${__data.fields[7].labels.cluster}` — documented but unimplemented, resolves empty |
| Time range on a panel or field data link | `${__url_time_range}` | `keepTime` — no effect on data links |
| Time range on a native dashboard link | `keepTime: true` | carrying both |
| A multi-select variable in a URL | `?${namespace:queryparam}` | `?var-namespace=${namespace}` |

Bracket interpolation resolves against the field's **raw `field.name`**, so it survives a `displayName` override and an `organize` rename. Write the raw label name, not the human header.

`:queryparam` emits the **source** variable's name, so it cannot be used where the target's parameter is named differently (`var-workload=${target_name}`). Those stay single-value-correct and fail visibly on multi-select — which is better than the plain form, which fails silently: with one value selected it looks right, and with two Grafana emits `var-namespace={a,b}`, which the target matches literally against nothing.

**Two links on a field render a click menu**, which is the wanted behaviour — give namespace and node cells both a logs and a metrics link. Do not set `oneClick`; it defeats the menu.

## Tables

- **Several queries in one table panel need `merge` or `joinByField`.** Grafana renders one frame per panel and hides the rest behind a result-set picker, so a six-query fleet table silently shows one cluster. Prefer `merge` unless you genuinely need a join key.
- **`joinByField` numbers every duplicate column.** With N queries carrying the same labels you get `cluster 1` through `cluster N` and **no bare `cluster`**. Keep copy `1`, exclude `2..N`, give copy `1` its header via `renameByName` keyed on `cluster 1`, and key `indexByName` on `cluster 1`. Excluding every copy deletes the only field carrying the raw name and silently breaks every link reading it.
- **Tables need `instant: true`.** A `format: table` target left as a range query returns a row per scrape timestamp instead of one per series.

## Layout and Sizing

The grid is 24 columns wide. Established widths, in descending use: `12` (half), `4` (six across), `24` (full), `6` (quarter), `8` (thirds).

| Panel | Typical size | Notes |
|---|---|---|
| `stat` pill row | `w: 4, h: 3` | Six across is the standard KPI row |
| `timeseries` | `w: 12, h: 10` | Two per row; `h: 9` and `h: 8` also in use |
| `table` | `w: 24, h: 10` | Full width |
| `row` | `h: 1` | Collapsible grouping |
| `bargauge` | `w: 12` | Top-N distributions |

Panel types in use are `stat`, `timeseries`, `table`, `bargauge` and `row`. Variables are `query`, `datasource`, `custom` and `constant`.

**When inserting a panel, shift the `y` of every panel at or below the insertion point**, then check for `gridPos` overlaps and duplicate panel ids.

## Thresholds

**An absolute-value stat gets one flat threshold step, with `value: null`.** Cloning a percent panel carries its 80/90 steps onto a bytes panel, and with `colorMode: background` every value above the step renders critical — a memory pill shipped permanently red this way. For headroom metrics the polarity is inverted as well, so percent steps are wrong twice over.

## Query Correctness

These are dashboard-specific and each was measured, not assumed:

- **Throttling is always the worst container, never an average.** Use `max by (...)` over the per-container ratio at every scope, and say so in the panel title. `sum(throttled)/sum(periods)` is a weighted average that hides a pinned container among idle ones — namespace `monitoring` reads 0.68% summed against 17.0% as the worst container. The dilution applies at container scope too, across replicas.
- **Available capacity is allocatable minus ACTIVE requests.** Use `cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests` and its `pod_memory` variant. The raw metric counts Succeeded and Failed pods, so completed Job pods are charged against headroom and the error grows with retained Job history. Do not join to `kube_pod_info` for a node label — the requests metric already carries one.
- **Summed headroom hides fragmentation.** Pair a summed figure with a `min by (node)` companion and say which the panel means: 25.9 cores free fleet-wide while no single node can take more than 4.2 is a scheduling failure the sum conceals.
- **`container_cpu_cfs_*` selectors need `container!=""`.** The pod-level cgroup series has no `container` label and yields a flat ratio of 1, rendering as 100% throttled. Only the CFS *period* counters are collected, so ratios must come from periods.
- **`workload_type` from `namespace_workload_pod:kube_pod_owner:relabel` is mixed case** — lowercase for built-in kinds, PascalCase for CRD-owned pods (`Cluster`, `RenovateJob`, `CronJob`), plus `barepod` and `staticpod`. Pass the literal value; do not normalise.

## Log Drilldowns

Label tiers and the `(?i)` rule are in `loki-label-model`; these are the dashboard-side rules on top of it.

- **A row whose kind is a custom resource cannot drill down on `workload_type`.** Mimir resolves CRD owners (`Cluster` for CloudNativePG, `RenovateJob`, `HelmChart`, plus `staticpod`); Loki collapses all of them to `barepod`. A link built from such a row selects nothing, silently, and `(?i)` does not help because the value is genuinely absent. **Scope those on `namespace` plus the `pod` or `workload` field instead** — `namespace`, `pod` and `container` agree exactly across both sides, including for these rows.
- **Prefer one `Open workload logs` button** over separate deployment, statefulset, daemonset and job buttons. Select the kind with the indexed `workload_type` and filter the name with the `workload` structured-metadata field. A trailing `(-.*)?` keeps generated Job names matching for CronJob-like workloads.
- **Every stream selector needs at least one matcher that cannot match empty**, such as `service_name=~".+"`. Dashboard all-values expand to `.*`, and a selector made only of empty-compatible matchers is rejected.
- **Preserve the time range** with `range.from=${__from}` and `range.to=${__to}` in the encoded Explore state.
- **`loki-${cluster}` as a datasource uid is only safe** where the `cluster` variable is `multi: false` and `includeAll: false`. Elsewhere it expands to a set or `.*` and yields an invalid uid — use row-level cluster recovery there.
- **Add log buttons only where the row has enough context to scope them.** Namespace-only and node-only links are acceptable fallbacks; a service dashboard should scope further.

## JSON Hygiene

- **Never change a dashboard `uid`.** It is the routing identity other dashboards link to.
- Dashboard JSON serializes at `indent=2`. **Some files escape non-ASCII as `\uXXXX` and some do not** — detect per file by round-tripping before rewriting, or the diff churns hundreds of unrelated lines. Where an edit is a pure string substitution, rewriting the raw file text avoids the question entirely.
- **Prefer scripted edits that assert the old value** over hand-editing. The files are large and the same URL commonly repeats across four panels.
- Most rate windows use `$__rate_interval`. `increase()` over `$__range` or `$__interval`, and the deliberate `[30m]` and `[10m]` smoothing windows, are intentional.

## Verification

1. **`kustomize build .deploy/rubik`** is what CI runs and must pass — invalid JSON breaks the deploy, not one panel.
2. **Confirm the query returns rows** against the live instance before shipping a panel or button: `query_prometheus` for a metric and its joins, `query_loki_logs` to prove a selector returns lines.
3. **Check a link target exists** with `search_dashboards` before "fixing" its uid. Several dashboards on the instance are managed elsewhere, so a target absent from this repo is not automatically dangling.
4. **Rendering cannot be verified locally.** Dashboards reach the instance only through GitOps, so a change is unproven until merged and synced. Say that rather than implying a fix is confirmed.
5. **Distinguish a wrong selector from a collection gap.** A corrected selector does not restore data that was never collected — say which you found.

## Key Principles

1. **Inspect the frame before the link.** Transforms decide field names; syntax changes against an unknown frame fail repeatedly and silently.
2. **Silent emptiness is the failure mode throughout** — a wrong selector, a hidden frame, a shifted index and a case-sensitive matcher all render as "no data" rather than an error.
3. **Two links, not `oneClick`.**
4. **`merge` by default, `joinByField` only for a real join key** — and then keep copy `1`.
5. **Never change a uid.**
6. **Say what is unproven.** Nothing renders until it syncs.

## Examples

**User says:** "the namespace logs button on cluster-workloads returns nothing"

1. Read `README.md` and `CLAUDE.md` first.
2. Read the panel's transforms and establish the actual field names — do not touch the URL yet.
3. Decode the link's LogQL and check each label against the stream-label list.
4. Prove the corrected selector returns lines with `query_loki_logs` before editing.
5. Rewrite the URL string, run `kustomize build .deploy/rubik`, and state that rendering is unproven until sync.

**Result:** A fix grounded in what the frame and Loki actually contain, rather than the seventh syntax swap.
