# Rightsize Signals

The four signals, what each one is worth, the thresholds that make a candidate material, and the queries that produce them. Metrics come from Mimir, one cluster at a time: the per-cluster `mimir-<cluster>` uid, or the federated `mimir` with a `cluster` matcher on every selector — both read the same data. `core` is only in `mimir-core`. Sizing is a per-cluster decision, so never size from an All-cluster query. The `grafana-kilic` skill carries the cost model and the `__tenant_id__` join trap.

## Weighting

**VPA opens a case. It never closes one.** Recommendations are decayed estimates over roughly eight days of history; they lag a workload that changed shape, and they cannot see that a container was killed for exceeding its limit.

| Signal | Window | Weight |
|---|---|---|
| VPA bounds versus request | live | Opens the case. Never sufficient alone. |
| Actual usage — working set, CPU rate | 7d | Confirms or kills the VPA suggestion. |
| OOMKilled | 7d | Heavy. Memory floor. Surface it and offer to act. |
| Sustained throttling, long-running workload | 7d | Heavy. CPU limit floor. |
| Brief throttle spikes, or Job/CronJob-owned pods | 7d | Low. List separately, never propose alone. |

**OOM is a floor, not a veto.** A container OOMKilled in the last 7d must not have its memory reduced, whatever VPA says — but the finding is worth raising on its own, because a workload being killed is a live problem rather than an efficiency one. Surface it, name the evidence, and offer to raise memory in the same pass.

**Sustained throttling is a floor the same way.** Sustained means a meaningful share of periods throttled across the window by the summed figure below, not a spike during startup or a batch burst. A Job throttling at 100% for ninety seconds is usually working as intended.

## Materiality

A candidate is only worth proposing when the change clears both floors for its resource:

| Resource | Absolute floor | Relative floor |
|---|---|---|
| CPU | 25m | 20% of the current request |
| Memory | 32Mi | 20% of the current request |

Both apply to **requests**. Below the floors, the change is noise: it costs a merge request, a sync, and a pod restart to reclaim an amount nobody can measure. Say the candidate was skipped and why rather than dropping it silently.

## What Each Value Targets

The sizing is tight: each value is the measured figure on the grid, with no multiplier on top.

| Value | Target |
|---|---|
| `requests.memory` | 7d time-weighted average of the busiest pod per 5-minute step |
| `requests.cpu` | the same shape on the 5m CPU rate |
| `limits.memory` | smallest grid stop at or above the 7d max working set |
| `limits.cpu` | smallest grid stop at or above the 7d max of the 5m CPU rate |

- **A limit never drops below its 7d max**, and a limit is never added where the workload had none — a new limit can throttle or kill a workload that never had one.
- **No bursty multiplier.** A bursty workload's memory limit is its 7d max on the grid, like every other; the 1.5x pad is not applied. What the bursty classification changes is how the max is read, per `rightsize-bursty-list`.
- **Grid** per `rightsize-snap-grids`, including the in-between stops taken wherever they sit materially closer to the sample.

## Queries

`$c` is the cluster's `mimir-<cluster>` uid; on the federated `mimir`, add `cluster="<name>"` to every selector instead. Substitute the namespace and workload filters as scope requires.

**VPA recommendation versus request** — the outlier definition the dashboard uses. Under-provisioned is `request < lowerbound`; over-provisioned is `request > upperbound`. VPA's `_target` points at a value; the queries below decide it:

```promql
max by (cluster, namespace, target_kind, target_name, container) (
  kube_customresource_verticalpodautoscaler_status_recommendation_containerrecommendations_target{resource="cpu"}
)
```

The join from VPA to running pods strips the replicaset hash off the pod name:

```promql
label_replace(
  kube_pod_container_resource_requests{container!="", resource="cpu"},
  "target_name", "$1", "pod", "^(.*?)(?:-[a-f0-9]{8,10}-[a-z0-9]{5}|-[0-9]+)$"
)
* on(cluster, namespace, target_name) group_left(target_kind, verticalpodautoscaler)
max by (cluster, namespace, target_kind, target_name, verticalpodautoscaler) (
  kube_customresource_verticalpodautoscaler_labels
)
```

**Requests — aggregate per step, then over time:**

```promql
# memory request, Mi
avg_over_time(max by (container) (container_memory_working_set_bytes{namespace="<ns>", container="<name>"})[7d:5m]) / 1024 / 1024

# CPU request, millicores
avg_over_time(max by (container) (rate(container_cpu_usage_seconds_total{namespace="<ns>", container="<name>"}[5m]))[7d:5m]) * 1000
```

The inner `max by (container)` picks the busiest pod alive at each 5-minute step; the outer `avg_over_time` weights each step equally across the 7d. Every replica gets the same request, so the busiest one is the one it has to fit.

**Never size a request from a per-series average** — `max by (container) (avg_over_time(...[7d]))` or `avg by (container) (avg_over_time(...))`. Each pod is its own series, and a pod that lived only through a spike averages to the spike; the outer `max` then picks it. Any workload whose pods churned in the window reads inflated. Measured on rubik: mimir's querier reads 261Mi that way against a 52.8Mi time-weighted average, store-gateway 768Mi against 510Mi, and ollama 5.1Gi over.

**Limits — the max is churn-safe:**

```promql
# memory limit, Mi
max by (container) (max_over_time(container_memory_working_set_bytes{namespace="<ns>", container="<name>"}[7d])) / 1024 / 1024

# CPU limit, millicores
max_over_time(max by (container) (rate(container_cpu_usage_seconds_total{namespace="<ns>", container="<name>"}[5m]))[7d:5m]) * 1000
```

A maximum over every series is the true peak whatever the pods did, so the per-series form is correct here.

**OOM kills in the window:**

```promql
count by (cluster, namespace, pod, container) (
  kube_pod_container_status_last_terminated_reason{reason="OOMKilled"} > 0
)
max_over_time(kube_pod_container_status_restarts_total[7d])
```

**Throttling — sum the periods, then divide:**

```promql
100 * sum by (container) (increase(container_cpu_cfs_throttled_periods_total{namespace="<ns>", container="<name>"}[7d]))
    / sum by (container) (increase(container_cpu_cfs_periods_total{namespace="<ns>", container="<name>"}[7d]))
```

Summing throttled and total periods across every pod over the window is the honest figure. A per-series ratio inflates the same way a per-series average does: a pod restarted in the window and throttled through its startup reports a high percentage over a handful of periods.

Read it beside the CPU request query. A steadily throttled container shows a high summed figure with an average close to its limit, and takes a CPU **limit** raise. A container whose summed figure is high while its time-weighted average sits far below the limit is throttling in sub-second bursts at each scrape — the CFS quota working as designed. Exporters are the usual case; leave them untouched.

Join through `namespace_workload_pod:kube_pod_owner:relabel` to get `workload` and `workload_type`, and use `workload_type` to separate Jobs and CronJobs from long-running controllers.

## The dashboards

The outlier definitions are maintained as dashboards, and those are the source of truth when this reference and they disagree:

- `kubernetes-autoscaling-vpa-outliers` — Autoscaling > Vertical Pod Autoscaler > Outliers. Under and Over-Provisioned CPU and Memory tables, plus Throttled Containers.
- `kubernetes-autoscaling-mixin-vpa-jkw2` — Autoscaling > Vertical Pod Autoscaler.

Their JSON lives in git at `cluster/workloads/monitoring-view/.deploy/rubik/dashboards/kubernetes/`. Read the panel queries from the dashboard rather than trusting a copy when a verdict is contested.

Both query the federated `mimir` with a multi-select `cluster` that **defaults to All**. Select the one cluster being sized before reading a table: under All the top 25 is ranked across the fleet, so a cluster's own outliers can be missing from it entirely.

Both tables cap at the top 25 by ratio. A quiet table means nothing outside the bounds ranked highly enough, never that the cluster is correctly sized.
