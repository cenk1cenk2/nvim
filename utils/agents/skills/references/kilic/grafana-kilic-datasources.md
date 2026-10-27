# Grafana Kilic Datasources

The datasource model behind the `grafana-kilic` server, how a question resolves to a uid, and how the endpoints misbehave. Read this before any query: picking the wrong uid returns a confidently empty answer rather than an error.

## Model

Two federated datasources across the Kubernetes fleet, and three families with one datasource per tenant. All are provisioned from `cluster/workloads/monitoring-backbone` as the live inventory; `list_datasources` shows the same.

| Family | Type | uid | Covers |
|---|---|---|---|
| Mimir, federated | `prometheus` | `mimir`, the Grafana default | every Kubernetes cluster |
| Loki, federated | `loki` | `loki` | every Kubernetes cluster |
| Mimir | `prometheus` | `mimir-<tenant>` | one tenant |
| Loki | `loki` | `loki-<tenant>` | one tenant |
| Alertmanager | `alertmanager` | `alertmanager-<tenant>` | one tenant |

A tenant is a Kubernetes cluster or `core`. **`core` is not a cluster**: it is the estate outside Kubernetes, and **the federated uids exclude it**, so core data is reachable only through `mimir-core`, `loki-core` and `alertmanager-core`. Its label model: `kilic-core-tenant`. The set of clusters is the `cluster` label's values on `mimir`.

## Federated and per-tenant datasources

The federated `mimir` and `loki` query every Kubernetes tenant at once; a per-tenant uid holds exactly one, so its `cluster` label has a single value.

- **A fleet question is one query on `mimir` or `loki`**, broken out `by (cluster)`, not one per cluster. It still costs the sum over every tenant, so say so before running it and scope to the clusters the question names.
- **On a federated uid the `cluster` matcher is what scopes the query.** Leave it out and you read every tenant. Only on a per-tenant uid is it redundant.
- **One cluster on `mimir` costs about the same as its per-tenant uid.** Federation visits every tenant, but the others return nothing after an index lookup.
- **Federated `mimir` puts `__tenant_id__` on every raw series**, and aggregation drops it. A binary operator between a raw series and an aggregate with no `on (...)` matches nothing, and a bare `or` returns both sides, so totals come out exactly doubled. Match with `on (...)` including `cluster`, and aggregate `__tenant_id__` away with `by (...)`.
- **The per-tenant uids stay provisioned** for what federation cannot do: Loki live tail rejects more than one tenant, the ruler API rejects federated requests so rule state is read per tenant, and Explore and the Grafana Alerting view use them. Keep a per-tenant sweep for deep single-cluster work such as rightsizing.

**Every datasource is a tenant view, not a backend.** Mimir and Loki are each a single multi-tenant instance on the central cluster; every other cluster runs only collectors that ship to them. Per-tenant limits are therefore enforced on shared infrastructure, so one noisy tenant is a neighbour problem, and an incident in either store affects every tenant at once: the central cluster being down is a fleet-wide observability outage. On logs the tenant appears as `tenant` structured metadata, which cross-checks that the uid you used is the cluster you meant.

**Retention bounds every query.** Loki's `max_query_lookback` matches its retention, so a query reaching further back returns nothing rather than erroring; the current values are in monitoring-backbone's Loki and Mimir values.

Dashboard conventions for datasource and `cluster` variables: `grafana-kilic-dashboards`.

## Resolving a target to a uid

1. **The user names a cluster**: query `mimir` or `loki` with `cluster="<name>"`, or its per-tenant uid; `core` goes to `mimir-core` or `loki-core`.
2. **The user names a workload, namespace, or repository**: resolve which clusters run it per `kilic-workload-resolution`, then select them with a `cluster` matcher on the federated uid.
3. **The user names nothing**: ask. Do not default to one cluster silently, and do not run an unscoped fleet query without saying that is what you are doing.

## The endpoints are flaky, and the failures lie

Treat these as normal operating conditions:

- **Loki metadata endpoints return 502 intermittently** (`list_loki_label_values`, `query_loki_stats`, `analyze_loki_labels`) against a datasource that is serving queries fine. **Retry before concluding anything.** `analyze_loki_labels` is the worst offender because it walks every label; prefer `list_loki_label_names` plus targeted `list_loki_label_values`.
- **`check_datasources_health` flaps.** The timeout is the Grafana proxy, not the datasource. A health result is never grounds for reporting a datasource down; prove it with an actual query.
- **Empty is not broken.** A source that ships only what it is configured to ship returns nothing for what was never collected. That is a real answer, and reporting it as an outage is wrong.

When something genuinely does not respond after a retry, say which datasource and which call, and continue with the rest rather than abandoning the sweep.

## Parameter naming is inconsistent

- Query and metadata tools take **`datasourceUid`**, camelCase.
- Alerting tools take **`datasource_uid`**, snake_case, alongside `rule_limit` and `limit_alerts` rather than `limit`.

A wrong parameter name errors with the valid argument list, which is cheap. Guessing a label name does not error, which is not.

## What this stack does not have

- **Grafana-managed alert rules.** Alerting lives in the Mimir Ruler, fed by Alloy from PrometheusRules in their owning repositories, and is authored as rule files rather than through the Grafana API.
- **Grafana OnCall.** Every OnCall and IRM tool is unavailable; do not reach for them.
