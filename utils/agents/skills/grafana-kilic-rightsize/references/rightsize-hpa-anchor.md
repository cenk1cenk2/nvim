# Rightsize HPA Anchor

HPAs stay, on workload and system charts alike, and target a **fixed `AverageValue`**. VPA moves `requests`, so anything expressed as a percentage of the request drifts every time VPA resizes.

## Before any request change

Read every HPA targeting the workload, and every chart-native autoscaling key, before a request moves. A Utilization target — `averageUtilization`, or a chart's `targetCPU` / `targetMemory` — divides live usage by the request, so the request is the HPA's denominator:

- **A request cut multiplies the utilization the HPA sees.** With zitadel's `targetCPU: 300`, a CPU request cut from 150m to 10m makes it scale out at 30m of usage instead of 450m. envoy-gateway's Utilization HPA pins scale-out the same way once its request shrinks.
- **A VPA-managed request makes a Utilization target meaningless**, because the denominator moves on its own. Convert it to a fixed `AverageValue` in the same change that puts the workload under VPA.
- **Hold the request** on a Utilization-anchored workload that stays on static sizing, unless the same change converts the HPA.

## Fixed AverageValue

```yaml
- type: Resource
  resource:
    name: cpu
    target:
      type: AverageValue
      averageValue: 200m
```

- **The value is the per-pod load at which the workload should scale out**, read from its measured per-pod usage, and justified in the merge request. The decision record prescribes no formula; a target derived from the limit is not part of the method.
- **It MUST be strictly below the limit.** At or above the limit the pod throttles or is killed before the autoscaler ever fires.
- **It does not follow the request.** A later VPA resize leaves it alone; revisit it only when the workload's load profile changes.

## Percentage form

When the chart only offers `target.averageUtilization`, or a chart-native `targetCpu` / `targetMemory` integer, both are percentages of requests. On a VPA-managed workload that is a drifting target; prefer a chart key or an override that renders `AverageValue`, and say in the change description when the chart cannot express one.

## Replica bounds are not sizing knobs

`minReplicas` stays at 1 or above: dropping it to 0 lets the pod count reach zero and kills in-flight requests on the next scale-up. `maxReplicas` is a safety net and is not derived from resources.

A workload with more than one HPA sets the value per HPA, since each targets its own Deployment with its own load.

## Pitfalls

- **`averageValue` at or above the limit.** The autoscaler fires only after the pod saturates. Self-audit that `averageValue < limit` for both CPU and memory.
- **Confusing a chart's `targetCpu` percentage with an absolute `averageValue`.** A chart key such as `autoscaling.targetCPU: 300` means 300 percent of `requests.cpu`, which is meaningless against a 10m request.
- **A literal `targetCPU: 80` on a VPA-managed workload.** It is 80 percent of whatever request VPA last wrote, so the scale-out point moves with every resize.
