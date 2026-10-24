# Structure Autoscaling: kilic

Where VPA, goldilocks, HPAs and KEDA live in the estate, so a sizing or scaling question routes to the right repository. To size a workload, load `grafana-kilic-rightsize`; the metrics and alerts are in `kilic-autoscaling-metrics`.

## The model

- **VPA moves requests only** (`controlledValues: RequestsOnly`) inside each container's `minAllowed`/`maxAllowed` band. Limits are authored in the manifest and never moved by VPA.
- **HPAs stay**, at a fixed `AverageValue`, on workload and system charts alike.
- **KEDA is used only where a native HPA cannot express the signal**: the Argo CD repo-server queue, Envoy Gateway request bursts, and the kagent WorkerPool. Everything else stays on its HPA.

Decision record: [VPA right-sizing and KEDA scaling: decisions](https://linear.app/kilic-dev/document/vpa-right-sizing-and-keda-scaling-decisions-07124f2ad3b8), D16 and D5.

## Who owns what

| Piece | Repository | Notes |
|---|---|---|
| VPA operator (recommender, updater, admission controller) | [`chart-vpa`](https://gitlab.kilic.dev/cluster/charts/chart-vpa) | Namespace `monitoring-system`, ApplicationSet `base/vpa/` in `argocd-system`, cluster label `system.feature.kilic.dev/vpa`. Recommender percentiles, floors and the `InPlace` feature gates are its `values.yaml`. |
| VPA recommendation metrics | [`chart-vpa`](https://gitlab.kilic.dev/cluster/charts/chart-vpa) | Its own kube-state-metrics; the custom-resource-state config `files/kube-state-metrics.yaml` exports target, bounds and `update_mode`. |
| goldilocks controller | [`chart-goldilocks`](https://gitlab.kilic.dev/cluster/charts/chart-goldilocks) | ApplicationSet `base/goldilocks/` in `argocd-system`, cluster label `system.feature.kilic.dev/goldilocks`. Renders one VPA per workload in every namespace labelled `goldilocks.fairwinds.com/enabled`. |
| A workload's VPA policy | the workload's own repository or chart | Annotations on the Deployment (or the chart value that renders them): `goldilocks.fairwinds.com/vpa-update-mode` and `goldilocks.fairwinds.com/vpa-resource-policy`. System charts carry the same annotations in their `values.yaml`. |
| KEDA | [`chart-keda`](https://gitlab.kilic.dev/cluster/charts/chart-keda) | All six clusters, namespace `keda-system`, ApplicationSet `base/keda/` in `argocd-system`, cluster label `system.feature.kilic.dev/keda`. |
| A ScaledObject | the repository of the workload it scales | Beside the Deployment it targets. |
| Autoscaling alerts | [`monitoring-ruler`](https://gitlab.kilic.dev/cluster/workloads/monitoring-ruler) | `.deploy/base/alerts/kubernetes/vpa.yaml`, `vpa-resizing.yaml`, `keda.yaml`. |
| Autoscaling dashboards | [`monitoring-view`](https://gitlab.kilic.dev/cluster/workloads/monitoring-view) | `.deploy/rubik/dashboards/kubernetes/autoscaling-*`. |

## ScaledObject mechanics

- **A ScaledObject creates and owns an HPA named `keda-hpa-<name>`.** An HPA and a ScaledObject never share a target: replacing one with the other removes the HPA in the same change that adds the ScaledObject.
- **`spec.replicas` leaves the manifest** whenever a ScaledObject exists, or ArgoCD and KEDA fight over the replica count.
- **A Prometheus trigger reaches Mimir through that cluster's own `mimir-proxy-nginx`**, at `http://mimir-proxy-nginx.monitoring.svc:8080/prometheus`, deployed by [`monitoring`](https://gitlab.kilic.dev/cluster/workloads/monitoring) under `.deploy/base/mimir-proxy/`. The proxy is **cluster-scoped**: it answers from its own cluster's tenant and never returns another cluster's data, so a trigger query needs no `cluster` matcher and cannot see a sibling cluster.
- **The proxy is a single path.** Every Prometheus trigger in a cluster depends on its `mimir-proxy-nginx` being up; when it is not, the scaler errors and the ScaledObject drops to its `fallback` replicas where one is set.

## The HTML canary is not the pattern

[`html-cv3`](https://gitlab.kilic.dev/cluster/workloads/html-cv3), [`html-listr2`](https://gitlab.kilic.dev/cluster/workloads/html-listr2) and [`html-nurankilic`](https://gitlab.kilic.dev/cluster/workloads/html-nurankilic) on rubik are a deliberate canary. They run `controlledValues: RequestsAndLimits` and a ScaledObject on CPU usage divided by the limit — a shape the estate does not use anywhere else. Never copy them as the template for a VPA policy or a ScaledObject.
