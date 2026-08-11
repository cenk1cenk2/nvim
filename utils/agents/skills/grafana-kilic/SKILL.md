---
name: grafana-kilic
description: grafana-kilic Manual for the grafana-kilic MCP server - resolve a question to the right datasource uid, know which tool families exist and which are absent, and route to the skill that owns the task. Load before the first call to that server. Not for the query construction itself, dashboards, alert rules, or rightsizing.
argumentHint: '[what you are about to ask Grafana]'
references:
  - ../references/kilic/grafana-kilic-datasources.md
---

## The grafana-kilic Server

The MCP server for the monitoring stack: metrics, logs, dashboards, alert state. **Load this before the first call to it**, then route to whichever skill owns the actual task.

Datasource inventory, the one-cluster-per-uid model, endpoint flakiness, and parameter naming: `grafana-kilic-datasources`.

## Resolve the Target First

Every query tool needs a datasource uid, and picking the wrong one returns a confidently empty answer rather than an error.

1. **A cluster is named** — use it. The seven are `core`, `moon`, `nailbed`, `neutrino`, `overseer`, `rubik`, `sun`.
2. **A workload, namespace, or repository is named** — resolve which clusters run it per `kilic-workload-resolution`, then query each.
3. **Nothing is named** — ask. Do not silently pick one, and do not sweep all seven without saying so; there is no fleet-wide datasource, so a fleet question is seven queries with a real cost.

Then pick the family: `mimir-<cluster>` for metrics, `loki-<cluster>` for logs, `alertmanager-<cluster>` for alert state.

## Route to the Owning Skill

| Task | Skill |
|---|---|
| Query metrics or logs | `grafana-kilic-read` |
| Author or fix a dashboard | `grafana-kilic-dashboards` |
| Author or tune an alert rule | `grafana-kilic-alerts` |
| Find or apply container rightsizing | `grafana-kilic-rightsize` |

This skill resolves targets and sets expectations. It does not teach query construction — the label model, the two-tier Loki split, and the recording rules live in `grafana-kilic-read`, and getting them wrong returns zero rows without erroring.

## What This Stack Does Not Have

Discovered by these failing, so do not spend calls rediscovering them:

- **Grafana-managed alert rules.** `alerting_manage_rules` with `operation: list` returns null. Alerting is Mimir Ruler rules from the `monitoring-ruler` repo — `grafana-kilic-alerts` owns that.
- **Grafana OnCall.** Every OnCall and IRM tool fails resolving the OnCall URL with a 404 from the settings API.
- **Loki logs on `core`.** That datasource is healthy and empty. Empty is a real answer, not an outage.

## Never Write Through This Server

Dashboards, folders and alert rules are **GitOps-owned** — they reach Grafana only through ArgoCD from their repositories. A change written through the API is unowned, will be reverted, and hides where the truth lives.

Use the server's read tools freely to verify. For anything that changes what Grafana shows, edit the owning repository through the skill in the routing table above.

## Expect the Endpoints to Misbehave

Covered fully in `grafana-kilic-datasources`, but the three that most often cause a wrong conclusion:

- **Loki metadata endpoints 502 intermittently** while queries work. Retry once before reporting a problem.
- **`check_datasources_health` flaps** — a timeout is the Grafana proxy, not the datasource. Prove state with a query.
- **Empty is not broken.**

## Key Principles

1. **Resolve the uid before the query.** A wrong datasource answers confidently and wrongly.
2. **One datasource is one cluster; fleet questions cost seven queries.** Say so before running them.
3. **Read here, write in the repository.**
4. **Route to the owning skill** rather than improvising a query, a panel, or a rule.
5. **Retry before concluding**, and distinguish empty from broken.
