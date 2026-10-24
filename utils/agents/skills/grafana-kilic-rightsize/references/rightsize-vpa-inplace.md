# Rightsize VPA In-Place

How in-place VPA resize and goldilocks-generated VPAs behave in this estate: VPA 1.8.1 from `chart-vpa`, goldilocks 4.16.2 from `chart-goldilocks`, Kubernetes 1.36. VPA applies the request band; the measured figures behind the band come from `rightsize-signals`. Recommender percentiles: `rightsize-vpa-percentiles`.

## In-place resize semantics

| Fact | Detail |
|---|---|
| Kubernetes | `InPlacePodVerticalScaling` is GA from 1.35, always on, no feature gate. |
| VPA update modes | `Auto`, `Off`, `Initial`, `InPlaceOrRecreate`. `InPlaceOrRecreate` is GA since VPA 1.6 (alpha 1.4, beta 1.5). |
| Never-evict mode | `InPlace` is alpha, behind `--feature-gates=InPlace` on the updater AND the admission controller; `chart-vpa` sets both. It is the estate's mode: a resize never restarts the pod. |
| Updater flags that matter | `--in-place-skip-disruption-budget=true` (deployed in this estate); `--min-replicas` defaults to 2, changed per workload with the goldilocks `vpa-min-replicas` annotation. |
| Container `resizePolicy` | A Deployment field, Kubernetes default `NotRequired`. goldilocks only writes VPAs and never sets it. The in-place path holds only while it stays `NotRequired`; a chart that sets `RestartContainer` turns every resize into a restart. |
| Shrinking a request | Always feasible in place. |
| Growing a request | Can be deferred or infeasible under node pressure. Under `InPlace` the resize stays pending on the node (`KubeletPodResizePending`); under `InPlaceOrRecreate` it falls back to eviction, and evicting a model-loading workload (GPU or not) unloads what it held. |

### controlledValues

| Value | Behaviour | Use |
|---|---|---|
| `RequestsOnly` | VPA resizes requests; limits stay authored in the manifest. | **The estate's policy, on every VPA outside the HTML canary.** A tight `maxAllowed` cannot cause an OOM, because the limit does not move. |
| `RequestsAndLimits` | VPA scales limits by the manifest's request:limit ratio on every resize. | Only the HTML canary runs it, deliberately; it is not a pattern to copy. |

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

The band as a policy, with `maxAllowed` at or below the container's authored limit and `requests = minAllowed` seeded in the manifest:

```yaml
goldilocks.fairwinds.com/vpa-update-mode: InPlace
goldilocks.fairwinds.com/vpa-resource-policy: |
  {
    "containerPolicies": [
      {
        "containerName": "<container>",
        "mode": "Auto",
        "controlledResources": ["cpu", "memory"],
        "controlledValues": "RequestsOnly",
        "minAllowed": { "cpu": "<min cpu>", "memory": "<min memory>" },
        "maxAllowed": { "cpu": "<max cpu>", "memory": "<max memory>" }
      }
    ]
  }
```

A workload whose fixed request is deliberate keeps a VPA in `Off` mode for visibility; the `VPARequests*` alerts exclude it by `update_mode`.

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

## Pitfalls

- **`RequestsAndLimits` anywhere.** Limits move with every resize; the estate authors limits in the manifest.
- **`maxAllowed` above the authored limit.** A request may never exceed its limit, so the resize produces an invalid pod.
- **Copying the HTML canary.** Its `RequestsAndLimits` policy and limit-relative ScaledObject are deliberate exceptions.
- **A standalone VPA next to a goldilocks one.** The older object wins; the newer one never acts.
- **Trusting an annotation edit.** A misspelled key is dropped without error; the live VPA is the only proof.
- **Adding `evictionRequirements` to gate disruption.** It also blocks live shrinking.
