---
name: grafana-kilic-read
description: grafana-kilic-read Query metrics and logs correctly - Loki splits labels into indexed stream labels and structured metadata, and putting the wrong one inside the braces returns zero rows instead of an error. Use on "check the metrics", "read the logs", "why is this pod restarting". Not for authoring dashboards, writing alert rules, or rightsizing workloads.
disableModelInvocation: true
argumentHint: '[what to look at] - e.g. ''logs for mimir-ruler on rubik'', ''memory usage in monitoring'''
references:
  - ../references/kilic/grafana-kilic-datasources.md
  - ../references/kilic/loki-label-model.md
  - ../references/kilic/kilic-workload-resolution.md
---

## Reading Grafana

Datasource inventory, target resolution, endpoint flakiness, and parameter naming: `grafana-kilic-datasources`. Resolving a workload to the clusters that run it: `kilic-workload-resolution`.

Label names, the indexed-versus-structured-metadata split, and the empty-result trap that follows from it: `loki-label-model`. That split is the single most common source of a wrong answer here, because the wrong form returns zero rows without erroring.

## Mimir — Prefer the Recording Rules

The kube-prometheus mixin rules are precomputed, far cheaper than the raw cadvisor series, and carry the workload join already done:

| Rule | Use for |
|---|---|
| `node_namespace_pod_container:container_memory_working_set_bytes` | Memory usage per container |
| `node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate` | CPU usage per container |
| `namespace_workload_pod:kube_pod_owner:relabel` | Pod to workload and `workload_type` mapping |
| `cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests` | Active requests, CPU and memory variants |
| `namespace_cpu:kube_pod_container_resource_requests:sum` | Per-namespace totals, CPU and memory variants |
| `instance:node_cpu:ratio`, `instance:node_memory_utilisation:ratio` | Node-level utilisation |
| `workload:pvc_used_bytes`, `workload:pvc_capacity_bytes` | PVC usage, a local rule set rather than mixin |

**Metrics are filtered aggressively at ingestion.** The collector drops everything outside an explicit allowlist, so a metric that exists upstream may simply not be here — `loki_*` internals, most `kubelet_*`, and most `container_*` beyond cpu/memory/fs/network basics are dropped. When a metric returns nothing, check it survives ingestion before assuming the target is down.

Use `list_prometheus_metric_names` with a `regex` to discover, and `list_prometheus_metric_metadata` for a metric's type and help text.

## Tool Behaviour

- **`query_prometheus` requires `startTime` and `endTime`**, even for an instant query. Omitting them fails with a time-parsing error that never mentions the missing parameter. `now` is accepted for both.
- **`query_loki_logs` defaults to a one-hour lookback** when `startRfc3339` and `endRfc3339` are omitted, and says so in `hints`. Read those hints — they also carry the diagnosis when a query returns nothing.
- **Set `limit` deliberately.** Responses report `totalLinesScanned` and `resultsTruncated`; a truncated sample is not evidence of a pattern.
- Large results are written to a file rather than returned inline. Slice them rather than narrowing a query you did not intend to narrow.

## Process

1. **Resolve the target to datasource uids** per `grafana-kilic-datasources`. Ask which clusters when the request does not say.
2. **Pick the side.** Metrics answer "how much and when", logs answer "what happened and why". Restarts, OOM kills and throttling are metrics; the reason a process died is logs.
3. **Build the selector from stream labels only**, and put everything else after a `|`.
4. **Verify a stream exists before trusting an empty result.** Select on namespace alone, then narrow.
5. **Retry a 502 once** before reporting a datasource problem.
6. **Report the query you ran.** A finding without its query cannot be checked or re-run.

## Key Principles

1. **A wrong Loki selector is silent.** Empty means suspect the query first, the world second.
2. **Names match across Mimir and Loki; tiers do not.** The question is never "what is it called", it is "is it indexed".
3. **Structured metadata is filtered with `|`, never selected inside `{}`.**
4. **`workload_type` is lowercase.** A value from a Prometheus field needs `(?i)`.
5. **A label in the listing may be dead.** Listings span the retention window, not current ingestion.
6. **Prefer recording rules**, and remember metrics are allowlisted at ingestion.
7. **One datasource is one cluster.** Fleet questions are per-cluster sweeps with a real cost.
8. **Report the query alongside the answer.**

## Examples

**User says:** "why did mimir-ruler restart on rubik"

1. One cluster: `mimir-rubik` and `loki-rubik`.
2. Metrics for the shape — restart count and last terminated reason.
3. Logs for the cause: `{namespace="monitoring", deployment="mimir-ruler"} | container="ruler" | detected_level="error"`.
4. Report both, with the queries.

**Result:** Restart count from Mimir, reason from Loki, and no time lost to an empty result caused by putting `container=` in the selector.

---

**User says:** "logs for the loki-write-1 pod"

1. There is no `pod` stream label, so select the workload and filter the pod.
2. `{namespace="monitoring", statefulset="loki-write"} | pod="loki-write-1"`.

**Result:** The right lines, instead of the empty set that `{pod="loki-write-1"}` returns.
