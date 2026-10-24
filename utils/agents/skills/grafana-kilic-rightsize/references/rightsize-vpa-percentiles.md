# Rightsize VPA Percentiles

The VPA recommender's `extraArgs` in `chart-vpa`'s `values.yaml` decide what VPA writes into a request. The flags are global: one change moves every VPA-managed request on every cluster the chart version reaches.

## Percentile config

```yaml
recommender:
  extraArgs:
    memory-aggregation-interval: "1h"
    memory-aggregation-interval-count: "168"
    recommendation-lower-bound-cpu-percentile: "0.5"
    recommendation-lower-bound-memory-percentile: "0.3"
    target-cpu-percentile: "0.9"
    target-memory-percentile: "0.5"
    recommendation-upper-bound-cpu-percentile: "0.95"
    recommendation-upper-bound-memory-percentile: "0.9"
    recommendation-margin-fraction: "0"
    pod-recommendation-min-cpu-millicores: "10"
    pod-recommendation-min-memory-mb: "32"
```

## Why each value

| Argument | Value | Reason |
|---|---|---|
| `target-cpu-percentile` | 0.9 | CPU requests are cheap and CPU throttling is governed by the limit, so the request may sit near typical peak load. |
| `target-memory-percentile` | 0.5 | A request is a scheduling claim and stays near typical use. The burst ceiling is the authored limit, which VPA never moves. |
| `recommendation-margin-fraction` | 0 | No margin on top of the percentile; headroom lives in the band and the limit, not in every request. |
| `memory-aggregation-interval` | 1h, 168 intervals | Seven days of hourly peaks, so p50 tracks typical use rather than the median daily peak (next section). |
| lower and upper bounds | 0.5 / 0.3 and 0.95 / 0.9 | The band the outlier dashboard and the `VPARequests*` alerts measure a live request against. |
| `pod-recommendation-min-*` | 10m CPU, 32 MB memory | Per-pod floors; no recommendation goes below them. |

The in-place feature gate, `feature-gates: InPlace=true`, is set on the updater and the admission controller in the same file.

## Rules

1. **The target MUST be strictly below the upper bound.** Setting both to the same percentile collapses the band and leaves the outlier alerts nothing to measure.
2. **The recommender serves requests only.** `controlledValues: RequestsOnly` is the estate's policy, so no percentile here sizes a limit.
3. **Change the flags in `chart-vpa`, never per cluster.** A per-cluster annotation block carrying the same arguments diverges silently from the chart.

## Memory percentiles and the aggregation interval

The recommender's memory histogram holds one sample per aggregation interval: the PEAK within that interval. At the 24h upstream default, p50 is the median daily peak, not median usage. Measured 2026-10-16 against time-weighted averages:

| Workload | Time-weighted avg | p50 of daily peaks (24h) | p50 at 1h interval |
|---|---|---|---|
| ollama | 754Mi | 2110Mi | 629Mi |
| speaches | 2784Mi | 4477Mi | 2994Mi |

That is why `chart-vpa` sets the interval to 1h. CPU is unaffected.

## Estate config

Each cluster runs the `chart-vpa` version its Kargo stage has promoted, so a cluster can lag the chart's `values.yaml`. Read the deployed `vpa-recommender` args (namespace `monitoring-system`) before reading a Target or bound from that cluster against this file.

## What VPA produces

VPA computes a LowerBound, a Target and an UpperBound per container. With `RequestsOnly`, the Target is what the updater writes into the request, clamped to the container's `minAllowed`/`maxAllowed`. LowerBound and UpperBound are the band a live request is judged against: below LowerBound means a grow is not landing, above UpperBound means capacity reserved and unused. The metric families and the alerts built on them: `kilic-autoscaling-metrics`.

## Pitfalls

- **Reading a Target as a limit.** VPA never sets a limit here; the limit is authored, per `rightsize-signals`.
- **Raising the memory target to buy headroom.** It raises every request fleet-wide; headroom belongs in the band and the limit.
- **Per-cluster annotation overrides shadowing the chart values.** The arguments belong in one place.
