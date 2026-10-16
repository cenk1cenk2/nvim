# Rightsize VPA Percentiles

The VPA recommender's `extraArgs` percentiles have to produce recommendations consistent with the sizing method in `rightsize-signals`. Misaligned percentiles make VPA suggest limits that are either too tight or too loose to be usable as a signal.

## Percentile config

```yaml
recommender:
  extraArgs:
    recommendation-lower-bound-cpu-percentile: "0.5"
    recommendation-lower-bound-memory-percentile: "0.5"
    target-cpu-percentile: "0.95"
    target-memory-percentile: "0.99"
    recommendation-upper-bound-cpu-percentile: "0.99"
    recommendation-upper-bound-memory-percentile: "0.99"
```

## Why each value

| Argument | Value | Maps to | Reason |
|---|---|---|---|
| `lower-bound-cpu-percentile` | 0.5 | average usage | Requests are cheap, and the median approximates the average. |
| `lower-bound-memory-percentile` | 0.5 | average usage | Same, and it is the request floor. |
| `target-cpu-percentile` | 0.95 | the CPU limit | Opens the case for a limit change; the committed limit is the 7d max per `rightsize-signals`, and a p95 sitting below a throttled container's limit is a sampling artifact, not a reason to cut. |
| `target-memory-percentile` | 0.99 | the memory limit | The memory limit is the 7d max on the grid with no multiplier, and p99 is the closest percentile to that max. |
| `upper-bound-cpu-percentile` | 0.99 | ceiling | A 0.95 target against a 0.99 ceiling leaves a real band. |
| `upper-bound-memory-percentile` | 0.99 | ceiling | Memory needs no separate band: the target already sits at the percentile nearest the max the limit is set from. |

## Rules

1. **The target MUST be strictly below the upper bound.** Setting both to the same percentile collapses the band to zero and leaves VPA no room to recommend anything meaningful.
2. **Memory targets sit higher than CPU targets.** CPU is elastic and p95 is enough; memory is inelastic, because once allocated it stays, so it targets p99.
3. **Lower bounds stay at 0.5.** Requests track average usage, and raising these makes VPA recommend inflated requests.
4. **Reconcile against the sizing rules before every VPA config change.** The percentiles exist to mirror the method; when the method moves, they follow.

## What VPA produces

VPA computes a LowerBound, a Target and an UpperBound per container. Configured as above, LowerBound approximates average usage and points at `resources.requests`, Target approximates p95 or p99 and points at `resources.limits`, and UpperBound is a safety ceiling that is rarely reached. All three open a case; the committed values come from the queries in `rightsize-signals`, because VPA's decayed per-container history cannot tell a churned pod's spike from a steady working set.

## Pitfalls

- **Using the CPU percentile for memory.** Target p99 for memory; p95 under-sizes an inelastic resource.
- **Committing VPA's Target as the limit.** The limit is the smallest grid stop at or above the 7d max, with no multiplier; Target is the signal that a limit is worth revisiting, and the max decides the value.
- **Per-cluster annotation overrides shadowing the chart values.** The VPA arguments belong in one place. Any per-cluster annotation block that also sets them diverges silently, so the chart values and the cluster annotations must not both carry them.
