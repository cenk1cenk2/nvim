# Rightsize VPA In-Place

How in-place VPA resize and goldilocks-generated VPAs behave in this estate, and what that means for automating requests. Measured and verified 2026-10-16 against VPA 1.8.0, Kubernetes 1.36 and goldilocks 4.16.2. The committed sizing values still come from `rightsize-signals`; this file covers the mechanism that could apply them. Recommender percentiles: `rightsize-vpa-percentiles`.

## In-place resize semantics

| Fact | Detail |
|---|---|
| Kubernetes | `InPlacePodVerticalScaling` is GA from 1.35, always on, no feature gate. |
| VPA update modes | `Auto`, `Off`, `Initial`, `InPlaceOrRecreate`. `InPlaceOrRecreate` is GA since VPA 1.6 (alpha 1.4, beta 1.5). |
| Never-evict mode | `InPlace` is alpha, behind `--feature-gates=InPlace` on the updater AND the admission controller. |
| Updater flags that matter | `--in-place-skip-disruption-budget=true` (deployed in this estate); `--min-replicas` defaults to 2, changed per workload with the goldilocks `vpa-min-replicas` annotation. |
| Container `resizePolicy` | A Deployment field, Kubernetes default `NotRequired`. goldilocks only writes VPAs and never sets it. The in-place path holds only while it stays `NotRequired`; a chart that sets `RestartContainer` turns every resize into a restart. |
| Shrinking a request | Always feasible in place. |
| Growing a request | Can be infeasible under node pressure and then falls back to eviction. Evicting a model-loading workload (GPU or not) unloads what it held, so such workloads are poor candidates. |

### controlledValues

| Value | Behaviour | Use |
|---|---|---|
| `RequestsOnly` | VPA resizes requests; limits stay static. | REQUIRED when limits are set deliberately outside VPA. A tight `maxAllowed` cannot cause an OOM, because the limit does not move. |
| `RequestsAndLimits` | VPA scales limits by the manifest's request:limit ratio on every resize. | Not here: a 10x ratio balloons the limit to the `maxAllowed` cap. |

### evictionRequirements

goldilocks does NOT carry `evictionRequirements`, and it would be wrong for this estate: `TargetHigherThanRequests` also blocks live shrinking, which is the whole point of the in-place path.

## goldilocks automation mechanics

goldilocks creates and manages one VPA per workload in every namespace carrying the `goldilocks.fairwinds.com/enabled` label (Pulumi-owned in the `cluster-<cluster>` repositories). The VPA mode comes from `goldilocks.fairwinds.com/vpa-update-mode`; absent it, the cluster default applies (Off, for the dashboard).

### Annotation surface

The full change-later contract, set per workload on the Deployment:

| Annotation (prefix `goldilocks.fairwinds.com/`) | Controls |
|---|---|
| `vpa-update-mode` | The VPA `updatePolicy.updateMode`. |
| `vpa-resource-policy` | Full `containerPolicies[]` JSON keyed by container name: `mode`, `controlledResources`, `controlledValues`, `minAllowed` / `maxAllowed`, OOM bump settings. |
| `vpa-min-replicas` | Updater minimum replicas for that workload. |
| `exclude-containers` | Dashboard only; does not touch the VPA. |

Proven bounds, the `html-*` setup: `minAllowed` 10m / 10Mi, `maxAllowed` 50m / 32Mi, from measured peaks, `controlledValues: RequestsOnly`.

### Truths from source

- **No per-workload opt-out.** The namespace label is the only switch.
- **The OLDEST VPA wins when two match one pod.** A standalone VPA beside a goldilocks one is silently inert.
- **Removing the namespace label DELETES every VPA goldilocks manages there.**
- **Misspelled annotation keys are dropped silently, with no error.** After every annotation edit, read the live VPA (`kubectl get vpa <name> -o yaml` through the cluster's usual read path): confirm the `RecommendationProvided` condition, the update mode, and the bounds.

### Playbooks

Add a workload:

1. Set the annotations on the Deployment.
2. Read the generated VPA: `RecommendationProvided`, mode, bounds.

Exit a whole namespace:

1. Remove the label in Pulumi.
2. Add explicit VPA CRs in the workload repositories for every workload that needs one, including `Off`-mode CRs for the siblings that should keep a recommendation.

## Candidates and evidence

Estate evidence, 2026-10-16.

**Proven:** `html-cv3`, `listr2` and `nurankilic` on rubik had requests AND limits resized live, without restarts, under `InPlaceOrRecreate`.

**Why the default recommender declines the bursty candidates.** In Auto mode VPA writes its Target into the REQUEST. The default recommender targets near-peak (p90 CPU, p95 memory, over daily peaks), which pins a bursty workload's request near its peak. That contradicts the estate's time-weighted-average posture for requests in `rightsize-signals`.

Measured candidate sweep, time-weighted method (memory):

| Workload | Time-weighted avg | 7d max |
|---|---|---|
| ollama | 754Mi | 8155Mi |
| speaches | 2781Mi | 4738Mi |
| nzbget | 13Mi | 728Mi |
| paperless | 859Mi | 1950Mi |
| immich | 452Mi | 833Mi |

**The fix: a second request-track recommender** through `spec.recommenders` (works in VPA 1.8.0, verified in source):

- `chart-vpa` needs a new template to deploy it.
- It needs `memory-aggregation-interval` at 1h. Memory percentiles aggregate per-interval peaks, so at the 24h default p50 is the median DAILY PEAK, not the average (`rightsize-vpa-percentiles`, "Memory percentiles and the aggregation interval").
- The candidates still need the whole-namespace exit above.

The merits landed within the materiality floors of the static sizes today. Revisit for workloads whose 7d average drifts more than 20% week over week.

## Estate config note

Deployed recommender args, observed 2026-10-16 (full table in `rightsize-vpa-percentiles`):

| Cluster | target cpu / mem | upper cpu / mem |
|---|---|---|
| nailbed | 0.95 / 0.99 | 0.99 / 0.99 |
| rubik, neutrino, overseer | 0.9 / 0.95 | 0.95 / 0.99 |

nailbed matches the reference; the divergence on the other three is untraced and reconciliation is pending. No cluster sets `memory-aggregation-interval`, so all run the 24h default. Re-read the deployed args before relying on this table.

## Pitfalls

- **`RequestsAndLimits` on a workload with deliberate limits.** Limits ratchet up with every resize.
- **A standalone VPA next to a goldilocks one.** The older object wins; the newer one never acts.
- **Trusting an annotation edit.** A misspelled key is dropped without error; the live VPA is the only proof.
- **Adding `evictionRequirements` to gate disruption.** It also blocks live shrinking.
- **Auto mode on a bursty workload with the default recommender.** The request lands near peak.
