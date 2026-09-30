# Kargo Pins: kilic

Where each repository kind keeps its version pins, the pin shape for workloads repositories that inflate Helm charts from files, and how a repository moves between Renovate and Kargo.

**Rule for every kind:** version decisions never live in `base`. Each resource gets exactly one override patch per cluster (per env for chart repositories), and that patch is the file Kargo writes.

## Chart Repositories

The pin is the ApplicationSet `targetRevision` in [argocd-system](https://gitlab.kilic.dev/cluster/argocd-system) `<env>/<component>/patch-applicationset.yaml`, a strategic merge patch naming only the pin:

```yaml
spec:
  template:
    spec:
      sources:
        - repoURL: git@gitlab.kilic.dev:cluster/charts/chart-<component>.git
          targetRevision: v1.0.0
```

`promote-pin` defaults point here, so argocd-system Stages omit `pin_file` and their Warehouses the `kargo.kilic.dev/pin-key` annotation. The sync `repoURL` the task derives from the subscription (SSH form, ending `.git`) must equal that `repoURL` exactly; a Stage whose ApplicationSet source differs sets `argocd_repo`.

## Workloads Repositories

Pins live in the workloads repository's per-cluster overlay, `.deploy/<cluster>/`. The Stage names the file in `pin_file`; the Warehouse names the key in its `kargo.kilic.dev/pin-key` annotation. Two shapes exist.

### Inline `helmCharts:` in a kustomization

`monitoring-backbone` pins each chart inline in the component's cluster kustomization:

| Artifact | `pin_file` | `pin-key` |
|---|---|---|
| chart `mimir-distributed` | `.deploy/rubik/mimir/kustomization.yaml` | `helmCharts.0.version` |
| chart `loki` | `.deploy/rubik/loki/kustomization.yaml` | `helmCharts.0.version` |
| image `opentelemetry-collector-contrib` | `.deploy/rubik/opentelemetry-ingester/opentelemetry-collector.yaml` | `spec.image` |

### File-based generator pins (worked example: `monitoring`)

[monitoring](https://gitlab.kilic.dev/cluster/workloads/monitoring) runs on six clusters and keeps `base` unversioned. Every chart and image is pinned per cluster in that component's own cluster folder:

| Artifact | Base (unversioned) | `pin_file` | `pin-key` |
|---|---|---|---|
| grafana-alloy chart | `base/grafana-alloy/helmchart.yaml` | `.deploy/<cluster>/grafana-alloy/helmchart/patch-helmchart.yaml` | `version` |
| blackbox-exporter chart | `base/blackbox-exporter/helmchart.yaml` | `.deploy/<cluster>/blackbox-exporter/patch-helmchart.yaml` | `version` |
| OpenTelemetry Collector image | untagged `spec.image` in `base/opentelemetry-collector/*/opentelemetry-collector.yaml` | `.deploy/<cluster>/opentelemetry-collector/patch-opentelemetry-collector.yaml` | `spec.image` (full tagged image) |

How the shape works:

- **A patch never reaches a generator config listed in the same kustomization** (`no matches for Id HelmChartInflationGenerator...`). The pin is therefore applied in a generator-config kustomization that lists the base `helmchart.yaml` under `resources:` and `patch-helmchart.yaml` under `patches:`, and a parent kustomization runs that folder through `generators:`.
- **Patches on the generator's inflated output do work beside the generator**, since generators run before patches. `<cluster>/grafana-alloy/` lists the Alloy RBAC under `resources:`, runs `./helmchart/` under `generators:`, and patches the inflated Deployment with `jsonpatch-alloy.yaml` (`CLUSTER_NAME`). That output patch is why Alloy's pin sits one folder deeper.
- `<cluster>/blackbox-exporter/` has no output patch, so it is itself the generator config and the cluster root runs it under `generators:`.
- `patch-helmchart.yaml` is the one override per chart per cluster: it sets `version` and lists the values under `additionalValuesFiles`, starting with the base `values.yaml`. Those paths resolve relative to the kustomization that runs the generator, not the patch file.
- The collector image is pinned by a strategic patch carrying the full `spec.image`, targeting every `OpenTelemetryCollector` by group, version and kind, so one patch covers both the logs and the metrics collector.

The collector Stages keep the default `pin_format: repo-tag`.

## Renovate and Kargo

A pin has one writer. Adopting Kargo for a dependency and handing it back to Renovate are both edits to that repository's `renovate.json`, landed with the Kargo change.

### Moving a dependency to Kargo

- **Workloads repositories:** replace the dependency's automerge presets with the scoped disable preset from `renovate/renovate-config`:
  - `manager-kustomize-automerge-minor(<chart>)` and `manager-kustomize-automerge-major(<chart>)` become `manager-kustomize-disable(<chart>)`.
  - `datasource-docker-automerge-minor(<image>)` becomes `datasource-docker-disable(<image>)`.
  - Prior art: monitoring-backbone `4e1aa5e` (`manager-kustomize-disable(mimir-distributed)`, `manager-kustomize-disable(loki)`, `datasource-docker-disable(ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib)`).
- **argocd-system:** its `argocd` manager is narrowed with `managerFilePatterns` to the patch files Kargo does not own (`platform/argo-rollouts` and `platform/kargo`), so Renovate no longer reads Kargo-managed `targetRevision` pins.

### Handing a dependency back to Renovate

1. Restore the automerge presets in place of the disable presets (or widen the `argocd` manager pattern again).
2. Disable the Kargo Stages first (drop `kargo.kilic.dev/auto: "true"` so the ProjectConfig policy stops auto-promoting), then remove the component's Warehouse and Stages from the repository's `.promote/` and the Stage names from the Application's `kargo.akuity.io/authorized-stage`. When that empties the Project, also remove its registry folder from `kargo-root`; the generated Application stays behind and is deleted by hand.
3. Make sure Renovate can read the pin.

**Renovate's `kustomize` manager reads only `kustomization.yaml` files** (default `managerFilePatterns` `/(^|/)kustomization\.ya?ml$/`), and within them only inline `helmCharts`, `images`, remote resources and components. A version in a `patch-helmchart.yaml` generator patch, or a `spec.image` in a collector patch, is invisible to it: the automerge presets match nothing and the version silently stops moving. A repository on the file-based pin shape that goes back to Renovate needs a `customManagers` regex entry whose `matchStrings` capture the line under a directive comment:

```yaml
# renovate: datasource=helm depName=alloy registryUrl=https://grafana.github.io/helm-charts
version: 1.13.0
```

argocd-system's existing regex manager matches a `value:` line after the directive, so a `version:` pin needs its own `matchStrings` rather than a copy of that entry.
