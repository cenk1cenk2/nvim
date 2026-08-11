# Grafana Kilic Datasources

The datasource inventory behind the `grafana-kilic` server, how a question resolves to a uid, and how the endpoints misbehave. Read this before any query — picking the wrong uid returns a confidently empty answer rather than an error.

## Inventory

Twenty datasources in three families, one per cluster:

| Family | Type | uid pattern | Clusters |
|---|---|---|---|
| Mimir | `prometheus` | `mimir-<cluster>` | core, moon, nailbed, neutrino, overseer, rubik, sun |
| Loki | `loki` | `loki-<cluster>` | core, moon, nailbed, neutrino, overseer, rubik, sun |
| Alertmanager | `alertmanager` | `alertmanager-<cluster>` | moon, nailbed, neutrino, overseer, rubik, sun |

**There is no `alertmanager-core`.** Core carries metrics and logs only.

## One datasource is exactly one cluster

Each datasource holds a single cluster's data: the `cluster` label on `mimir-rubik` has exactly one value, `rubik`. The label is present because dashboards template on it, not because a datasource ever mixes clusters.

Two consequences that decide how every task is shaped:

- **There is no fleet-wide datasource.** A question about "the fleet" is seven queries, and the cost is real. Ask which clusters before sweeping all of them.
- **Filtering by `cluster` inside a query buys nothing.** The uid already decided it. Keep the label only when copying a dashboard query that templates on it.

**Mimir and Loki are not deployed the same way.** Mimir runs per cluster. Loki is a **single instance on rubik** serving every cluster as a tenant, so the seven `loki-*` datasources are seven tenant views of one store. Tenants are named `<cluster>.monitoring.int.kilic.dev` and appear as the `tenant` structured metadata on every log line, which is a useful cross-check that the uid you used is the cluster you meant.

That topology explains two things: Loki-wide limits such as `max_global_streams_per_user` (15000) apply per tenant on shared infrastructure, and a Loki-side incident affects every cluster's logs at once while metrics keep working.

Loki retention is **360h** (15 days). `max_query_lookback` matches it, so a query reaching further back returns nothing rather than erroring.

## Resolving a target to a uid

1. **The user names a cluster** — use it directly. The seven names above are the whole set.
2. **The user names a workload, namespace, or repository** — resolve which clusters run it per `kilic-workload-resolution`, then query each.
3. **The user names nothing** — ask. Do not default to one cluster silently, and do not sweep all seven without saying that is what you are doing.

## The endpoints are flaky, and the failures lie

Verified behaviour, not speculation. Treat these as normal operating conditions:

- **Loki metadata endpoints return 502 often** — `list_loki_label_values`, `query_loki_stats`, and `analyze_loki_labels` all do it intermittently against a datasource that is serving queries fine. **Retry before concluding anything.** `analyze_loki_labels` is the worst offender because it walks every label including `__stream_shard__`; prefer `list_loki_label_names` plus targeted `list_loki_label_values`.
- **`check_datasources_health` flaps.** The same datasource times out on one call and reports OK on the next; the timeout is the Grafana proxy, not the datasource. A health result is never grounds for reporting a datasource down — prove it with an actual query.
- **Empty is not broken.** `loki-core` returns an empty label list because it holds no logs. That is a real answer, and reporting it as an outage is wrong.

When something genuinely does not respond after a retry, say which datasource and which call, and continue with the rest rather than abandoning the sweep.

## Parameter naming is inconsistent

The server does not use one convention, and the error messages are the only reliable guide:

- Query and metadata tools take **`datasourceUid`** — camelCase.
- Alerting tools take **`datasource_uid`** — snake_case, alongside `rule_limit` and `limit_alerts` rather than `limit`.

A wrong parameter name errors with the valid argument list, which is cheap. Guessing a label name does not error, which is not.

## What this stack does not have

- **Grafana-managed alert rules.** `alerting_manage_rules` with `operation: list` returns null. Alerting lives in the Mimir Ruler, deployed from the `monitoring-ruler` workload, and is authored as rule files rather than through the Grafana API.
- **Grafana OnCall.** `list_alert_groups` fails resolving the OnCall URL with a 404 from the settings API. Every OnCall and IRM tool is unavailable; do not reach for them.
