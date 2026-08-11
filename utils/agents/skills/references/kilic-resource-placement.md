# Kilic Resource Placement

Where a container's `resources` block actually lives, once `kilic-workload-resolution` has told you which repository owns the workload. Two groups, two entirely different ladders. Applying a correct value at the wrong layer either reaches every cluster when it should have reached one, or is silently overridden by a layer above it.

## System components — `cluster/charts/chart-*`

Deployed by `argocd-system` through an ApplicationSet per component. Values are layered, lowest precedence first:

```
chart-<c>/values.yaml                            fleet-wide default
  < argocd-system/base/<c>/values.yaml           fleet-wide
    < argocd-system/<env>/<c>/values.yaml        per environment
      < inline document 1 in the applicationset  templated identity only
        < cluster annotation                     per cluster, highest
```

Environments are `development`, `platform`, `production`, `load-balancer`.

**The top layer is not a git edit.** `values.system.feature.kilic.dev/<component>` annotations reach the cluster secret from **Vault** at `overseer/argocd/clusters/<cluster>`, surfaced by an ExternalSecret in `argocd-root`. A per-cluster override for a system component is therefore a Vault write. Say so out loud rather than pushing the change down to a lower layer where it would reach clusters that did not ask for it.

**Inline document 1 is reserved.** It carries `{{...}}`-templated identity only — secret key paths, `txtOwnerId`, per-cluster hostnames. Static values never belong there.

Helm 4 merge semantics, which decide whether an edit lands:

- Maps deep-merge at any depth.
- **Lists replace wholesale**, never merge. Re-state the whole list or lose entries.
- `key: null` does **not** suppress a subchart default. Set the value explicitly.

## Workloads — `cluster/workloads/*`

Kustomize, no values ladder:

```
.deploy/base/<component>/        only when the workload spans clusters
  .deploy/<cluster>/<component>/
```

A single-cluster workload has no `base/` and should not gain one for a single change — that is indirection with nothing on the other side. A workload that already spans clusters keeps identical configuration in `base/` and only genuine differences in each `.deploy/<cluster>/`.

## Choosing the layer

1. **Establish the spread** — how many clusters run this application.
2. **Same change in the same direction everywhere** → the common layer. `chart-*/values.yaml` for a system component, `.deploy/base/` for a workload.
3. **One or two clusters differ** → leave the common layer and override: `argocd-system/<env>/<c>/values.yaml`, the Vault-backed cluster annotation, or `.deploy/<cluster>/`.
4. **Single-cluster application** → its only layer. No override question exists.

Cover the common case in the common layer and treat the rest as overrides. An override that duplicates the common value is drift waiting to happen.

## Traps

- **Vendored chart copies are not edit targets.** Workloads carry upstream chart trees at `.deploy/<cluster>/<component>/charts/<chart>-<version>/`. They contain `resources:` blocks that look editable and are regenerated on every dependency update.
- **`resources:` in a `kustomization.yaml` is a file list**, not container sizing. A naive search for resource blocks returns mostly these.
- **Empty values are not always inert.** An empty map can be load-bearing: `nfs: {}` meaning "match any NFS volume" changes behavior if removed, while `nodeSelector: {}` does not. Before touching one, check whether the chart template guards it and whether an earlier layer already supplies it.
- **A chart change ships on a version.** Charts release by semantic-release and are pinned per environment via `targetRevision` in `<env>/<component>/patch-applicationset.yaml`. Editing `chart-*/values.yaml` changes nothing until the chart is released and the pin moves.
