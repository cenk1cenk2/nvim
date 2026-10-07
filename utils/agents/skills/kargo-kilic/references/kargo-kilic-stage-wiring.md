# Kargo Stage Wiring: kilic

The files, vars and annotations that connect a Stage to its Freight, its pin and its Application. Task internals and Kargo version quirks stay in [kargo-root](https://gitlab.kilic.dev/cluster/kargo-root) `CLAUDE.md`.

## Layout

In the gitops repository, `.promote/` holds one Project's promotion config as values for the Helm chart [chart-kargo-promote](https://gitlab.kilic.dev/cluster/charts/chart-kargo-promote), published at `oci://registry-1.docker.io/cenk1cenk2/chart-kargo-promote` and versioned by its git tag. The chart renders the ProjectConfig, Warehouses and Stages; no Kargo manifest is written by hand. Its `README.md` documents every values key. A workloads repository registers the whole folder:

```
.promote/
  kustomization.yaml        # helmCharts: chart-kargo-promote, valuesFile: values.yaml
  values.yaml               # project, repository, chain, stages, warehouses
```

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

helmCharts:
  - name: chart-kargo-promote
    repo: oci://registry-1.docker.io/cenk1cenk2
    version: v2.0.0
    releaseName: kargo-promote
    valuesFile: values.yaml
```

`cluster/argocd-system` registers each `.promote/<component>/` as its own Project root over a shared `.promote/values.yaml` (`repository` and the `chain` every component shares). The component folder holds `values.yaml` (`project`, `warehouses`, and a `chain` when it skips environments) and a `kustomization.yaml` whose `helmCharts` entry sets `valuesFile: ../values.yaml` and `additionalValuesFiles: [values.yaml]`. Its `.promote/kustomization.yaml` only lists the component folders for CI; nothing syncs it. A component with several Warehouses lists them all in its one `values.yaml`.

- `releaseName` is always `kargo-promote`: Helm caps release names at 53 characters, and the chart takes the namespace from `project`.
- The repository pins the chart version in its `helmCharts` entry; its `renovate.json` extends `local>renovate/renovate-config:default/manager-kustomize-automerge-minor(registry-1.docker.io/cenk1cenk2/chart-kargo-promote)` (minor and patch automerge, major stays manual).
- `kustomize build --enable-helm` downloads the chart into `charts/` beside the kustomization, so the repository's `.gitignore` carries `charts/`. ArgoCD and the CI pipe run kustomize with `--enable-helm --load-restrictor LoadRestrictionsNone`, which `valuesFile: ../values.yaml` needs.
- A change to the chart's rendered output reaches every `.promote/` that bumps to that version.

### Values

```yaml
---
project: kargo-<repo>

repository: https://gitlab.kilic.dev/cluster/workloads/<repo>.git

chain:
  - <cluster>

stages:
  <cluster>:
    environment: production
    deploy:
      vars:
        argocd_selector:
          matchApplications:
            - <cluster>-<repo>

warehouses:
  - name: <component>
    annotations:
      kargo.kilic.dev/release-url: https://github.com/<owner>/<project>/releases/tag/{version}
    spec:
      subscriptions:
        - image:
            repoURL: <registry>/<image>
            constraint: "*"
            imageSelectionStrategy: SemVer
    pins:
      - file: .deploy/{stage}/deployment.yaml
        key: spec.template.spec.containers.0.image
        value: "{repo}:{tag}"

  - name: valkey
    spec:
      subscriptions:
        - chart:
            repoURL: https://valkey.io/valkey-helm/
            name: valkey
            semverConstraint: "*"
    pins:
      - file: .deploy/{stage}/valkey/kustomization.yaml
        key: helmCharts.0.version
    stages:
      <cluster>:
        deploy:
          vars:
            review: "false"
        jobs:
          report:
            enabled: false
```

- `project` is written in full; `repository` becomes every Warehouse's `kargo.kilic.dev/pin-repo`.
- `chain` is the ordered stages every Warehouse promotes through; a Warehouse's own `chain` replaces it.
- `stages.<stage>` is the stage catalog: `environment` (the pin's environment, the deploy Stage's `environment` var and the key into `metadata.environments`; unset, the stage is the environment and no var is written), `deploy` (the deploy Stage `<warehouse>.<stage>`, always rendered) and `jobs.<job>` (`jobs.report`, the report Stage `<warehouse>.<stage>.report`).
- `deploy` and each `jobs.<job>` take `requiredSoakTime` (this Stage's own wait for its source), `vars` (the task's vars, a map or list written as plain YAML and rendered as an expr literal), and `labels`, `annotations` and `spec`, merged over the generated Stage with the values winning; `kargo.akuity.io/color` in `deploy.annotations` overrides the environment's colour. A job also takes `enabled`. `deploy.vars.review: "false"` skips the review; `jobs.report.enabled: false` renders no report Stage, and the next deploy Stage sources the deploy Stage directly.
- `warehouses[]`: `name` (the Warehouse and the Stage prefix), `spec` verbatim (`subscriptions`, `interval`; no defaults added), `labels` and `annotations` merged over the generated metadata (the release notes URL is `kargo.kilic.dev/release-url`), `pins` (written as the `kargo.kilic.dev/pins` annotation), and optional `chain` and `stages.<stage>`, merged over the catalog: `deploy.vars` and `jobs.<job>.vars` merge by var name with each value replaced whole, other maps deep-merge, lists replace, `null` removes a key.
- Helm merges several values files the same way, so the argocd-system shared file holds `repository` and `chain` and each component file its `project`, `warehouses` and a `chain` when it skips environments.

The chart derives the rest from its `metadata` defaults: `metadata.environments.<environment>` (the deploy Stage's `requiredSoakTime` and colour annotation), `metadata.deploy` (task `promote-pin`, labels `kargo.kilic.dev/auto: "true"` and `kargo.kilic.dev/role: deploy`), `metadata.jobs.report` (`enabled`, suffix `report`, `requiredSoakTime: 2h0m0s`, task `report-pin`, role `report`, colour `gray`, the `report-verdict` verification in `spec`) and `metadata.projectconfig` (the auto-promotion policy), plus Stage names `<warehouse>.<stage>` and `<warehouse>.<stage>.report`, the `sources` chain and every object's `metadata.namespace`. Colours: development `green`, production `yellow`, load-balancer `amber`, platform `red`, every report `gray`. The render fails on a Warehouse without a chain, `deploy.vars.environment`, an unknown job, a deploy Stage after the first without a `requiredSoakTime`, pins naming more than one file, a Warehouse defined twice, or an empty var. The schema is loose: an unknown key is ignored, not rejected. Render a pipeline with `kustomize build --enable-helm --load-restrictor LoadRestrictionsNone .promote` (`.promote/<component>` in `argocd-system`).

In `kargo-root`, `projects/argocd-system/<component>/` or `projects/<repo>/` holds `project.yaml` (sync-wave `-1`, `kargo.akuity.io/description`), a `kustomization.yaml` listing it, and `promote.yaml`, which no kustomization lists. No Namespace: Kargo's Project controller creates the Project's namespace and the `kargo-root` AppProject whitelist does not allow one.

```yaml
---
project: kargo-<repo>             # kargo-argocd-system-<component> under projects/argocd-system/

sources:
  - repoURL: git@gitlab.kilic.dev:<group>/<repo>.git
    path: .promote                # .promote/<component> for an argocd-system component
    targetRevision: HEAD
```

The ApplicationSet copies `sources` verbatim into the generated Application; there is never a top-level `path`, since the git files generator overwrites it. The folder is listed in `projects/kustomization.yaml` or `projects/argocd-system/kustomization.yaml`. Names are written in full, never derived from the folder.

## Warehouse

One subscription per Warehouse; its kind (`git`, `chart`, `image`) is the source kind the task branches on, read at runtime, so no Stage var names the source. The Warehouse also describes the pin, so a Stage passes no pin var.

| Subscription | Pin value written | Sync on the default `matchLabels` |
|---|---|---|
| `git` | the tag, or the full commit ID for branch-tracking Freight | `sync_revision` to the commit |
| `chart` | the chart version | `sync_chart` (Helm `chart` source), or `sync_revision` for an `oci://` source |
| `image` | the `pins` entry's `value` template (`{repo}:{tag}`, `{tag}`, `{digest}`) | `sync_head`: matching Applications at `HEAD`, no revision |

- `repository` and the Warehouse's `pins` are required; the chart writes them as `kargo.kilic.dev/pin-repo` and `kargo.kilic.dev/pins` (the list as pretty JSON in a `|-` block). Pin entries are `file` with `{stage}`, `key`, optional `value`; shape and examples in `kargo-kilic-pins`. The task derives the `yaml-parse` path from the primary `key`.
- The Warehouse annotation `kargo.kilic.dev/release-url`: release notes URL with the placeholder `{version}`; without it the promotion carries no release link.
- An `oci://` chart subscription leaves `name` empty.
- An image Warehouse with `imageSelectionStrategy: Digest` needs a `value` with `{digest}`, or every promotion writes the same tag.

## Stage Vars

Deploy Stages call `promote-pin`, report Stages `report-pin`, both `kind: ClusterPromotionTask`. Report Stages pass no vars except switches (`stages.<stage>.jobs.report.vars`). Deploy Stages pass only what the defaults do not cover (`stages.<stage>.deploy.vars`), most none at all; the repository, file and format come from the Warehouse, and the agents door and Slack channel are the same everywhere:

- `environment`: set through `stages.<stage>.environment`, never in `deploy.vars`. It defaults to the stage, so only per-cluster workloads stages set it (`production`). The stage is the Stage name without the component prefix; "environment" means the real environment only.
- `argocd_selector`: which Applications the sync targets, below, written as a plain YAML map that the chart renders as an expr literal.

### Sync: `argocd_selector`

A map holding exactly one of `matchApplications` or `matchLabels`, rendered as an expr literal on the Stage:

- Unset (chart repositories): `matchLabels` on `system.kilic.dev/component` and `cluster.kilic.dev/environment`; a selector step pins every matching Application to the promoted revision.
- `matchApplications` (workloads repositories): a list of exactly one name, rendered `"${{ {matchApplications: ['<application>']} }}"`. `sync_app` syncs that Application's `HEAD` after `pin_mr_merge` put the pin on `main`.
- `matchLabels` on an `image` or `artifact` Stage (chart component images): `system.kilic.dev/component: <component>` and `cluster.kilic.dev/environment: load-balancer` under the Warehouse's `stages.<stage>.deploy.vars.argocd_selector.matchLabels`, synced by `sync_head` at `HEAD`.
- Sync steps run only when the pin changed, or a manual actor re-promotes a current pin; an auto no-op never touches ArgoCD. The deploy record carries the resolved `argocd.selector`, and the review and report inputs an `ArgoCD applications:` line.

### Switches

`review`, `comment`, `report` and `notify` all default to `"true"`, and each is turned off with the quoted string `"false"`: `review`, `notify` and `comment` in `deploy.vars` (deploy Stage), `report`, `notify` and `comment` in `jobs.report.vars` (report Stage). `jobs.report.enabled: false` removes the report Stage itself; a report Stage kept with `report: "false"` still holds the soak gate and posts the final thread message.

## Authorizing Stages on the Application

Every Application a Stage syncs must list it in `kargo.akuity.io/authorized-stage`, a comma-separated `<project>:<stage>` string. The annotation lives on the Application in the gitops side, never in `kargo-root` or `.promote/`.

- Chart repositories: `argocd-system/patch-kargo.yaml` templates it on every ApplicationSet as `kargo-argocd-system-{{ .values.component }}:{{ .values.component }}.<stage>`, together with the two selector labels. A component's second Warehouse adds its own entry (`external-dns-webhook-opnsense.load-balancer`) in a root patch listed after `patch-kargo.yaml`.
- Workloads repositories deployed by a cluster's ArgoCD repository: that repository sets it on the shared Application, e.g. `rubik-monitoring-backbone` carries `kargo-monitoring-backbone:mimir.rubik,kargo-monitoring-backbone:loki.rubik,kargo-monitoring-backbone:opentelemetry-ingester.rubik`. A new Stage on a shared Application is appended to that string.
- Workloads repositories deployed by an `argocd-system` ApplicationSet: the ApplicationSet templates one entry per component, `kargo-monitoring:<component>.{{.name}}`. A new component adds its entry there.
