---
name: grafana-kilic-dashboards
description: grafana-kilic-dashboards Author and fix Grafana dashboards in their owning repo - pills, paired charts, tables, issue and inventory tables, variables, drilldown links, section order. Links break silently when a transform renames the field they read. Use on "fix this dashboard", "add a panel". Not for reading metrics, writing alert rules, or editing Grafana directly.
disableModelInvocation: true
argumentHint: '[dashboard or panel] - e.g. ''add a logs button to cluster-workloads'''
references:
  - ./references/dashboard-construction.md
  - ../references/kilic/grafana-kilic-datasources.md
  - ../references/kilic/loki-label-model.md
  - ../references/kilic/kilic-monitoring-ownership.md
  - ../references/kilic/kilic-autoscaling-metrics.md
  - ../references/kilic/kilic-core-tenant.md
scripts:
  - ./scripts/dashboard.py
---

## Grafana Dashboards

Find the owning repository per `kilic-monitoring-ownership`, then **read its `CLAUDE.md` and the dashboards around the one you are changing**: they hold the inventory, uids, variables and selectors, and this skill holds only the mechanisms. monitoring-view's `README.md` is the link and drilldown spec for every dashboard wherever it lives. Correct a `CLAUDE.md` when you prove it wrong.

How pills, charts, tables, variables, families, link order and log drilldowns are built, and the section order: `dashboard-construction`. Datasource model: `grafana-kilic-datasources`. Loki label tiers behind every log link: `loki-label-model`. Core tenant selectors: `kilic-core-tenant`. Autoscaling metric families: `kilic-autoscaling-metrics`.

**Grafana is GitOps-owned.** Never edit a dashboard through the Grafana API or UI; reads are how you verify. Adding a dashboard is three edits: the JSON, its `GrafanaDashboard` CR naming a folder, and a `configMapGenerator` entry with `disableNameSuffixHash: true`.

## Datasources

**Dashboards query the federated datasources.** Kubernetes dashboards read `mimir` and `loki` scoped by a multi-select `cluster`; core dashboards read `mimir-core` and `loki-core`. The per-tenant uids stay for Explore, live tail and the Alerting view.

- **Federated `mimir` puts `__tenant_id__` on every raw series.** Never put a bare `or`, `and`, `unless` or other unmatched binary operator between a raw series and an aggregate; match with `on (...)` including `cluster`, and aggregate `__tenant_id__` away.
- **A link carries `var-datasource=${datasource}` only when the target's variable admits more than one option.** Everywhere else omit it.
- **Drilldowns read the row's own `cluster`**: `var-cluster=${__data.fields["cluster"]}` into a metrics dashboard, `loki-${__data.fields["cluster"]}` for logs; dashboard-level links pass `${cluster:queryparam}`.

## ABSOLUTE: Establish What the Frame Contains Before Touching a Link

**Rewriting link interpolation syntax does not fix a broken drilldown** when the real cause is that the referenced field does not exist in the frame after its transforms. **Read the panel's transforms and work out the resulting field names first**, then decide the link. `indexByName`, `renameByName` and `displayName` are not evidence a field exists; keyed on a name no transform produced, all three fail silently.

## Link Interpolation

| Need | Use | Never |
|---|---|---|
| A table cell's value | `${__data.fields["<raw label name>"]}` | `${__data.fields[0]}`: a join or hidden field shifts indexes |
| A series label on a value field's own link | `${__field.labels.cluster}` | `${__data.fields[7].labels.cluster}`: unimplemented, resolves empty |
| Time range on a data link | `${__url_time_range}` | `keepTime`: no effect on data links |
| Time range on a native dashboard link | `keepTime: true` | carrying both |
| A multi-select variable in a URL | `?${namespace:queryparam}` | `?var-namespace=${namespace}` |

Bracket interpolation resolves against the field's **raw `field.name`**, so it survives a `displayName` override and an `organize` rename. `:queryparam` emits the source variable's name, so it cannot be used where the target's parameter is named differently; those stay single-value and fail visibly on multi-select, which beats the plain form failing silently.

**`joinByField` numbers every duplicate column** (`cluster 1` to `cluster N`, no bare `cluster`). Keep copy `1`, exclude `2..N`, and key `renameByName` and `indexByName` on `cluster 1`; excluding every copy deletes the only field carrying the raw name and silently breaks every link reading it. Prefer `merge`.

## Process

1. **Find the owner and read its `CLAUDE.md`** and the neighbouring dashboards; copy the shape of the closest existing panel rather than inventing one.
2. **Place the panel** in its section per the order in `dashboard-construction`, at its position in the `panels` list, then run `dashboard.py reflow`.
3. **Build it** to the pill, chart or table recipe, using the dashboard's existing selectors and variable.
4. **Wire links**: the dashboard link bar order, the entity-cell menu (dashboard links, then log drilldowns), the row value and time range on every data link.
5. **Verify** per the section below, and report the panel or query that changed, never the whole JSON.

## JSON Hygiene

- **Never change a dashboard `uid`.** It is the routing identity other dashboards and alerts link to.
- Dashboard JSON serializes at `indent=2`. **Some files escape non-ASCII as `\uXXXX` and some do not**; detect per file by round-tripping before rewriting, or the diff churns. A pure string substitution on the raw text avoids the question.
- **Prefer scripted edits that assert the old value** over hand-editing; the same URL commonly repeats across panels. A link-title rename is `dashboard.py retitle`.
- Most rate windows use `$__rate_interval`; `increase()` over `$__range` and deliberate smoothing windows are intentional.

## Verification

1. **`kustomize build`** of the owning repository's deploy directory must pass before the commit; invalid JSON breaks the deploy, not one panel.
2. **`dashboard.py reflow --renumber`, then `dashboard.py lint`** on every changed file.
3. **Run every changed query live**: `dashboard.py queries` prints each target with variables substituted, for `query_prometheus` on the dashboard's datasource; `query_loki_logs` proves a log link's selector returns lines. An empty result needs a negative control before it counts.
4. **Prove an empty issue table works** with a loosened control: loosen its threshold in the live query until rows appear, then restore it.
5. **Count links before and after a rework.** Dashboard links, data links and override links per file must match unless a panel was removed, and then its links moved to the panel replacing it.
6. **Snapshot-diff the panels you did not mean to touch**: compare each untouched panel's JSON before and after (by id or title), and explain any difference.
7. **Check a link target exists** with `search_dashboards` before "fixing" its uid; a target absent from one repository may be owned by another.
8. **Distinguish a wrong selector from a collection gap.** A corrected selector does not restore data that was never collected; say which you found.
9. **Rendering cannot be verified locally.** A change is unproven until merged and synced; say so.

**A rework across several dashboards is spec-driven.** Write one spec file holding the layout, unit, link and verification rules, dispatch one agent per dashboard writing only its own files and reporting its verified query count and lint result, and review every diff against the spec before committing.

## Scripts

`scripts/dashboard.py` is executed by its path, resolved from this skill's `bundleDir`; its shebang syncs its own uv project, so it is never run through `python3`. A first `dashboard.py --help` in the foreground confirms it launches.

| Subcommand | Does |
|---|---|
| `lint PATH...` | Reports layout and convention defects, one line each, then a `RESULT:` line. |
| `queries PATH... [--set VAR=VALUE]` | Prints each target as JSON (`file`, `panel`, `title`, `refId`, `expr`), unset variables as `.*`, `$__rate_interval` as `5m`, `$__interval` as `1m`, `$__range` as `1h`; `datasource` is never substituted. |
| `reflow PATH... [--renumber]` | Re-stacks `gridPos` from list order, keeping each panel's `w` and `h`; `--renumber` also renumbers ids. |
| `retitle PATH... --map OLD=NEW` | Renames dashboard-link and data-link titles exactly; panel titles are untouched; writes nothing when any mapping is unmatched. |

Exit codes: 0 clean or written, 1 findings or an unmatched mapping, 2 usage error, 3 a file is not dashboard JSON. Files are rewritten at `indent=2` keeping each file's own non-ASCII escaping.

## Key Principles

1. **Inspect the frame before the link.** Transforms decide field names; syntax changes against an unknown frame fail repeatedly and silently.
2. **Silent emptiness is the failure mode throughout**: a wrong selector, a hidden frame, a shifted index and a case-sensitive matcher all render as "no data".
3. **The owner's `CLAUDE.md` holds the specifics; this skill holds the mechanism.**
4. **Stack entities; never repeat a section per entity.**
5. **Two links, not `oneClick`; `merge` before `joinByField`.**
6. **Never change a uid.**
7. **Say what is unproven.** Nothing renders until it syncs.

## Examples

**User says:** "the namespace logs button on cluster-workloads returns nothing"

1. Find the owner and read its `CLAUDE.md` and monitoring-view's `README.md`.
2. Read the panel's transforms and establish the actual field names; do not touch the URL yet.
3. Decode the link's LogQL and check each label against the stream-label tier.
4. Prove the corrected selector returns lines with `query_loki_logs` before editing.
5. Rewrite the URL with a script, count links before and after, run `kustomize build`, and state that rendering is unproven until sync.

**Result:** A fix grounded in what the frame and Loki actually contain, rather than another syntax swap.
