# Kargo Stage Wiring: kilic

The files, vars and annotations that connect a Stage to its Freight, its pin and its Application. Task internals and Kargo version quirks stay in [kargo-root](https://gitlab.kilic.dev/cluster/kargo-root) `CLAUDE.md`.

## Layout

In the gitops repository, `.promote/` holds one Project's promotion config. A workloads repository registers the whole folder:

```
.promote/
  kustomization.yaml        # projectconfig.yaml, <component>/ ...; the report verification patch
  projectconfig.yaml        # ProjectConfig kargo-<route>-<name> or kargo-<repo>
  <component>/              # = the Warehouse name
    kustomization.yaml      # warehouse.yaml, stages/
    warehouse.yaml
    stages/
      kustomization.yaml    # namePrefix: <component>., configurations: kustomizeconfig.yaml
      kustomizeconfig.yaml
      <cluster>.yaml
      <cluster>.report.yaml
```

`cluster/argocd-system` registers each `.promote/<component>/` as its own Project root instead: the component folder carries `projectconfig.yaml` beside `warehouse.yaml` and `stages/` (`<env>.yaml`, `<env>.report.yaml`), and loads the kustomize Component `../.components/report-verification`. Its `.promote/kustomization.yaml` only lists the component folders for CI; nothing syncs it.

- Every namespaced manifest sets `metadata.namespace: kargo-<...>` in full; kustomize `namespace:` is never used.
- The Warehouse sits outside the prefixed `stages/` kustomization, or `namePrefix` renames it. Each `stages/` folder carries its own `kustomizeconfig.yaml`; a shared one fails kustomize's load restrictor.
- Report Stage files carry no `verification:`. One patch selecting `kargo.kilic.dev/role=report` adds `report-verdict`: in `.promote/kustomization.yaml` for a workloads repository, in the `report-verification` Component for `argocd-system`.
- Every Stage carries labels `kargo.kilic.dev/auto: "true"` (selected by the ProjectConfig auto-promotion policy) and `kargo.kilic.dev/role` (`deploy` or `report`), and annotation `kargo.akuity.io/color` (development `green`, production `yellow`, load-balancer `amber`, platform `red`, every report `gray`).

In `kargo-root`, `projects/<route>/<name>/` or `projects/<repo>/` holds `namespace.yaml` (`kargo.akuity.io/project: "true"`, sync-wave `-2`, `Delete=confirm,Prune=confirm`), `project.yaml` (sync-wave `-1`, `kargo.akuity.io/description`), a `kustomization.yaml` listing those two, and `promote.yaml`, which no kustomization lists:

```yaml
project: kargo-<repo>             # kargo-argocd-system-<name> under projects/argocd-system/
source:
  repoURL: git@gitlab.kilic.dev:<group>/<repo>.git
  path: .promote                  # .promote/<component> for an argocd-system component
```

The folder is listed in `projects/kustomization.yaml` or `projects/argocd-system/kustomization.yaml`. Names are written in full, never derived from the folder.

## Warehouse

One subscription per Warehouse; its kind (`git`, `chart`, `image`) is the source kind the task branches on, read at runtime, so no Stage var names the source.

| Subscription | Pin value written | Sync without `argocd_apps` |
|---|---|---|
| `git` | the tag, or the full commit ID for branch-tracking Freight | `sync_revision` to the commit |
| `chart` | the chart version | `sync_chart` (Helm `chart` source), or `sync_revision` for an `oci://` source |
| `image` | per `pin_format` (`repo-tag` default, `tag`, `repo-digest`, `digest`) | rejected: needs `argocd_apps` |

- `kargo.kilic.dev/pin-key`: the `yaml-update` key in dot-and-index form (`helmCharts.0.version`); the task derives the `yaml-parse` path from it. Omitted for `argocd-system`, whose default is the ApplicationSet `spec.template.spec.sources.0.targetRevision`.
- `kargo.kilic.dev/release-url`: release notes URL with the placeholder `{version}`; without it the promotion carries no release link.
- An `oci://` chart subscription leaves `name` empty.
- An image Warehouse with `imageSelectionStrategy: Digest` needs `pin_format` `repo-digest` or `digest`, or every promotion writes the same tag.

## Stage Vars

Deploy Stages call `promote-pin`, report Stages `report-pin`, both `kind: ClusterPromotionTask`. Report Stages pass no vars except switches. Deploy Stages always pass `gitops_repo` (HTTPS), and add only what the defaults do not cover:

- `env`: defaults to the short Stage name, so only per-cluster workloads Stages set it (`production`).
- `pin_file`: repo-relative path in the gitops repository. The default means `<env>/<component>/patch-applicationset.yaml`. Pin locations per repository kind: `kargo-kilic-pins`.
- `pin_format`: image Stages only.
- `argocd_repo`: only when the Application source `repoURL` differs from the SSH form derived from the subscription (an ApplicationSet source without `.git`).

### Sync: `argocd_apps`

- Unset (chart repositories): a selector step pins every Application labelled `system.kilic.dev/component` and `cluster.kilic.dev/environment` to the promoted revision.
- Set (workloads repositories): `"${{ ['<application>'] }}"`, an expr list literal of exactly one name, never a bare JSON or comma string. `sync_app` syncs that Application's `HEAD` after `pin_mr_merge` put the pin on `main`.
- Sync steps run only when the pin changed, or a manual actor re-promotes a current pin; an auto no-op never touches ArgoCD.

### Switches

`review`, `comment`, `report` and `notify` all default to `"on"`. A Stage turns one off with the quoted string `"off"`.

## Authorizing Stages on the Application

Every Application a Stage syncs must list it in `kargo.akuity.io/authorized-stage`, a comma-separated `<project>:<stage>` string. The annotation lives on the Application in the gitops side, never in `kargo-root` or `.promote/`.

- Chart repositories: `argocd-system/patch-kargo.yaml` templates it on every ApplicationSet as `kargo-argocd-system-{{ .values.component }}:{{ .values.component }}.<env>`, together with the two selector labels.
- Workloads repositories deployed by a cluster's ArgoCD repository: that repository sets it on the shared Application, e.g. `rubik-monitoring-backbone` carries `kargo-monitoring-backbone:mimir.rubik,kargo-monitoring-backbone:loki.rubik,kargo-monitoring-backbone:opentelemetry-ingester.rubik`. A new Stage on a shared Application is appended to that string.
- Workloads repositories deployed by an `argocd-system` ApplicationSet: the ApplicationSet templates one entry per component, `kargo-argocd-system-monitoring:<component>.{{.name}}`. A new component adds its entry there.
