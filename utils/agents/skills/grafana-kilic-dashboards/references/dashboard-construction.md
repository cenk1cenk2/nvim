# Dashboard Construction

How the panels on a kilic dashboard are built and ordered. These are the mechanisms every owning repository follows; the concrete dashboards, their uids, variables and selectors are in the owning repository's `CLAUDE.md` and JSON. The Kubernetes dashboards in monitoring-view (cluster nodes and workloads) are the reference for layout and data-link menus: when in doubt, open one and copy its shape.

## Section order

A dashboard reads top to bottom from "is anything wrong" to "what exactly is there":

1. **`Overview`**: one or two rows of stat pills. The first row answers the health glance (counts up, things in a bad state, recent events such as reboots or OOM kills over 24h); the second carries capacity (absolute totals) then utilization (the worst percentage per resource).
2. **Domain sections** from one vocabulary: `Compute`, `Network`, `Filesystem`, `Storage`. A specific section (`Traffic`, `Peers`, `Backups`, `Jobs`) appears only where no generic one fits.
3. **`Health`**: status charts (exporter up, sync state, reboots) and the issue tables with no section of their own. There is no `Problems` or `Timeline` section.
4. **`Inventory`**: full-width inventory tables, always last, and only when there is one.

Every section starts with a native `row` panel. Within a section: the absolute pair, then its percent pair, then the issue tables that list what is wrong in that section.

**Hosts and other entities stack on shared panels; a section is never repeated per entity.** A multi-select variable on the entity key narrows every panel at once. A per-entity drilldown is its own dashboard, not a repeated row.

## Grid

The grid is 24 columns. Pill rows are their own grid rows: no chart or table shares a `gridPos.y` with pills.

| Panel | Size |
|---|---|
| stat pill | `h: 3`, `w = 24/n` for `n` of 3, 4 or 6; six across at `w: 4` is the default |
| timeseries | `w: 12, h: 10`, two per row as a pair; three status charts at `w: 8` |
| issue table | `w: 12, h: 7`, two per row |
| inventory table | `w: 24, h: 10` |
| bargauge | `w: 8` beside a `w: 16` timeseries, or `w: 12` |

Do not add filler pills to complete a row; a left-aligned partial row is allowed only as the last pill row of its section. Panel types are `row`, `stat`, `timeseries`, `table` and `bargauge`; anything else needs a reason. Variables are `datasource`, `query` and `constant`.

## Stat pills

- **Options**: `colorMode: background`, `graphMode: none`, `textMode: value` (the title names the metric), `reduceOptions.calcs: [lastNotNull]`, every target `instant: true`.
- **Absolute pills** (counts of things, totals, capacity) get unit `short`, `bytes` or the resource's unit and **one flat threshold step, `{color: blue, value: null}`**. Cloning a percent pill carries its 80/90 steps onto a bytes pill and renders it permanently red.
- **Problem-count pills** (things down, unsynced, read-only) get `green` at `null` and `red` at `1`, so zero reads healthy.
- **Percent pills** show the worst entity (`max(...)` over the per-entity percentage), unit `percent` on a 0-100 scale with the query multiplied by 100, `decimals: 1`, steps green, orange 80, red 90; inverted for headroom metrics.
- **A count that can be empty ends `or vector(0)`**, so "none" renders as `0` instead of `No data`. Where a metric only exists once non-zero, fall back with `or 0 * count(up{...} == 1)` instead, so a dead exporter still reads as no data rather than a healthy zero.
- **Several values in one pill** (`Up / Total`) use `orientation: auto` with `wideLayout: true` and one legend per target; `horizontal` stacks them into text-less bars. A related pair (`Request / Limit`, `In / Out`) may share a `w: 4` pill rendered vertically.
- **Pill data links** go to the dashboard that explains the number, carrying the current variables.

## Paired charts

- **Pairs**: an absolute chart (`CPU by Host`, used against capacity) beside its sibling resource, then the percent pair (`CPU Utilization %` beside `Memory Utilization %`). A utilization percentage without its companion resource is incomplete.
- **Legends are tables**: `displayMode: table`, `placement: bottom`, calcs `mean` and `max` (add `lastNotNull` for live signals; keep `max` without `min` for sparse event bars).
- **Legend formats put the entity first**: `{{node}}`, `{{node}} / {{name}}`, `{{node}} used` beside `{{node}} cores`. A stacked series must be identifiable without a click.
- **Percentages use unit `percent` with `min: 0`, `max: 100`**, never `percentunit`.
- **Prefer a friendly identifier over a device name** when another series maps one to the other: `label_replace` the device, then join on the shared labels so the legend reads the name, not the interface.
- **Stacked bars for additive rates and categorical breakdowns; lines for latency, durations and gauges.**

## Tables

- **Instant queries in table format** (`instant: true`, `format: table`); a range query returns a row per scrape timestamp.
- **Several queries merge**: one query per column, each aggregated `max by (<entity>, <labels>)` over the same entity keys, combined with a `merge` transform. Use `joinByField` only for a real join key, and then keep copy `1` of every duplicated label (see `grafana-kilic-dashboards`).
- **One `organize` transform** excludes `Time` and the value columns that only carried labels, renames raw names to headers, and orders columns with `indexByName`: **the entity first**, then status, then descriptive labels, then numbers, then technical identifiers (job, exporter version) last.
- **Colour cells**: status columns use value mappings (`0` Down red, `1` Up green) with `cellOptions: {type: color-background, mode: basic}` and matching thresholds. Percent columns get unit `percent` and the 80/90 thresholds on a colour-background cell; a **gauge cell** (`{type: gauge, mode: basic, valueDisplayMode: text}`) suits a fill level where the bar reads faster than the number.
- **Units per column** through `byName` overrides keyed on the raw field name (`Value #E` for seconds, `Value #G` for bytes).
- **Sort** with `options.sortBy` on the entity header, then the next key, ascending; an issue table may sort by severity instead.
- **The entity cell carries a data-link menu**: dashboard links first, in the dashboard's own link order, each with the row value and `${__url_time_range}`; then the log drilldowns, opening in a new tab. Two or more links render a click menu; do not set `oneClick`.

## Issue tables

An issue table lists only what is wrong, so **empty means healthy**.

- **The filter is the whole query**: every column's query repeats the same `and on (<keys>) (<condition>)`, so a value column shows only the rows in the issue set and a merged row never appears half-filled.
- **Title it as the problem** (`Filesystem Issues`, `Hosts Down`), size `w: 12, h: 7`, and place it at the end of the section whose problem it lists.
- **Validate with a loosened control**: an empty table is indistinguishable from a broken query, so run the query live with the threshold loosened until rows appear (or tightened until a healthy row drops out), then restore it.

## Inventory tables

Full width in `Inventory`, one row per entity, merged from instant queries over info metrics (`*_info`, `*_build_info`, `up`, boot time, capacity). Columns follow the entity-first order above; `up` becomes a mapped Status cell. The entity cell carries the fullest link menu on the dashboard.

## Variables

- **`datasource`**: type `datasource`, query `prometheus`, with a regex limiting it to the uids the dashboard can read (`/^mimir$/` for Kubernetes-only, `/^mimir(-core)?$/` where core is readable); the selected default is the dashboard's natural tenant. Fleet landing pages carry no variables and query `mimir` directly.
- **Entity variable**: type `query`, `label_values(<an info or up metric with the dashboard's exact selector>, <entity label>)`, so the variable lists exactly the entities the panels select; `multi: true`, `includeAll: true`, default All; `refresh: 2` (on time range change) so entities that appear or vanish follow the range.
- **`cluster`** on Kubernetes dashboards is multi-select and defaults to All; every entity-keyed `by` and `on` list carries `cluster`, and tables keep a visible `cluster` column.
- **Every panel query uses the variable** (`node=~"$node"`), so All and a selection narrow every panel alike.

## Dashboard families per host class

A host class that needs its own pages (a hypervisor, a NAS) gets **a copy of the generic host dashboard scoped by its job namespace** (`job=~"<class>/.+"`), while the generic one excludes it (`job!~"(<class>|...)/.+"`). The copy keeps the generic layout and adds class-specific sections.

- **Titles name the family**: `<Family> > Overview`, `<Family> > Disks`.
- **Siblings link to each other** in a fixed order, and every member links back to the hub.
- **A hub dashboard mirrors its targets**: one pill row per family, each pill using the same query as the pill it summarises on the target, and linking there. When a target's pill changes, the hub's mirror changes in the same commit.

## Dashboard links

Native links in the top bar, in this order: the hub or parent first, then siblings in the family, then related service dashboards, then third-party drilldowns (Node Exporter Full), then sibling families, then log links last. Dashboard links carry `keepTime: true` and the variables that exist on the target (`${node:queryparam}`); log links carry `targetBlank: true` and the time in the Explore state instead.

## Log drilldowns

Logs are reached through Explore links, never a log dashboard. Label tiers per `loki-label-model`.

**The recipe** is `/explore?left=<pane state>`, where the pane state is URL-encoded JSON:

```
{"datasource":"<loki uid>","queries":[{"expr":"<logql>","refId":"A"}],"range":{"from":"${__from}","to":"${__to}"}}
```

The JSON punctuation is encoded (`%7B`, `%22`, `%3A`, and `%5C%22` for the quotes inside the expression); the interpolation tokens stay raw and unencoded (`${__data.fields["node"]}`, `${node:regex}`, `${__from}`), so Grafana substitutes them before the browser decodes the rest. Build it with a script that encodes the decoded form, never by hand.

- **Datasource**: the federated `loki` with `cluster=~"${cluster:regex}"` as the first matcher on a dashboard link, `loki-${__data.fields["cluster"]}` on a row link, `loki-core` for core. Never `loki-${cluster}`: a multi-select expands it into an invalid uid.
- **Safe labels**: only indexed stream labels inside `{}`; structured metadata goes after `|`. `namespace`, `pod` and `container` agree exactly between Mimir and Loki, so they are the safe path when a row's `workload_type` is a custom-resource kind Loki does not know.
- **Every selector needs a matcher that cannot match empty**, such as `service_name=~".+"`, because an All variable expands to `.*`.
- **Titles**: `Open <entity> logs` on a cell (`Open node logs`, `Open workload logs`), `<Entity> logs` on a dashboard link. Prefer one `Open workload logs` (indexed `workload_type` plus `| workload=~"<name>(-.*)?"`) over one button per kind.
- **Only where the row has enough context to scope it.** A column that is not a log source (a guest name, an interface) gets no log link.

## Query correctness

- **Throttling is the worst container, never an average**: `max by (...)` over the per-container ratio, said in the title. A summed ratio hides a pinned container among idle ones, at every scope.
- **Available capacity is allocatable minus active requests**, from the `active` request recording rules; the raw requests metric counts completed pods.
- **Summed headroom hides fragmentation**: pair a summed figure with a `min by (node)` companion and say which the panel means.
- **`container_cpu_cfs_*` selectors need `container!=""`**; the pod-level cgroup series reads as a flat 100%.
- **`workload_type` is mixed case in Mimir**: pass the literal value; do not normalise.
- **Range semantics are deliberate**: instant queries for inventory and live status, `$__rate_interval`, `increase(...[$__range])` or `*_over_time(...[$__range])` for activity; titles say which.
