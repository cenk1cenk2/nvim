---
name: kargo-kilic
description: kargo-kilic Shape and wire Kargo promotions in the kilic estate - Project naming, .promote/ Warehouses and Stages, pins, soak chains, kargo-root registration and the Renovate handover. Use when adding, changing, reverting or debugging a promotion flow. Not for ArgoCD sync or prune state, or the Laravel estate.
references:
  - ./references/kargo-kilic-pins.md
  - ./references/kargo-kilic-stage-wiring.md
  - ../references/current-state-only.md
---

## Kargo Promotion: kilic

Kargo runs on `overseer`. [kargo-root](https://gitlab.kilic.dev/cluster/kargo-root) `CLAUDE.md` on `main` is the authority for task internals, record schema, the `.promote/` layout and Kargo version quirks; this skill carries the estate-level decisions around it: which Project shape a repository gets, where its pins live (on the Warehouse), how Stages chain, and how a repository moves between Renovate and Kargo.

A promotion never calls ArgoCD's sync API to deploy a new version. `promote-pin` writes the pinned values of one file of a gitops repository, merges the pin MR, then asks ArgoCD to sync the Application; the report Stage judges the result after a soak.

## Where Promotions Live

Each gitops repository owns how it promotes; `kargo-root` owns what the promotions share and the Projects they run in.

| `cluster/kargo-root` | The gitops repository's `.promote/` |
|---|---|
| `shared/` (ClusterConfig, credentials), `promotions/` (ClusterPromotionTasks `promote-pin`, `report-pin`, ClusterAnalysisTemplate `report-verdict`) | the Project's ProjectConfig (auto-promotion policy) |
| each Project's `project.yaml` in `projects/argocd-system/<component>/` or `projects/<repo>/`; Kargo's Project controller creates and owns the Project's namespace, so `kargo-root` holds no Namespace | Warehouses, with the `kargo.kilic.dev/pin-repo`, `kargo.kilic.dev/pins` and `kargo.kilic.dev/release-url` annotations |
| the registry entry `promote.yaml` beside it, and ApplicationSet `kargo-promote` | deploy and report Stages |

`kargo-promote` reads every `projects/**/promote.yaml` (`project`, `source.repoURL`, `source.path`) and generates one Application named after the Project, in AppProject `kargo`, syncing that `.promote/` path into the Project's namespace. `.promote/` is a separate kustomize root built by the repository's CI and never part of its own root build; it stays inert until registered.

| Registry folder | Project | Source |
|---|---|---|
| `projects/argocd-system/<component>/`, one per chart component | `kargo-argocd-system-<component>` | `cluster/argocd-system`, `.promote/<component>` |
| `projects/monitoring/` | `kargo-monitoring` | `cluster/workloads/monitoring`, `.promote` |
| `projects/monitoring-backbone/` | `kargo-monitoring-backbone` | `cluster/workloads/monitoring-backbone`, `.promote` |

The Project is named after the repository its `.promote/` lives in: `kargo-<repo>` for a workloads repository (`kargo-monitoring`, `kargo-rustfs`, `kargo-gitlab-runner`, `kargo-renovate` for `renovate/renovate`), whichever ArgoCD repository deploys its Applications and however many clusters and Applications it spans, and `kargo-argocd-system-<component>` for each `cluster/argocd-system` chart component. The registry folder follows it: `projects/<repo>/` or `projects/argocd-system/<component>/`. The Kargo UI title is always `metadata.name`; the Project's `kargo.akuity.io/description` (`<repo>` or `argocd-system.<component>`) shows under it.

## Repository Kinds

Every Kargo-managed repository is one of two kinds, and the kind fixes the Stage naming, the sync mode and the Project split.

| | Chart repositories | Kustomize workloads repositories |
|---|---|---|
| Source | wrapper chart `cluster/charts/chart-<component>`, released as git tags | upstream Helm charts and images pinned inside `cluster/workloads/<repo>` |
| Pin lives in | [argocd-system](https://gitlab.kilic.dev/cluster/argocd-system) `<environment>/<component>/patch-applicationset.yaml`, `targetRevision` | the workloads repository's own per-cluster overlay files, per `kargo-kilic-pins` |
| ArgoCD shape | one ApplicationSet per component per env, generating one Application per cluster of that env | plain directory source, one Application per cluster and repository: `<cluster>-<repo>` from the cluster's ArgoCD repository, or `cluster-<cluster>-system-<repo>` from an `argocd-system` ApplicationSet |
| Stages | per environment: `<component>.<stage>` and `<component>.<stage>.report`, the stage an environment | per cluster: `<component>.<stage>` and `<component>.<stage>.report`, the stage a cluster |
| Project | one per component, `kargo-argocd-system-<component>`, registering `argocd-system` `.promote/<component>` | one per repository, registering its whole `.promote/`: `kargo-<repo>` (`kargo-monitoring-backbone`, `kargo-monitoring`) |
| Sync | `argocd_selector` unset: the default `matchLabels`, pinned to the promoted revision | `argocd_selector` with `matchApplications`, one name: the cluster's Application |
| `environment` var | the stage, by default | still the environment of the pin (`production`), not the stage |

A pin in a chart repository's env covers every cluster of that env at once. A workloads pin covers one cluster, so a workloads repository deployed to several clusters gets one Stage per cluster.

**Selector sync cannot work for a workloads repository**, for three independent reasons, so a workloads Stage sets `argocd_selector` with `matchApplications`. The one exception is an image pinned in a base every Application of the repository includes: one Stage per cluster syncs them all by a label they share with `matchLabels` (`sync_head`), and each of them authorizes it (rustfs's `opentelemetry-collector.rubik` on `system.kilic.dev/component: rustfs`).

- A `matchLabels` selector on an `image` or `artifact` runs `sync_head`, which syncs the matching Applications at `HEAD` without a revision. That suits an image in a Helm values file the Applications read at `HEAD` (chart component images below); a workloads Application is shared by several components, so it is named instead.
- A `chart` Stage on the default selector takes the `sync_chart` step, which writes a Helm `chart` source (`repoURL`, `chart`, `desiredRevision`) onto the Application. A workloads Application is a directory source of the gitops repository, so that source is wrong for it.
- The selector matches Applications labelled `system.kilic.dev/component` and `cluster.kilic.dev/environment`. A shared Application holds several components and cannot carry one component label, and a `desiredRevision` pin would revert the newer pins other Stages and humans merge to the same repository. `sync_app` syncs whatever `HEAD` holds instead.

`argocd_selector` is an expr literal map, `"${{ {matchApplications: ['rubik-monitoring-backbone']} }}"`: `matchApplications` is a list of exactly one name, because the `sync_app` step writes a fixed-length `apps` list; `matchLabels` is a label map. The default `matchLabels` is `system.kilic.dev/component` plus `cluster.kilic.dev/environment`. One Stage on `matchApplications` syncs one Application, which is the other reason Stages are per cluster. When one cluster carries several separately pinned instances of a repository, the stage names the instance and the pin sits in `.deploy/<cluster>/{stage}/`: one Application per instance for rustfs (`rustfs.main` syncs `rubik-rustfs-main`), or one Application holding several chart releases for gitlab-runner (`gitlab-runner.loki-rubik-amd64-privileged` and `gitlab-runner.loki-rubik-amd64` both sync `rubik-gitlab-runner-system`).

**Chart component images** are a third case: an image a chart component runs, pinned in a Helm values file of `cluster/argocd-system` (`load-balancer/<component>/values.yaml`) that the component's Applications read at `HEAD`. It is a second Warehouse, with an `image` subscription, inside the component's existing Project, whose Stages set `matchLabels` and sync with `sync_head`. The first is `external-dns-webhook-opnsense` in `kargo-argocd-system-external-dns-opnsense-{loki,thor}`, with `review`, `report` and `notify` off.

## Choosing the Project Split

**The Project boundary follows the ArgoCD Application boundary.** Decide it before writing any manifest:

- **One Project, several Warehouses** when the components share one Application per cluster: a workloads repository whose components all sync through the cluster's Application. `monitoring-backbone` is the precedent: Project `kargo-monitoring-backbone`, Warehouses `mimir`, `loki` (charts) and `opentelemetry-ingester` (image), Stages `mimir.rubik`, `loki.rubik`, `opentelemetry-ingester.rubik` with a `.report` each.
- **One Project per component** when each component is its own ApplicationSet and is versioned and released on its own: every `argocd-system` wrapper chart, Project `kargo-argocd-system-<component>` with Warehouse `<component>`. An image of that chart is a further Warehouse in the same Project, and the component's `.promote/<component>/` folder then holds one subfolder per Warehouse.

What each side buys and costs:

| | One Project per repository | One Project per component |
|---|---|---|
| Authorization | the cluster's Application lists every Stage in one `kargo.akuity.io/authorized-stage` string, or its ApplicationSet templates one entry per component | `argocd-system/patch-kargo.yaml` templates `kargo-argocd-system-{{ .values.component }}:{{ .values.component }}.<stage>` for every ApplicationSet; it only works because Project and Stage names derive from the component |
| Isolation | one namespace, one ProjectConfig promotion policy, one UI view of a coupled rollout | a namespace (Kargo's), ProjectConfig and UI entry per component; a bad component cannot crowd another's view |
| Cost of adding a component | a `.promote/<component>/` folder, one repository MR; nothing changes in `kargo-root` | a `.promote/<component>/` folder in `argocd-system` plus a registry folder in `kargo-root` |

Both sides name Stages the same way: short names in the manifests, `namePrefix: <component>.` in each Warehouse's `stages/kustomization.yaml`, and a per-folder `kustomizeconfig.yaml` rewriting the Warehouse and `sources.stages` references.

Split a coupled repository per component only when its components genuinely ship on their own Applications. Keep an independently released chart in its own Project even when it is small.

## Soak and Report Chain

- Every deploy Stage has a report Stage beside it that sources only from it, with `requiredSoakTime: 2h0m0s`, auto-promotes, runs `report-pin` and verifies with ClusterAnalysisTemplate `report-verdict` (fails on `DEGRADED` and `ERRORED`).
- A downstream deploy Stage sources **only** from the upstream `.report` Stage, never from the upstream deploy Stage. The tasks read the chain from the Stages themselves; no var names a Stage.
- Soak on top of the report's 2h: `10h0m0s` after the first env's report (`development.report`), `4h0m0s` after any later report.
- Stage order for chart repositories (the environments): `development`, `production`, `load-balancer`, `platform`, skipping envs a component does not pin (reloader, goldilocks and vpa source `platform` from `production.report`). The last report is a leaf.
- Chains are linear. The fan-in form (`sources.stages: [<up>, <up>.report]` with `availabilityStrategy: All`) is unusable: `ListFreightAvailableToStage` requires the verified set to equal the sources (`verifiedStages.Equal`), so under `All` real Freight never lists for later Stages and they become manual-only.
- Durations are written normalized (`2h0m0s`, `10h0m0s`), or ArgoCD reports the Stage OutOfSync.
- Stage order for workloads repositories is the cluster chain the repository states (`monitoring`: `nailbed`, `neutrino`, `rubik`, `moon`, `sun`, `overseer`). A single-cluster workloads Project has no chain: each deploy Stage sources `direct: true` from its Warehouse.

## Process

1. **Classify the repository** as a chart or workloads repository per Repository Kinds, and pick the Project split per Choosing the Project Split.
2. **Locate or create the pin** per `kargo-kilic-pins`. Version decisions never live in `base`; one override patch per resource per cluster (or per environment).
3. **Write the Warehouse and Stages** in the gitops repository's `.promote/`, wired per `kargo-kilic-stage-wiring`: the Warehouse's single subscription and its `pin-repo` and `pins` annotations, `argocd_selector` and `environment` for workloads, the chain and soak above. A component of an already registered workloads repository is this one repository MR; nothing changes in `kargo-root`.
4. **Register a new Project** in `kargo-root` per `kargo-kilic-stage-wiring`: the registry folder with `project.yaml`, `kustomization.yaml` and `promote.yaml` (Kargo creates the namespace), listed in its parent kustomization. A repository outside `cluster/argocd-system` and `cluster/workloads/*` also needs a `kargo` AppProject `sourceRepos` entry in `cluster/argocd-root`. Merge the repository MR first; it is inert until registered.
5. **Authorize the Stages on the Application** in its gitops repository (`kargo.akuity.io/authorized-stage`, comma-separated `<project>:<stage>`), per `kargo-kilic-stage-wiring`.
6. **Hand the version off from Renovate** in the same change set per `kargo-kilic-pins`, so the two never race on one pin.
7. **Verify by rendering** before opening MRs: `kustomize build .promote` (and `.promote/<component>` in `argocd-system`) in the gitops repository, `kustomize build .` in `kargo-root`, and the workloads overlay with `--enable-helm` for a generator pin. After `kargo-root` syncs, check that the Application named after the Project exists and is synced and that the Project lists its Stages.

## Key Principles

- **The repositories win.** Check `kargo-root` `CLAUDE.md` on `main`, the gitops repository's own `CLAUDE.md` section on `.promote/`, and the live manifests before relying on a fact here; a drifted fact is corrected in this skill in the same turn, per `current-state-only`.
- **A rename is a cutover.** The estate is in testing, so Freight and Stage records are disposable: the repository's `.promote/` switches every name and namespace, `kargo-root` renames the registry folder, and the Applications' `authorized-stage` entries take the new prefix. Syncing removes the old Project completely: ApplicationSet `kargo-promote` deletes its generated Application, whose resources finalizer deletes its Stages, Warehouses and ProjectConfig, and confirming the `kargo-root` prune of the old Project deletes its namespace. Only `kargo-root` syncs with `Prune=confirm`; the generated Applications prune and self-heal without a confirmation.
- **One promotion pins one artifact in one file.** The Warehouse's `pins` may write that artifact's version to several keys of the file; a second artifact is a second Warehouse with its own Stages.
- **A pin has one writer.** Kargo or Renovate owns each dependency, never both; Renovate is disabled for every artifact Kargo promotes.
- **Review, report, notify and comment default to `"true"`; a Stage turns one off with `"false"`.** Turn one off only with a stated reason (the `prometheus-operator` and `opentelemetry-operator` Projects run review, report and notify `"false"` because Renovate automerges their charts). Helper images, dependency charts and Applications on an auto-update cycle (digest-pinned moving tags, the html sites, gose, teamspeak3, gitlab-tools, the agents bridges, the ollama MCP images) run review, report and notify `"false"` by owner decision; kargo-root `CLAUDE.md` keeps the list.
