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
| `lower-bound-cpu-percentile` | 0.5 | average usage | CPU percentiles are taken over usage samples, so the median approximates the average. |
| `lower-bound-memory-percentile` | 0.5 | average usage only at a 1h aggregation interval | Memory percentiles are taken over per-interval peaks; see "Memory percentiles and the aggregation interval". |
| `target-cpu-percentile` | 0.95 | the CPU limit | Opens the case for a limit change; the committed limit is the 7d max per `rightsize-signals`, and a p95 sitting below a throttled container's limit is a sampling artifact, not a reason to cut. |
| `target-memory-percentile` | 0.99 | the memory limit | The memory limit is the 7d max on the grid with no multiplier, and p99 is the closest percentile to that max. |
| `upper-bound-cpu-percentile` | 0.99 | ceiling | A 0.95 target against a 0.99 ceiling leaves a real band. |
| `upper-bound-memory-percentile` | 0.99 | ceiling | Memory needs no separate band: the target already sits at the percentile nearest the max the limit is set from. |

## Rules

1. **The target MUST be strictly below the upper bound.** Setting both to the same percentile collapses the band to zero and leaves VPA no room to recommend anything meaningful.
2. **Memory targets sit higher than CPU targets.** CPU is elastic and p95 is enough; memory is inelastic, because once allocated it stays, so it targets p99.
3. **Lower bounds stay at 0.5.** For CPU the median approximates average usage. For memory it does not by default: the percentiles are taken over per-interval peaks, so the interval decides (next section). Raising either bound makes VPA recommend inflated requests.
4. **Reconcile against the sizing rules before every VPA config change.** The percentiles exist to mirror the method; when the method moves, they follow.

## Memory percentiles and the aggregation interval

The recommender's memory histogram holds one sample per aggregation interval: the PEAK within that interval. The default `memory-aggregation-interval` is 24h, so p50 is the median daily peak, not median usage. Measured 2026-10-16 against time-weighted averages:

| Workload | Time-weighted avg | p50 of daily peaks (24h) | p50 at 1h interval |
|---|---|---|---|
| ollama | 754Mi | 2110Mi | 629Mi |
| speaches | 2784Mi | 4477Mi | 2994Mi |

`memory-aggregation-interval` is a recommender flag, or a `PerVPAConfig` field (alpha). A 1h interval makes p50 track the time-weighted average; at the 24h default, lower-bound memory 0.5 is an inflated request signal and must not be read as the average. CPU is unaffected.

## Estate config

Observed 2026-10-16 from the deployed `vpa-recommender` deployments (`monitoring-system`, image `vpa-recommender:1.8.0`, chart `vpa-5.1.0`). The `chart-vpa` default values match the ideal above; not every cluster runs them.

| Cluster | target-cpu | target-memory | upper-cpu | upper-memory | lower (cpu/mem) |
|---|---|---|---|---|---|
| nailbed | 0.95 | 0.99 | 0.99 | 0.99 | 0.5 / 0.5 |
| neutrino | 0.9 | 0.95 | 0.95 | 0.99 | 0.5 / 0.5 |
| overseer | 0.9 | 0.95 | 0.95 | 0.99 | 0.5 / 0.5 |
| rubik | 0.9 | 0.95 | 0.95 | 0.99 | 0.5 / 0.5 |
| moon, sun | no recommender found | | | | |
| rancher | not readable (RBAC denies the read) | | | | |

No `memory-aggregation-interval` is set on any readable cluster, so memory percentiles run at the 24h default. The origin of the neutrino, overseer and rubik overrides was not found in the indexed `chart-vpa` source. Reconciliation of these clusters against the ideal in this file (the requests-track-average method) is pending; until then, read a VPA Target or bound from those clusters against the args that cluster runs, not against this file's table.

## Bursty workloads

Auto mode writes Target into the request, which lands near peaks for bursty workloads and does not fit the tight time-weighted-average posture of `rightsize-signals`. The mechanism for request-oriented VPA sizing is a second recommender selected through `spec.recommenders` (verified on VPA 1.8.0), with its own percentiles and the interval caveat above. The house sizing method in `rightsize-signals` and `rightsize-bursty-list` stays the authority for committed values. In-place resize, goldilocks automation and the measured candidate sweep: `rightsize-vpa-inplace`.

## What VPA produces

VPA computes a LowerBound, a Target and an UpperBound per container. Configured as above, LowerBound approximates average usage (CPU, or memory at a 1h interval) and points at `resources.requests`, Target approximates p95 or p99 and points at `resources.limits`, and UpperBound is a safety ceiling that is rarely reached. All three open a case; the committed values come from the queries in `rightsize-signals`, because VPA's decayed per-container history cannot tell a churned pod's spike from a steady working set.

## Pitfalls

- **Using the CPU percentile for memory.** Target p99 for memory; p95 under-sizes an inelastic resource.
- **Committing VPA's Target as the limit.** The limit is the smallest grid stop at or above the 7d max, with no multiplier; Target is the signal that a limit is worth revisiting, and the max decides the value.
- **Per-cluster annotation overrides shadowing the chart values.** The VPA arguments belong in one place. Any per-cluster annotation block that also sets them diverges silently, so the chart values and the cluster annotations must not both carry them.
