# Kargo Stage Wiring: kilic

The vars and annotations that connect a Stage to its Freight, its pin and its Application. Task internals and v1.11.4 quirks stay in [kargo-root](https://gitlab.kilic.dev/cluster/kargo-root) `CLAUDE.md`.

## Layout in kargo-root

- `.deploy/overseer/promotions/`: ClusterPromotionTasks `promote-pin` and `report-pin`, ClusterAnalysisTemplate `report-verdict`.
- Per component Project: `.deploy/overseer/projects/<repo>/<component>/` with `namespace.yaml`, `project.yaml`, `projectconfig.yaml`, `warehouse.yaml` and `stages/<env>.yaml` plus `stages/<env>.report.yaml`.
- Per repository Project: `.deploy/overseer/projects/<repo>/` with `warehouse-<name>.yaml` per Warehouse and `stages/<cluster>.<component>.yaml` plus `.report.yaml`, full names, no `namePrefix`.
- The Namespace carries `kargo.akuity.io/project: "true"`, sync-wave `-2` and `Delete=confirm,Prune=confirm`; the Project sync-wave `-1` and `kargo.akuity.io/description`.
- Every Stage carries labels `kargo.kilic.dev/auto: "true"` (selected by the ProjectConfig auto-promotion policy) and `kargo.kilic.dev/role` (`deploy` or `report`), and annotation `kargo.akuity.io/color` (development `green`, production `yellow`, load-balancer `amber`, platform `red`, every report `gray`).

## Stage Vars

Deploy Stages call `promote-pin`, report Stages `report-pin`, both `kind: ClusterPromotionTask`. Always passed: `component`, `env`, `gitops_repo` (HTTPS); `promote-pin` also takes `source_repo` and `argocd_repo`. Downstream deploy Stages add `report_previous` (full upstream report Stage name).

### Source: `source_kind`

| `source_kind` | Warehouse subscription | Pin value written | Sync without `argocd_apps` |
|---|---|---|---|
| `git` (default) | `git` | the tag, or the full commit ID for branch-tracking Freight | `sync_revision` to the commit |
| `chart` | `chart` | the chart version | `sync_chart` (Helm `chart` source), or `sync_revision` for an `oci://` `argocd_repo` |
| `image` | `image` | per `pin_format` (`repo-tag` default, `tag`, `repo-digest`, `digest`) | rejected: needs `argocd_apps` |
| `artifact` | generic subscription | the artifact version | rejected; unreachable on v1.11.4 OSS, which registers only the git, image and chart subscribers |

- `chart` and `image` Stages set `source_name` (chart name, or the image's short name) and may set `source_release_url`.
- `source_repo` (and `source_name` for a Helm-repository chart) must equal the Warehouse subscription `repoURL` (and `name`), or `source_artifact` fails the Promotion. An `oci://` chart subscription leaves `name` empty.
- An image Warehouse with `imageSelectionStrategy: Digest` needs `pin_format` `repo-digest` or `digest`, or every promotion writes the same tag.
- `source_origin` names the Warehouse when a Stage requests Freight from several that could each provide the artifact.

### Pin: `pin_file`, `pin_key`, `pin_path`

Set all three together, or none:

- `pin_file`: repo-relative path in the gitops repository. The default `none` means `<env>/<component>/patch-applicationset.yaml`.
- `pin_key`: the `yaml-update` key, dot-and-index form (`helmCharts.0.version`).
- `pin_path`: the `yaml-parse` expr form of the same key (`helmCharts[0].version`).

The task never converts between the two key forms, so both are written literally. Defaults are the ApplicationSet `spec.template.spec.sources.0.targetRevision` / `spec.template.spec.sources[0].targetRevision`. Pin locations per repository kind: `kargo-kilic-pins`.

### Sync: `argocd_apps`

- Unset (chart repositories): a selector step pins every Application labelled `system.kilic.dev/component` and `cluster.kilic.dev/environment` to the promoted revision.
- Set (workloads repositories): `"${{ ['<cluster>-<repo>'] }}"`, an expr list literal of exactly one name, never a bare JSON or comma string. `sync_app` syncs that Application's `HEAD` after `pin_mr_merge` put the pin on `main`.
- Sync steps run only when `commit` Succeeded; a no-op promotion never touches ArgoCD.

### Switches

`review`, `comment`, `report` and `notify` all default to `"on"`. A Stage turns one off with the quoted string `"off"`.

## Authorizing Stages on the Application

Every Application a Stage syncs must list it in `kargo.akuity.io/authorized-stage`, a comma-separated `<project>:<stage>` string. The annotation lives on the Application in the gitops side, never in `kargo-root`.

- Chart repositories: `argocd-system/patch-kargo.yaml` templates it on every ApplicationSet as `kargo-argocd-system-{{ .values.component }}:{{ .values.component }}.<env>`, together with the two selector labels.
- Workloads repositories: the cluster's ArgoCD repository sets it on the shared Application, e.g. `rubik-monitoring-backbone` carries `kargo-monitoring-backbone:rubik.mimir,kargo-monitoring-backbone:rubik.loki,kargo-monitoring-backbone:rubik.otel`. A new Stage on a shared Application is appended to that string.
