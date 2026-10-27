# Grafana Kilic Datasources

The datasource inventory behind the `grafana-kilic` server, how a question resolves to a uid, and how the endpoints misbehave. Read this before any query — picking the wrong uid returns a confidently empty answer rather than an error.

## Inventory

Twenty-three datasources: two federated across the fleet, and three families with one per cluster. All are provisioned from `cluster/workloads/monitoring-backbone` at `.deploy/rubik/datasources/`:

| Family | Type | uid | Covers |
|---|---|---|---|
| Mimir, federated | `prometheus` | `mimir` — the Grafana default | moon, nailbed, neutrino, overseer, rubik, sun |
| Loki, federated | `loki` | `loki` | moon, nailbed, neutrino, overseer, rubik, sun |
| Mimir | `prometheus` | `mimir-<cluster>` | core, moon, nailbed, neutrino, overseer, rubik, sun |
| Loki | `loki` | `loki-<cluster>` | core, moon, nailbed, neutrino, overseer, rubik, sun |
| Alertmanager | `alertmanager` | `alertmanager-<cluster>` | core, moon, nailbed, neutrino, overseer, rubik, sun |

**`core` is not a cluster** — it is the standalone host estate (hypervisors, routers, NAS, GitLab, Rancher and the other ansible-managed servers). **The federated uids exclude it**: core data is reachable only through `mimir-core`, `loki-core` and `alertmanager-core`. Its label model and query shapes: `kilic-core-tenant`.

## Federated and per-cluster datasources

The federated `mimir` and `loki` query all six Kubernetes tenants at once; a per-cluster uid holds exactly one tenant, so the `cluster` label on `mimir-rubik` has the single value `rubik`.

The consequences that decide how every task is shaped:

- **A fleet question is one query on `mimir` or `loki`**, broken out `by (cluster)` — not six. It still costs the sum over every tenant, roughly 3–3.7x a single cluster, so say so before running it and scope to the clusters the question names.
- **On a federated uid the `cluster` matcher is what scopes the query.** Leave it out and you read every tenant. Only on a per-cluster uid is it redundant, because the uid already decided it.
- **One cluster on `mimir` costs about the same as its per-cluster uid.** Federation visits every tenant, but the others return nothing after an index lookup; only latency grows slightly.
- **Federated `mimir` puts `__tenant_id__` on every raw series**, and aggregation drops it. A binary operator between a raw series and an aggregate with no `on (...)` matches nothing, and a bare `or` returns both sides — totals come out exactly doubled. Match with `on (...)` and include `cluster` in it; aggregate `__tenant_id__` away with `by (...)`.
- **The per-cluster uids stay provisioned** for what federation cannot do: Loki live tail rejects more than one tenant, the ruler API rejects federated requests so rule state is read per tenant, and Explore and the Grafana Alerting view use them. A per-cluster sweep is optional, not the default — keep it for deep single-cluster work such as rightsizing.

Dashboard conventions — which folders carry a `datasource` variable, the multi-select `cluster` defaulting to All, and how links pass both — are specified in the `monitoring-view` repository's `CLAUDE.md`, and for the Core and Infrastructure folders in `monitoring-core`'s, and summarised in `grafana-kilic-dashboards`.

**Every datasource is a tenant view, not a backend.** Mimir and Loki are each a **single multi-tenant instance on rubik**, in namespace `monitoring-backbone`; every other cluster runs only collectors — `opentelemetry-collector`, `grafana-alloy`, `blackbox-exporter` — that ship to them. So the sixteen Mimir and Loki datasources, federated ones included, are tenant views of two stores, not sixteen deployments.

Tenants are named `<cluster>.monitoring.int.kilic.dev`. On logs the tenant appears as `tenant` structured metadata on every line, which cross-checks that the uid you used is the cluster you meant.

Two consequences worth holding: per-tenant limits such as Loki's `max_global_streams_per_user` (15000) are enforced on shared infrastructure, so one noisy tenant is a neighbour problem; and an incident in either store affects **every** cluster's data at once, which is the opposite of what per-cluster datasource names suggest. Rubik being down is a fleet-wide observability outage, not a rubik one.

Loki retention is **360h** (15 days), and `max_query_lookback` matches it, so a query reaching further back returns nothing rather than erroring.


## Resolving a target to a uid

1. **The user names a cluster** — query `mimir` or `loki` with `cluster="<name>"`, or its per-cluster uid. The six cluster names above are the whole set of clusters; `core` goes to `mimir-core` or `loki-core`.
2. **The user names a workload, namespace, or repository** — resolve which clusters run it per `kilic-workload-resolution`, then select them with a `cluster` matcher on the federated uid.
3. **The user names nothing** — ask. Do not default to one cluster silently, and do not run an unscoped fleet query without saying that is what you are doing.

## The endpoints are flaky, and the failures lie

Verified behaviour, not speculation. Treat these as normal operating conditions:

- **Loki metadata endpoints return 502 often** — `list_loki_label_values`, `query_loki_stats`, and `analyze_loki_labels` all do it intermittently against a datasource that is serving queries fine. **Retry before concluding anything.** `analyze_loki_labels` is the worst offender because it walks every label including `__stream_shard__`; prefer `list_loki_label_names` plus targeted `list_loki_label_values`.
- **`check_datasources_health` flaps.** The same datasource times out on one call and reports OK on the next; the timeout is the Grafana proxy, not the datasource. A health result is never grounds for reporting a datasource down — prove it with an actual query.
- **Empty is not broken.** `loki-core` holds only the containers each host lists for shipping, so a container absent there returns nothing because it was never collected. That is a real answer, and reporting it as an outage is wrong.

When something genuinely does not respond after a retry, say which datasource and which call, and continue with the rest rather than abandoning the sweep.

## Parameter naming is inconsistent

The server does not use one convention, and the error messages are the only reliable guide:

- Query and metadata tools take **`datasourceUid`** — camelCase.
- Alerting tools take **`datasource_uid`** — snake_case, alongside `rule_limit` and `limit_alerts` rather than `limit`.

A wrong parameter name errors with the valid argument list, which is cheap. Guessing a label name does not error, which is not.

## What this stack does not have

- **Grafana-managed alert rules.** `alerting_manage_rules` with `operation: list` returns null. Alerting lives in the Mimir Ruler, fed by Alloy from the PrometheusRules in `monitoring-ruler`, in `monitoring-core` for the core tenant, and in the workload repositories and charts that own them, and is authored as rule files rather than through the Grafana API.
- **Grafana OnCall.** `list_alert_groups` fails resolving the OnCall URL with a 404 from the settings API. Every OnCall and IRM tool is unavailable; do not reach for them.
