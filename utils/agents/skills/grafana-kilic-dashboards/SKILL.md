---
name: grafana-kilic-dashboards
description: grafana-kilic-dashboards Author and fix Grafana dashboards in monitoring-view or their owning repo - panel layout, table transforms, drilldown links, thresholds. Links break silently when a transform renames the field they read, so the frame is checked first. Use on "fix this dashboard", "add a panel". Not for reading metrics, writing alert rules, or editing Grafana directly.
disableModelInvocation: true
argumentHint: '[dashboard or panel] - e.g. ''add a logs button to cluster-workloads'''
references:
  - ../references/kilic/grafana-kilic-datasources.md
  - ../references/kilic/loki-label-model.md
  - ../references/kilic/kilic-monitoring-ownership.md
  - ../references/kilic/kilic-autoscaling-metrics.md
scripts:
  - ./scripts/dashboard.py
---

## Grafana Dashboards

Fleet and cross-cutting dashboards live in `cluster/workloads/monitoring-view`, rubik only, namespace `monitoring-backbone`; a dashboard for one workload or system component lives in that repository or chart. Which owner, the folder tree and the workload-side layout: `kilic-monitoring-ownership`. Datasource uids and the per-cluster model: `grafana-kilic-datasources`. The Loki label model behind every log drilldown is in `loki-label-model` — indexed stream label versus structured metadata decides whether a button returns lines or nothing.

**monitoring-view's `README.md` is the spec for links and drilldowns, and its `CLAUDE.md` is the operational context, for every dashboard wherever it lives.** Read both before touching anything; a workload repository's own `CLAUDE.md` adds only what is specific to its dashboards. They are load-bearing; correct them when you prove them wrong.

## Datasources

**Dashboards query the federated datasources, not the per-cluster ones.** `mimir` is the Grafana default and spans every cluster except `core`; `mimir-core` is the core tenant's datasource and the only dashboard route to core data. The per-cluster `mimir-<cluster>` and `loki-<cluster>` uids stay provisioned for Explore, the Alerting view, Node Exporter Full and Loki live tail. The full spec is in the repo's `CLAUDE.md`:

| Folder | `datasource` variable | `cluster` variable |
|---|---|---|
| Fleet landing pages: `kubernetes/kubernetes`, `kubernetes/cilium`, `kubernetes/gateway/gateway`, `kubernetes/backups/backups`, `kubernetes/databases/databases`, `kubernetes/databases/postgresql`, `backbone/backbone`, `operations/operations`, `fleet/fleet` | none; queries uid `mimir` directly | none; every row broken out by `cluster` |
| `metrics/*` | regex `/^mimir(-core)?$/`, selected `mimir` | multi-select, defaults to All |
| `core/*` | regex `/^mimir(-core)?$/`, selected `mimir-core` | none |
| Every other category | regex `/^mimir$/`, selected `mimir` | multi-select, defaults to All |

- **Every `cluster` variable is multi-select and defaults to All**, even where the data lives on one cluster today, so one panel holds rows from several clusters. Every entity-keyed `by` and `on` list carries `cluster`, timeseries quantiles aggregate `by (le, cluster)`, and tables keep a visible `cluster` column. Drilldowns read the row's own value: `var-cluster=${__data.fields["cluster"]}` for a metrics link, `loki-${__data.fields["cluster"]}` for a log link; dashboard-level links pass `${cluster:queryparam}`.
- **A link carries `var-datasource=${datasource}` only when the target's variable admits more than one option** (`metrics/*`, `core/*`). Everywhere else omit it.
- **Federated `mimir` puts `__tenant_id__` on every series.** Never put a bare `or`, `and`, `unless` or other unmatched binary operator between a raw series and an aggregate: the tenant label stops the sides matching and rows vanish or duplicate. Match with `on (...)` and include `cluster` in the list; give every new query a `cluster` matcher and aggregate `__tenant_id__` away.
- **The federated `loki` spans every cluster**, so the `cluster` matcher in its selector is what scopes the query. Dashboard-level log buttons use `loki` with `cluster=~"${cluster:regex}"`.

## How a Dashboard Reaches Grafana

In monitoring-view the directories nest like the Grafana folder tree:

```
.deploy/rubik/dashboards/<path>/<name>.json        the dashboard
.deploy/rubik/dashboards/<path>/<name>.yaml        GrafanaDashboard CR
.deploy/rubik/dashboards/<path>/kustomization.yaml configMapGenerator
.deploy/rubik/folders/<path>/                      GrafanaFolder CR
```

`<path>` is a category or a subfolder of one (`kubernetes/gateway`). The JSON is mounted as a ConfigMap and referenced by a `GrafanaDashboard` CR (`grafana.integreatly.org/v1beta1`) via `configMapRef`, with `instanceSelector` matching `monitoring.kilic.dev/grafana: default`. Each level adds its own `namePrefix`, so CR names read as the path (`kubernetes-gateway-folder`) and `folderRef` names that final CR name. A monitoring-view folder's uid is `folder-<path>` and never changes. A workload-owned dashboard follows `kilic-monitoring-ownership` instead: its own `dashboards/` directory, instance label `monitoring.kilic.dev/instance`, its own folder.

Adding a dashboard means three edits, not one: the JSON, its CR, and a `configMapGenerator` entry with `disableNameSuffixHash: true`.

**Grafana is GitOps-owned.** Never edit a dashboard through the Grafana API or UI, and avoid the write-capable MCP tools entirely. Reads are how you verify.

## ABSOLUTE — Establish What the Frame Contains Before Touching a Link

**Rewriting link interpolation syntax does not fix a broken drilldown.** Swapping between forms — raw brackets, `.labels` — fails every time when the real cause is that the referenced field does not exist in the frame after its transforms. Changing syntax against a frame you have not inspected repeats that failure.

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
| `table` | `w: 24, h: 10` | Full width; inventory tables close a dashboard or section |
| issue `table` | `w: 12, h: 7` | Two per row, closing the section whose problems they list |
| `row` | `h: 1` | Collapsible grouping |
| `bargauge` | `w: 8` beside a `w: 16` `timeseries`, or `w: 12` | Current distribution next to its history; top-N |

Panel types in use are `stat`, `timeseries`, `table`, `bargauge` and `row`, plus three narrow exceptions: `status-history` on `core/rancher` and `kubernetes/gateway/blackbox-probe`, one `piechart` on `kubernetes/gateway/envoy-gateway-traffic`, and one `text` markdown note on `backbone/tenants`. No dashboard uses the `statusmap` plugin. Variables are `query`, `datasource` and `constant`; none is `custom`.

**When inserting a panel, put it at its place in the `panels` list and run `dashboard.py reflow`**, which re-stacks every `gridPos` from list order, then `dashboard.py lint` for overlaps and duplicate ids.

**A stat showing several values in one pill uses `orientation: auto` with `wideLayout: true`.** `horizontal` stacks the values in a column, so three values in an `h: 3` pill each get a third of the height and render as bare colour bars with no text. The stat panel does not forward `minVizHeight` or `minVizWidth`, so those settings do nothing. `auto` lays the values side by side, with the name on the left and the value on the right.

## Stacking Hosts

**Hosts, nodes, routers and guests stack on shared panels; a section is never repeated per entity.** A multi-select variable on the entity's key (`node`, `pbs`, `router`, `guest`) defaulting to All narrows every panel at once.

- **Every chart carries the entity in its legend** — `{{node}}`, `{{node}} / {{name}}`, `{{router}} {{interface}}` — and every table carries it as its first column, so a stacked series or row is identifiable without a click.
- **Lay a dashboard out the way the Kubernetes dashboards are** (`kubernetes/cluster-nodes`, `kubernetes/cluster-workloads`): Overview with one or two rows of six pills (counts and utilization, then capacity and headroom); then one row per concern holding an absolute pair (`CPU by Node`, `Memory by Node`) followed by its `%` pair (`CPU Utilization %`, `Memory Utilization %`); the issue tables that list what is wrong close their section; inventory tables come last.
- **Pair every utilization percentage across resources** — a CPU % panel without its memory % companion is incomplete.
- **A per-entity drilldown is its own dashboard** (`Proxmox > Guests` beside `Proxmox > Overview`), not a repeated row.
- **Prefer a friendly identifier over a device name** when another series maps one to the other: join on the shared label (`label_replace` the device first) so the legend reads `WAN`, not `vtnet0`.

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
- **Never use `loki-${cluster}` as a datasource uid.** On a multi-select `cluster` it expands to a set or `.*` and yields an invalid uid — use row-level cluster recovery or the federated `loki`.
- **Add log buttons only where the row has enough context to scope them.** Namespace-only and node-only links are acceptable fallbacks; a service dashboard should scope further.

## JSON Hygiene

- **Never change a dashboard `uid`.** It is the routing identity other dashboards link to.
- Dashboard JSON serializes at `indent=2`. **Some files escape non-ASCII as `\uXXXX` and some do not** — detect per file by round-tripping before rewriting, or the diff churns hundreds of unrelated lines. Where an edit is a pure string substitution, rewriting the raw file text avoids the question entirely.
- **Prefer scripted edits that assert the old value** over hand-editing. The files are large and the same URL commonly repeats across four panels. A link-title rename is `dashboard.py retitle`, which refuses a mapping that matches nothing.
- **Report the panel change** — the JSON is large, so show the panel or query that moved, never the whole file.
- Most rate windows use `$__rate_interval`. `increase()` over `$__range` or `$__interval`, and the deliberate `[30m]` and `[10m]` smoothing windows, are intentional.

## Verification

1. **`kustomize build .deploy/<cluster>`** in the owning repository is what CI runs and must pass — invalid JSON breaks the deploy, not one panel.
2. **Run `dashboard.py lint`** on every changed file; it exits 1 on overlaps, duplicate ids, range-mode tables, repeated rows, percent thresholds on absolute stats and multi-select variables passed without `:queryparam`.
3. **Confirm the query returns rows** against the live instance before shipping a panel or button: `query_prometheus` for a metric and its joins, `query_loki_logs` to prove a selector returns lines. `dashboard.py queries` prints every target's expression with variables substituted, one JSON line each, for that check; an empty result needs a negative control before it counts.
4. **Check a link target exists** with `search_dashboards` before "fixing" its uid. Workload repositories and charts own dashboards too, so a target absent from monitoring-view is not automatically dangling.
5. **Rendering cannot be verified locally.** Dashboards reach the instance only through GitOps, so a change is unproven until merged and synced. Say that rather than implying a fix is confirmed.
6. **Distinguish a wrong selector from a collection gap.** A corrected selector does not restore data that was never collected — say which you found. For VPA, resize and KEDA panels, a lazily created series is a third case, and which families exist at all is in `kilic-autoscaling-metrics`.

## Scripts

`scripts/dashboard.py` is executed by its path, resolved from this skill's `bundleDir`; its shebang syncs its own uv project, so it is never run through `python3`. A first `dashboard.py --help` in the foreground confirms it launches.

| Subcommand | Does |
|---|---|
| `lint PATH...` | Reports layout and convention defects, one line each, then a `RESULT:` line. |
| `queries PATH... [--set VAR=VALUE]` | Prints each target as JSON (`file`, `panel`, `title`, `refId`, `expr`), unset variables as `.*`, `$__rate_interval` as `5m`, `$__range` as `1h`. |
| `reflow PATH... [--renumber]` | Re-stacks `gridPos` from list order, keeping each panel's `w` and `h`; `--renumber` also renumbers ids. |
| `retitle PATH... --map OLD=NEW` | Renames dashboard-link and data-link titles exactly; panel titles are untouched; writes nothing when any mapping is unmatched. |

Exit codes: 0 clean or written, 1 findings or an unmatched mapping, 2 usage error, 3 a file is not dashboard JSON. Files are rewritten at `indent=2` keeping each file's own non-ASCII escaping.

## Key Principles

1. **Inspect the frame before the link.** Transforms decide field names; syntax changes against an unknown frame fail repeatedly and silently.
2. **Silent emptiness is the failure mode throughout** — a wrong selector, a hidden frame, a shifted index and a case-sensitive matcher all render as "no data" rather than an error.
3. **Two links, not `oneClick`.**
4. **`merge` by default, `joinByField` only for a real join key** — and then keep copy `1`.
5. **Never change a uid.**
6. **Stack hosts; never repeat a section per host.**
7. **Say what is unproven.** Nothing renders until it syncs.

## Examples

**User says:** "the namespace logs button on cluster-workloads returns nothing"

1. Read `README.md` and `CLAUDE.md` first.
2. Read the panel's transforms and establish the actual field names — do not touch the URL yet.
3. Decode the link's LogQL and check each label against the stream-label list.
4. Prove the corrected selector returns lines with `query_loki_logs` before editing.
5. Rewrite the URL string, run `kustomize build .deploy/rubik`, and state that rendering is unproven until sync.

**Result:** A fix grounded in what the frame and Loki actually contain, rather than the seventh syntax swap.
