---
name: grafana-kilic
description: grafana-kilic Manual for the grafana-kilic MCP server - resolve a question to the right datasource uid, know which tool families exist and which are absent, and route to the skill that owns the task. Load before the first call to that server. Not for the query construction itself, dashboards, alert rules, or rightsizing.
argumentHint: '[what you are about to ask Grafana]'
references:
  - ../references/kilic/grafana-kilic-datasources.md
  - ../references/kilic/kilic-workload-resolution.md
---

## The grafana-kilic Server

The MCP server for the monitoring stack: metrics, logs, dashboards, alert state. **Load this before the first call to it**, then route to whichever skill owns the actual task.

Datasource inventory, the federated and per-cluster uids, endpoint flakiness, and parameter naming: `grafana-kilic-datasources`.

## Resolve the Target First

Every query tool needs a datasource uid, and picking the wrong one returns a confidently empty answer rather than an error.

1. **A cluster is named** — use it. The seven are `core`, `moon`, `nailbed`, `neutrino`, `overseer`, `rubik`, `sun`.
2. **A workload, namespace, or repository is named** — resolve which clusters run it per `kilic-workload-resolution`, then select them with a `cluster` matcher.
3. **Nothing is named** — ask. Do not silently pick one cluster. A fleet question is one query on the federated uid, broken out `by (cluster)`, but it costs the sum over every tenant, so say so before running it.

Then pick the family: `mimir` for metrics and `loki` for logs, both federated across the six Kubernetes clusters, with the `cluster` matcher doing the scoping; `mimir-core` and `loki-core` for core, which the federated uids exclude; `alertmanager-<cluster>` for alert state. The per-cluster `mimir-<cluster>` and `loki-<cluster>` uids remain for live tail, the ruler API, and deep single-cluster work such as rightsizing — a per-cluster sweep is optional, no longer the default.

## Route to the Owning Skill

| Task | Skill |
|---|---|
| Query metrics or logs | `grafana-kilic-read` |
| Author or fix a dashboard | `grafana-kilic-dashboards` |
| Author or tune an alert rule | `grafana-kilic-alerts` |
| Find or apply container rightsizing | `grafana-kilic-rightsize` |

This skill resolves targets and sets expectations. It does not teach query construction — the label model, the two-tier Loki split, and the recording rules live in `grafana-kilic-read`, and getting them wrong returns zero rows without erroring.

## Never Write Through This Server

Dashboards, folders and alert rules are **GitOps-owned** — they reach Grafana only through ArgoCD from their repositories. A change written through the API is unowned, will be reverted, and hides where the truth lives.

Use the server's read tools freely to verify. For anything that changes what Grafana shows, edit the owning repository through the skill in the routing table above.

## Key Principles

1. **Resolve the uid before the query.** A wrong datasource answers confidently and wrongly.
2. **Fleet questions go to the federated `mimir` and `loki`** — one query broken out `by (cluster)`, not seven. It still costs every tenant, so say so before running it; core is only in `mimir-core` and `loki-core`.
3. **Read here, write in the repository.**
4. **Route to the owning skill** rather than improvising a query, a panel, or a rule.
5. **Retry before concluding**, and distinguish empty from broken.
