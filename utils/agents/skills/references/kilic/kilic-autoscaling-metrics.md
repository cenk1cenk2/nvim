# Autoscaling Metrics: kilic

What the estate can measure about VPA, in-place resizing and KEDA, what it cannot, and what each autoscaling alert means for triage. Read the families here before building a query, panel or rule on them; an absent family reads as "no data", which looks the same as "nothing happened".

## Families that exist

| Family | Source | What it carries |
|---|---|---|
| `kube_customresource_verticalpodautoscaler_status_recommendation_containerrecommendations_target`, `_lowerbound`, `_upperbound`, `_uncappedtarget` | `chart-vpa`'s own kube-state-metrics, custom-resource-state config in `files/kube-state-metrics.yaml` | One series per VPA, container and `resource` (`cpu` in cores, `memory` in bytes), labelled `verticalpodautoscaler`, `namespace`, `target_kind`, `target_name`, `update_mode`, `container`. |
| `kube_customresource_verticalpodautoscaler_labels` | the same | One info series per VPA, carrying `update_mode`. **The only way to exclude a switched-off VPA**: filter `update_mode!="Off"`, as the `VPARequests*` rules do. |
| `kube_customresource_verticalpodautoscalercheckpoint_status_last_sample_start` | the same | Newest sample the recommender holds per container; `time() - ...` is recommendation freshness. |
| `vpa_updater_in_place_updated_pods_total` and `vpa_updater_evicted_pods_total` | the VPA updater, scraped by `chart-vpa`'s pod monitors | **The pair that proves in-place resizing and the absence of restarts**: the first rising while the second stays flat. |
| `vpa_updater_failed_in_place_update_attempts_total` | the VPA updater | Failed in-place attempts by `vpa_namespace`, `vpa_name` and `reason`. |
| `kubelet_pod_pending_resizes` | the kubelet | Gauge, per node, `reason` = `Deferred` or `Infeasible`. |
| `kubelet_pod_infeasible_resizes_total` | the kubelet | Counter, per node, of resizes the kubelet rejected as infeasible. |
| `kubelet_pod_in_progress_resizes` | the kubelet | Gauge, per node, of resizes being actuated. |
| `keda_scaler_metrics_value{exported_namespace, scaledObject}` | KEDA | **The number KEDA acts on** for each trigger — compare it with the trigger's threshold. The namespace label is `exported_namespace`, not `namespace`. |

Both kubelet resize families are **node-level with no pod attribution**: a series names the node, never the pod. Finding the pod means listing the pods on that node and reading their `PodResizePending` condition through the cluster read path.

## What does not exist, and how it misleads

- **`kube_pod_status_conditions` is not a kube-state-metrics family at all.** `PodResizePending` cannot be queried from Mimir; it is read from the pod object only.
- **Lazily created series are absent until their first event.** `kubelet_pod_pending_resizes`, `kubelet_pod_infeasible_resizes_total` and the updater's failure counters appear only after the first observation. Their absence means no such event has happened yet, not that collection is broken — never "fix" an alert because its metric has no series.
- **The collector strips `reason` from every metric not on its keep-list.** The keep-list is the `delete_key(datapoint.attributes, "reason")` statement in `cluster/workloads/monitoring`, `.deploy/base/opentelemetry-collector/metrics/opentelemetry-collector.yaml`. A metric missing from it silently merges `Deferred` with `Infeasible` and every other reason into one series. A rule or panel that splits by `reason` on a new family starts with adding that family to the keep-list.
- **`vpa_updater_in_place_updatable_pods_total` minus `vpa_updater_in_place_updated_pods_total` is not a deferral signal.** One is a gauge and the other a counter, so the difference means nothing.

## Rules and what they mean for triage

All live in `cluster/workloads/monitoring-ruler`, `.deploy/base/alerts/kubernetes/vpa.yaml` and `vpa-resizing.yaml`, recording rule `vpa:kube_pod_container_resource_requests:max` in `.deploy/base/rules/kubernetes/vpa.yaml`. Each links the `kubernetes-autoscaling-vpa-resizing` dashboard.

| Alert | Fires when | Triage |
|---|---|---|
| `VPARequestsBelowLowerBound` | For 6h, a non-`Off` VPA's target is over 1.5x the live request and the request is below `lowerbound`. | The updater wants to grow the request and it is not landing. Check the pods' resize status and the node's free allocatable; a grow that cannot fit stays pending. |
| `VPARequestsAboveUpperBound` | For 6h, the live request is over 1.5x the target and above `upperbound`. | Capacity reserved and unused. Check the updater acts on the pods at all, and whether a chart or operator writes the request back after each resize. |
| `KubeletPodResizePending` | For 30m, a node holds pending resizes, split by `reason`. | `Deferred` waits for room on the node; `Infeasible` will never fit there. Find the pods on the node with `PodResizePending`. |
| `KubeletPodResizeInfeasible` | For 30m, the node rejected resizes as infeasible in the last hour. | The pod can never reach its new size on that node. Compare the requested size with the node's allocatable and check the node's resize support for that reason. |
| `VPATargetPinnedAtLimit` | For 6h, a freshly refreshed target sits at the container limit. | The request band reaches the authored limit. Raise the limit or lower `maxAllowed`; `maxAllowed` must stay at or below the limit. |
| `VPAResizeChurn` | For 1h, a container's request or limit changed in place more than 12 times in 6h without a restart. | Read whether the request leaves the `lowerbound`–`upperbound` band. Drift inside the band is filtered by the updater's `pod-update-threshold` in `chart-vpa`, not a sizing problem. |
| `VPAInPlaceResizeFailed` | Any increase of the updater's failed in-place counter, by `reason`. | Read the `reason`, then node capacity and the target workload's resize status. |
