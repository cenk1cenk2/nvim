# Kargo Pins: kilic

Where each repository kind keeps its version pins, how the Warehouse describes them, the pin shape for workloads repositories that inflate Helm charts from files, and how a repository moves between Renovate and Kargo.

**Rule for every kind:** version decisions never live in `base`. Each resource gets exactly one override patch per cluster (per environment for chart repositories), and that patch is the file Kargo writes.

## Warehouse Pins

The pin is described on the Warehouse, never in Stage vars. In `.promote/values.yaml` the top-level `repo` and each Warehouse's `pins` list carry it, and the chart writes them as the annotations `kargo.kilic.dev/pin-repo` and `kargo.kilic.dev/pins`:

- `repo`: the gitops repository's HTTPS URL ending `.git`.
- `pins`: one entry per pinned value. `file` (repo-relative, `{stage}` standing for the stage, the Stage name without the component prefix) and `key` (`yaml-update` dot-and-index form, `helmCharts.0.version`) are required; `value` is an optional template over `{version}`, `{tag}`, `{commit}`, `{digest}` and `{repo}`, default `{version}`, so charts and git tags omit it and an image that stores a full reference sets `"{repo}:{tag}"`.
- Every entry names the same `file` (the render fails otherwise), and the first is the primary pin (its current value is `From:`). Pins in two files take two Warehouses.

```yaml
---
warehouses:
  - name: <component>
    subscriptions:
      - git:
          repoURL: https://gitlab.kilic.dev/cluster/charts/chart-<component>.git
          commitSelectionStrategy: SemVer
          semverConstraint: "*"
    pins:
      - file: "{stage}/<component>/patch-applicationset.yaml"
        key: spec.template.spec.sources.0.targetRevision
```

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

The Warehouse's pin `file` is `{stage}/<component>/patch-applicationset.yaml` and its `key` `spec.template.spec.sources.0.targetRevision`. The sync `repoURL` the task derives from the subscription (SSH form, ending `.git`) must equal that `repoURL` exactly, so every ApplicationSet chart source ends in `.git`; no var overrides it.

### Chart component images

An image a chart component runs is pinned in a Helm values file of argocd-system, not in the ApplicationSet patch: `external-dns-webhook-opnsense` writes `external-dns.provider.webhook.image.tag` in `load-balancer/<component>/values.yaml` (a `pins` entry without `value`, so the tag is written). Its Warehouse is a second `warehouses` entry in the component's `.promote/<component>/values.yaml`, beside the chart Warehouse, and Renovate is disabled for the image.

## Workloads Repositories

Pins live in the workloads repository's per-cluster overlay, `.deploy/{stage}/`. The Warehouse's `pins` entry names the file (`.deploy/{stage}/...`, the stage being the cluster) and the key. Two shapes exist.

### Inline `helmCharts:` in a kustomization

`monitoring-backbone` pins each chart inline in the component's cluster kustomization:

| Artifact | `file` | `key` |
|---|---|---|
| chart `mimir-distributed` | `.deploy/{stage}/mimir/kustomization.yaml` | `helmCharts.0.version` |
| chart `loki` | `.deploy/{stage}/loki/kustomization.yaml` | `helmCharts.0.version` |
| image `opentelemetry-collector-contrib` | `.deploy/{stage}/opentelemetry-ingester/opentelemetry-collector.yaml` | `spec.image`, `value` `{repo}:{tag}` |

### File-based generator pins (worked example: `monitoring`)

[monitoring](https://gitlab.kilic.dev/cluster/workloads/monitoring) runs on six clusters and keeps `base` unversioned. Every chart and image is pinned per cluster in that component's own cluster folder:

| Artifact | Base (unversioned) | `file` | `key` |
|---|---|---|---|
| grafana-alloy chart | `base/grafana-alloy/helmchart.yaml` | `.deploy/{stage}/grafana-alloy/helmchart/patch-helmchart.yaml` | `version` |
| blackbox-exporter chart | `base/blackbox-exporter/helmchart.yaml` | `.deploy/{stage}/blackbox-exporter/patch-helmchart.yaml` | `version` |
| OpenTelemetry Collector image | untagged `spec.image` in `base/opentelemetry-collector/*/opentelemetry-collector.yaml` | `.deploy/{stage}/opentelemetry-collector/patch-opentelemetry-collector.yaml` | `spec.image` (full tagged image, `value` `{repo}:{tag}`) |

How the shape works:

- **A patch never reaches a generator config listed in the same kustomization** (`no matches for Id HelmChartInflationGenerator...`). The pin is therefore applied in a generator-config kustomization that lists the base `helmchart.yaml` under `resources:` and `patch-helmchart.yaml` under `patches:`, and a parent kustomization runs that folder through `generators:`.
- **Patches on the generator's inflated output do work beside the generator**, since generators run before patches. `<cluster>/grafana-alloy/` lists the Alloy RBAC under `resources:`, runs `./helmchart/` under `generators:`, and patches the inflated Deployment with `jsonpatch-alloy.yaml` (`CLUSTER_NAME`). That output patch is why Alloy's pin sits one folder deeper.
- `<cluster>/blackbox-exporter/` has no output patch, so it is itself the generator config and the cluster root runs it under `generators:`.
- `patch-helmchart.yaml` is the one override per chart per cluster: it sets `version` and lists the values under `additionalValuesFiles`, starting with the base `values.yaml`. Those paths resolve relative to the kustomization that runs the generator, not the patch file.
- The collector image is pinned by a strategic patch carrying the full `spec.image`, targeting every `OpenTelemetryCollector` by group, version and kind, so one patch covers both the logs and the metrics collector.

The collector pins write `{repo}:{tag}`.

### Floating-tag images

An image on a moving tag (`latest`, `stable`, `13.0-latest`), including long-running helpers such as init containers, sidecars and image volumes, is its own Warehouse with `imageSelectionStrategy: Digest`, the tag as `constraint`, and pin value `{repo}:{tag}@{digest}`. Helpers run `jobs: []` on their stage (no review and no report Stage); an image the estate builds itself (home-assistant's `config` image volume) keeps `report`. Outside Kargo stay only one-off Jobs (restores, migrations, a chart's setup Jobs), CloudNativePG `imageName`, the `renovate/renovate` image of the RenovateJob CRs, the `nginx:alpine` proxies in `monitoring/.deploy/base`, nailbed's demo nginx and gitlab-runner's runner `image.tag: alpine`; kargo-root `CLAUDE.md` keeps that list.

## Renovate and Kargo

A pin has one writer. Adopting Kargo for a dependency and handing it back to Renovate are both edits to that repository's `renovate.json`, landed with the Kargo change.

### Moving a dependency to Kargo

- **Workloads repositories:** replace the dependency's automerge presets with the scoped disable preset from `renovate/renovate-config`:
  - `manager-kustomize-automerge-minor(<chart>)` and `manager-kustomize-automerge-major(<chart>)` become `manager-kustomize-disable(<chart>)`.
  - `datasource-docker-automerge-minor(<image>)` becomes `datasource-docker-disable(<image>)`.
  - Prior art: monitoring-backbone `4e1aa5e` (`manager-kustomize-disable(mimir-distributed)`, `manager-kustomize-disable(loki)`, `datasource-docker-disable(ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib)`).
- **Any other artifact Kargo promotes** (an image in a chart values file): the matching `datasource-docker-disable(<image>)` preset.
- **argocd-system:** its `argocd` manager is narrowed with `managerFilePatterns` to the patch files Kargo does not own (`platform/argo-rollouts` and `platform/kargo`), so Renovate reads no Kargo-managed `targetRevision` pin.

### Handing a dependency back to Renovate

1. Restore the automerge presets in place of the disable presets (or widen the `argocd` manager pattern again).
2. Remove the component's `warehouses` entry from the repository's `.promote/values.yaml`, which drops its Warehouse and Stages on the next sync, and the Stage names from the Application's `kargo.akuity.io/authorized-stage`. When that empties the Project, also remove its registry folder from `kargo-root`: the ApplicationSet then deletes the generated Application and its objects, and confirming the `kargo-root` prune of the Project deletes its namespace.
3. Make sure Renovate can read the pin.

**Renovate's `kustomize` manager reads only `kustomization.yaml` files** (default `managerFilePatterns` `/(^|/)kustomization\.ya?ml$/`), and within them only inline `helmCharts`, `images`, remote resources and components. A version in a `patch-helmchart.yaml` generator patch, or a `spec.image` in a collector patch, is invisible to it: the automerge presets match nothing and the version silently stops moving. A repository on the file-based pin shape that goes back to Renovate needs a `customManagers` regex entry whose `matchStrings` capture the line under a directive comment:

```yaml
# renovate: datasource=helm depName=alloy registryUrl=https://grafana.github.io/helm-charts
version: 1.13.0
```

argocd-system's existing regex manager matches a `value:` line after the directive, so a `version:` pin needs its own `matchStrings` rather than a copy of that entry.
