# Rightsize HPA Anchor

`target.averageUtilization` is a percentage of `requests`, not of `limits`. Once requests are cut to the snap floor, an 80 percent target fires at `0.8 x 10m = 8m` CPU, which is meaningless. The autoscaler has to fire before the pod saturates its limit, or it is throttled long before it scales.

## Before any request change

Read every HPA targeting the workload, and every chart-native autoscaling key, before a request moves. A Utilization target — `averageUtilization`, or a chart's `targetCPU` / `targetMemory` — divides live usage by the request, so the request is the HPA's denominator:

- **A request cut multiplies the utilization the HPA sees.** With zitadel's `targetCPU: 300`, a CPU request cut from 150m to 10m makes it scale out at 30m of usage instead of 450m. envoy-gateway's Utilization HPA pins scale-out the same way once its request shrinks.
- **Hold the request** on a Utilization-anchored workload unless the same change re-anchors the HPA below. Holding is the default; both workloads above kept their requests.
- **Re-anchor only when the resize touches an HPA-anchored workload.** A resize that changes neither the request nor the limit an HPA reads leaves the HPA alone.

## Formula

`averageValue = floor(0.8 x limit)`, and it MUST be strictly less than the limit.

| Limit | Target averageValue |
|---|---|
| `cpu: 250m` | `cpu: 200m` |
| `cpu: 1000m` | `cpu: 800m`, or `cpu: "0.8"` where the chart prefers integer CPU |
| `cpu: 2` | `cpu: "1.6"` |
| `mem: 64Mi` | `mem: 51Mi` |
| `mem: 1Gi` | `mem: 819Mi` |
| `mem: 2Gi` | `mem: 1638Mi` |
| `mem: 4Gi` | `mem: 3276Mi` |

## Preferred form: absolute averageValue

Absolute thresholds decouple the HPA from any later retune of `requests`:

```yaml
- type: Resource
  resource:
    name: cpu
    target:
      type: AverageValue
      averageValue: 200m   # 0.8 x limits.cpu
- type: Resource
  resource:
    name: memory
    target:
      type: AverageValue
      averageValue: 51Mi   # 0.8 x limits.memory
```

## Percentage form

When the chart only offers `target.averageUtilization`, or a chart-native `targetCpu` / `targetMemory` integer, both are percentages of requests and carry the same semantics. Recompute as `(0.8 x limit) / request x 100`. The number looks large, for instance 2000 for a 10m request against a 250m limit, and the arithmetic is still correct. Record the resulting number in the change description so a reviewer can check it.

## Replica bounds are not sizing knobs

`minReplicas` stays at 1 or above: dropping it to 0 lets the pod count reach zero and kills in-flight requests on the next scale-up. `maxReplicas` is a safety net and is not derived from resources.

A workload with more than one HPA applies the same formula per HPA, since each targets its own Deployment with its own resources block.

## Pitfalls

- **`averageValue` set to the limit rather than 80 percent of it.** The autoscaler then fires only at 100 percent utilization and never scales ahead of throttling. Self-audit that `averageValue < limit` for both CPU and memory.
- **Confusing a chart's `targetCpu` percentage with an absolute `averageValue`.** A chart key such as `autoscaling.targetCPU: 300` means 300 percent of `requests.cpu`, which is meaningless against a 10m request. Convert through the percentage formula instead of copying an absolute value into it.
- **Leaving the factor out.** A literal `targetCPU: 80` is 80 percent of requests, so with a 10m request it fires at 8m and never on real load. Always re-derive from the new limit.
