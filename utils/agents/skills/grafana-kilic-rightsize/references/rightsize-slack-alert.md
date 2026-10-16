# Rightsize Slack Alert

The flow from a `CPUThrottlingHigh` alert dropped in a Slack thread to a resource change. The alert attachment is the specification: there is no scoping question and no discovery mode, and never ask which issue it belongs to.

## Phase 1: extract the alert

1. Read the thread through `slack-kilic`. The parent message is a webhook whose attachment carries the payload.
2. Pull `alertname`, `cluster`, `namespace`, `container`, `pod`, `severity` and the throttling percentage out of the attachment.
3. The cluster's datasource is `mimir-<cluster>`, or `cluster="<cluster>"` on every selector against the federated `mimir`; confirm the live set with `grafana-kilic__list_datasources(type="prometheus")`.

## Phase 2: find the owning repository

Resolve the container through ArgoCD per `kilic-workload-resolution`. A component under `monitoring-system` supplied by a chart wrapper resolves to `cluster/charts/chart-<name>` and takes the arithmetic in `rightsize-charts-cross-cluster`; a first-party component resolves to `cluster/workloads/<name>`. Read the current limits with `kube_pod_container_resource_limits` on that cluster's Mimir before touching either. When the limits were already changed, investigate per `rightsize-throttling-alert` instead.

## Phase 3: sample, or fall back to the floor

Read the requests, the limits and the summed throttle figure per `rightsize-signals`, scoped to the alert's `namespace` and `container` on that cluster. The summed figure decides whether the container is steadily throttled or bursting by design; only the first takes a CPU limit raise.

**When Grafana is unreachable**, do not block. Use the value floors in `rightsize-snap-grids` for the obvious cases: a DaemonSet component at 100m goes to the 250m CPU floor, a lightweight controller at 10m goes to 100m, and 128Mi is already at or above the 64Mi memory floor for most exporters. Tell the user the fallback was used and ask whether to proceed now or wait for metrics. Never present floor values as sampled data.

## Phase 4: file the issue and land the change

1. Create the Linear issue through `linear-kilic` in the resource-tuning project with the alert details, the current limit, the target values, their provenance (sampled or floor fallback), and the repository path.
2. Set the state explicitly; the API default is not the state this workflow wants.
3. Land the change per the Implementation steps of `grafana-kilic-rightsize`.

## Phase 5: sweep the other clusters

After the merge request exists, confirm the scope with one query on the federated `mimir`: `count by (cluster) (ALERTS{alertstate="firing", alertname="<name>", container="<container>"})` covers every Kubernetes cluster at once. Report which clusters are affected and which are clean, in the Slack thread and on the Linear issue. A fix in a chart repository reaches every cluster on deploy, so say so explicitly. This sweep is one query, not a second change.

## Pitfalls

- **Assuming the alert already has a Linear issue.** Most alerts arrive as raw webhook deliveries; create the issue.
- **A DaemonSet limit is per node.** Throttling on one node means that node's copy is starved, and the fix, bumping the chart default, applies to every node.
