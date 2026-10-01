# Kargo Stage Wiring: kilic

The files, vars and annotations that connect a Stage to its Freight, its pin and its Application. Task internals and Kargo version quirks stay in [kargo-root](https://gitlab.kilic.dev/cluster/kargo-root) `CLAUDE.md`.

## Layout

In the gitops repository, `.promote/` holds one Project's promotion config. A workloads repository registers the whole folder:

```
.promote/
  kustomization.yaml        # projectconfig.yaml, <component>/ ...; the report verification patch
  projectconfig.yaml        # ProjectConfig kargo-<repo>
  <component>/              # = the Warehouse name
    kustomization.yaml      # warehouse.yaml, stages/
    warehouse.yaml
    stages/
      kustomization.yaml    # namePrefix: <component>., configurations: kustomizeconfig.yaml
      kustomizeconfig.yaml
      <stage>.yaml          # the stage is the cluster here, the environment in argocd-system
      <stage>.report.yaml
```

`cluster/argocd-system` registers each `.promote/<component>/` as its own Project root instead: the component folder carries `projectconfig.yaml` beside `warehouse.yaml` and `stages/` (`<stage>.yaml`, `<stage>.report.yaml`), and loads the kustomize Component `../.components/report-verification`. Its `.promote/kustomization.yaml` only lists the component folders for CI; nothing syncs it. A component with several Warehouses keeps one subfolder per Warehouse, as the workloads repositories do: `.promote/<component>/kustomization.yaml` lists `projectconfig.yaml`, each `<warehouse>/` and the `report-verification` Component, and each `<warehouse>/` holds its `kustomization.yaml`, `warehouse.yaml` and `stages/` (`namePrefix: <warehouse>.`).

- Every namespaced manifest sets `metadata.namespace: kargo-<...>` in full; kustomize `namespace:` is never used.
- The Warehouse sits outside the prefixed `stages/` kustomization, or `namePrefix` renames it. Each `stages/` folder carries its own `kustomizeconfig.yaml`; a shared one fails kustomize's load restrictor.
- Report Stage files carry no `verification:`. One patch selecting `kargo.kilic.dev/role=report` adds `report-verdict`: in `.promote/kustomization.yaml` for a workloads repository, in the `report-verification` Component for `argocd-system`.
- Every Stage carries labels `kargo.kilic.dev/auto: "true"` (selected by the ProjectConfig auto-promotion policy) and `kargo.kilic.dev/role` (`deploy` or `report`), and annotation `kargo.akuity.io/color` (development `green`, production `yellow`, load-balancer `amber`, platform `red`, every report `gray`).

In `kargo-root`, `projects/argocd-system/<component>/` or `projects/<repo>/` holds `project.yaml` (sync-wave `-1`, `Delete=confirm,Prune=confirm`, `kargo.akuity.io/description`), a `kustomization.yaml` listing it, and `promote.yaml`, which no kustomization lists. No Namespace: Kargo's Project controller creates the Project's namespace and the `kargo-root` AppProject whitelist does not allow one.

```yaml
project: kargo-<repo>             # kargo-argocd-system-<component> under projects/argocd-system/
source:
  repoURL: git@gitlab.kilic.dev:<group>/<repo>.git
  path: .promote                  # .promote/<component> for an argocd-system component
```

The folder is listed in `projects/kustomization.yaml` or `projects/argocd-system/kustomization.yaml`. Names are written in full, never derived from the folder.

## Warehouse

One subscription per Warehouse; its kind (`git`, `chart`, `image`) is the source kind the task branches on, read at runtime, so no Stage var names the source. The Warehouse also describes the pin, so a Stage passes no pin var.

| Subscription | Pin value written | Sync on the default `matchLabels` |
|---|---|---|
| `git` | the tag, or the full commit ID for branch-tracking Freight | `sync_revision` to the commit |
| `chart` | the chart version | `sync_chart` (Helm `chart` source), or `sync_revision` for an `oci://` source |
| `image` | the `pins` entry's `value` template (`{repo}:{tag}`, `{tag}`, `{digest}`) | `sync_head`: matching Applications at `HEAD`, no revision |

- `kargo.kilic.dev/pin-repo` and `kargo.kilic.dev/pins`: both required, the gitops repository and the JSON list of pins (`file` with `{stage}`, `key`, optional `value`); shape and examples in `kargo-kilic-pins`. The task derives the `yaml-parse` path from the primary `key`.
- `kargo.kilic.dev/release-url`: release notes URL with the placeholder `{version}`; without it the promotion carries no release link.
- An `oci://` chart subscription leaves `name` empty.
- An image Warehouse with `imageSelectionStrategy: Digest` needs a `value` with `{digest}`, or every promotion writes the same tag.

## Stage Vars

Deploy Stages call `promote-pin`, report Stages `report-pin`, both `kind: ClusterPromotionTask`. Report Stages pass no vars except switches. Deploy Stages pass only what the defaults do not cover, most none at all; the repository, file and format come from the Warehouse, and the agents door and Slack channel are the same everywhere:

- `environment`: defaults to the stage, so only per-cluster workloads Stages set it (`production`). The stage is the Stage name without the component prefix; "environment" means the real environment only.
- `argocd_selector`: which Applications the sync targets, below.

### Sync: `argocd_selector`

An expr literal map holding exactly one of `matchApplications` or `matchLabels`:

- Unset (chart repositories): `matchLabels` on `system.kilic.dev/component` and `cluster.kilic.dev/environment`; a selector step pins every matching Application to the promoted revision.
- `matchApplications` (workloads repositories): `"${{ {matchApplications: ['<application>']} }}"`, a list of exactly one name, never a bare JSON or comma string. `sync_app` syncs that Application's `HEAD` after `pin_mr_merge` put the pin on `main`.
- `matchLabels` on an `image` or `artifact` Stage (chart component images): `"${{ {matchLabels: {'system.kilic.dev/component': '<component>', 'cluster.kilic.dev/environment': 'load-balancer'} } }}"`, synced by `sync_head` at `HEAD`. The `} }` space is required.
- Sync steps run only when the pin changed, or a manual actor re-promotes a current pin; an auto no-op never touches ArgoCD. The deploy record carries the resolved `argocd.selector`, and the review and report inputs an `ArgoCD applications:` line.

### Switches

`review`, `comment`, `report` and `notify` all default to `"true"`. A Stage turns one off with the quoted string `"false"`.

## Authorizing Stages on the Application

Every Application a Stage syncs must list it in `kargo.akuity.io/authorized-stage`, a comma-separated `<project>:<stage>` string. The annotation lives on the Application in the gitops side, never in `kargo-root` or `.promote/`.

- Chart repositories: `argocd-system/patch-kargo.yaml` templates it on every ApplicationSet as `kargo-argocd-system-{{ .values.component }}:{{ .values.component }}.<stage>`, together with the two selector labels. A component's second Warehouse adds its own entry (`external-dns-webhook-opnsense.load-balancer`) in a root patch listed after `patch-kargo.yaml`.
- Workloads repositories deployed by a cluster's ArgoCD repository: that repository sets it on the shared Application, e.g. `rubik-monitoring-backbone` carries `kargo-monitoring-backbone:mimir.rubik,kargo-monitoring-backbone:loki.rubik,kargo-monitoring-backbone:opentelemetry-ingester.rubik`. A new Stage on a shared Application is appended to that string.
- Workloads repositories deployed by an `argocd-system` ApplicationSet: the ApplicationSet templates one entry per component, `kargo-monitoring:<component>.{{.name}}`. A new component adds its entry there.
