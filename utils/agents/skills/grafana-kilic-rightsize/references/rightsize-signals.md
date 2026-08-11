# Rightsize Signals

The four signals, what each one is worth, the thresholds that make a candidate material, and the queries that produce them. Metrics come from the per-cluster Mimir datasources — `mimir-core`, `mimir-moon`, `mimir-nailbed`, `mimir-neutrino`, `mimir-overseer`, `mimir-rubik`, `mimir-sun`. There is no fleet-wide datasource, so every query runs per cluster.

## Weighting

**VPA opens a case. It never closes one.** Recommendations are decayed estimates over roughly eight days of history; they lag a workload that changed shape, and they cannot see that a container was killed for exceeding its limit.

| Signal | Window | Weight |
|---|---|---|
| VPA bounds versus request | live | Opens the case. Never sufficient alone. |
| Actual usage — working set, CPU rate | 7d | Confirms or kills the VPA suggestion. |
| OOMKilled | 7d | Heavy. Memory floor. Surface it and offer to act. |
| Sustained throttling, long-running workload | 7d | Heavy. CPU floor. |
| Brief throttle spikes, or Job/CronJob-owned pods | 7d | Low. List separately, never propose alone. |

**OOM is a floor, not a veto.** A container OOMKilled in the last 7d must not have its memory reduced, whatever VPA says — but the finding is worth raising on its own, because a workload being killed is a live problem rather than an efficiency one. Surface it, name the evidence, and offer to raise memory in the same pass.

**Sustained throttling is a floor the same way.** Sustained means a meaningful share of periods throttled across the window, not a spike during startup or a batch burst. A Job throttling at 100% for ninety seconds is usually working as intended.

## Materiality

A candidate is only worth proposing when the change clears both floors for its resource:

| Resource | Absolute floor | Relative floor |
|---|---|---|
| CPU | 25m | 20% of the current request |
| Memory | 32Mi | 20% of the current request |

Both apply to **requests**. Touch limits only where the workload already sets them; do not introduce a limit that did not exist, and never lower a limit below observed peak usage.

Below the floors, the change is noise: it costs a merge request, a sync, and a pod restart to reclaim an amount nobody can measure. Say the candidate was skipped and why rather than dropping it silently.

## Queries

`$c` is the cluster's datasource uid. Substitute the namespace and workload filters as scope requires.

**VPA recommendation versus request** — the outlier definition the dashboard uses. Under-provisioned is `request < lowerbound`; over-provisioned is `request > upperbound`. Compare against `_target` for the value to propose:

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

**Actual usage over the window** — the confirmation step:

```promql
# memory, peak working set
max_over_time(container_memory_working_set_bytes{container!=""}[7d])

# memory, typical
quantile_over_time(0.95, container_memory_working_set_bytes{container!=""}[7d])

# cpu, typical and peak
quantile_over_time(0.95, rate(container_cpu_usage_seconds_total{container!=""}[5m])[7d:5m])
max_over_time(rate(container_cpu_usage_seconds_total{container!=""}[5m])[7d:5m])
```

Propose memory requests against the p95 and check the peak against the limit. Propose CPU requests against the p95; CPU is compressible, so peak matters less than sustained throttling.

**OOM kills in the window:**

```promql
count by (cluster, namespace, pod, container) (
  kube_pod_container_status_last_terminated_reason{reason="OOMKilled"} > 0
)
max_over_time(kube_pod_container_status_restarts_total[7d])
```

**Throttling, as a percentage of CFS periods:**

```promql
100 * (
  rate(container_cpu_cfs_throttled_periods_total{container!=""}[7d])
  / rate(container_cpu_cfs_periods_total{container!=""}[7d])
)
```

Join through `namespace_workload_pod:kube_pod_owner:relabel` to get `workload` and `workload_type`, and use `workload_type` to separate Jobs and CronJobs from long-running controllers.

## The dashboards

The outlier definitions are maintained as dashboards, and those are the source of truth when this reference and they disagree:

- `kubernetes-autoscaling-vpa-outliers` — Autoscaling > VPA > Outliers. Under and Over-Provisioned CPU and Memory tables, plus Throttled Containers.
- `kubernetes-autoscaling-mixin-vpa-jkw2` — Autoscaling > Vertical Pod Autoscaler.

Their JSON lives in git at `cluster/workloads/monitoring-view/.deploy/<cluster>/dashboards/kubernetes/`. Read the panel queries from the dashboard rather than trusting a copy when a verdict is contested.

Both tables cap at the top 25 by ratio. A quiet table means nothing outside the bounds ranked highly enough, never that the cluster is correctly sized.
