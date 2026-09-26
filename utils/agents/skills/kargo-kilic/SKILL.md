---
name: kargo-kilic
description: kargo-kilic Load when adding, changing, reverting or debugging a Kargo promotion flow in the kilic estate - a kargo-root Project, Warehouse or Stage, the pin file it writes, or moving a repository between Renovate and Kargo. Covers Project shape per repository kind, pin locations, soak chains and Stage wiring. Not for ArgoCD sync or prune state, or the Laravel estate.
references:
  - ./references/kargo-kilic-pins.md
  - ./references/kargo-kilic-stage-wiring.md
  - ../references/current-state-only.md
---

## Kargo Promotion: kilic

Kargo runs on `overseer` and is configured entirely from [kargo-root](https://gitlab.kilic.dev/cluster/kargo-root) (`.deploy/overseer/`). Its `CLAUDE.md` on `main` is the authority for task internals, record schema and v1.11.4 quirks; this skill carries the estate-level decisions around it: which Project shape a repository gets, where its pins live, how Stages chain, and how a repository moves between Renovate and Kargo.

A promotion never calls ArgoCD's sync API to deploy a new version. `promote-pin` writes one YAML value in one file of a gitops repository, merges the pin MR, then asks ArgoCD to sync the Application; the report Stage judges the result after a soak.

## Repository Kinds

Every Kargo-managed repository is one of two kinds, and the kind fixes the Stage naming, the sync mode and the Project split.

| | Chart repositories | Kustomize workloads repositories |
|---|---|---|
| Source | wrapper chart `cluster/charts/chart-<component>`, released as git tags | upstream Helm charts and images pinned inside `cluster/workloads/<repo>` |
| Pin lives in | [argocd-system](https://gitlab.kilic.dev/cluster/argocd-system) `<env>/<component>/patch-applicationset.yaml`, `targetRevision` | the workloads repository's own per-cluster overlay files, per `kargo-kilic-pins` |
| ArgoCD shape | one ApplicationSet per component per env, generating one Application per cluster of that env | plain directory source, one Application per cluster and repository, `<cluster>-<repo>` |
| Stages | per env: `<component>.<env>` and `<component>.<env>.report` | per cluster: `<cluster>.<component>` and `<cluster>.<component>.report` |
| Project | one per component, `kargo-argocd-system-<component>` | one per repository, `kargo-<repo>` (precedent: `kargo-monitoring-backbone`) |
| Sync | label selector (`argocd_apps` unset), pinned to the promoted revision | `argocd_apps`, a literal list naming the one shared Application |
| `env` var | the overlay directory the Stage pins | still the environment of the pin (`production`), not the Stage |

A pin in a chart repository's env covers every cluster of that env at once. A workloads pin covers one cluster, so a workloads repository deployed to several clusters gets one Stage per cluster.

**Selector sync cannot work for a workloads repository**, for three independent reasons, so every workloads Stage sets `argocd_apps`:

- `source_gate` rejects an `image` Stage without `argocd_apps`: the Application tracks the gitops repository, so there is no image revision to pin it to.
- A `chart` Stage without `argocd_apps` takes the `sync_chart` step, which writes a Helm `chart` source (`repoURL`, `chart`, `desiredRevision`) onto the Application. A workloads Application is a directory source of the gitops repository, so that source is wrong for it.
- The selector matches Applications labelled `system.kilic.dev/component` and `cluster.kilic.dev/environment`. A shared Application holds several components and cannot carry one component label, and a `desiredRevision` pin would revert the newer pins other Stages and humans merge to the same repository. `sync_app` syncs whatever `HEAD` holds instead.

`argocd_apps` is a literal list of exactly one name (`"${{ ['rubik-monitoring-backbone'] }}"`), because the `sync_app` step writes a fixed-length `apps` list; any other length renders an empty name and fails the step. One Stage therefore syncs one Application, which is the other reason Stages are per cluster.

## Choosing the Project Split

**The Project boundary follows the ArgoCD Application boundary.** Decide it before writing any manifest:

- **One Project, several Warehouses** when the components share one Application: a workloads repository whose components all sync through `<cluster>-<repo>`. `monitoring-backbone` is the precedent: Project `kargo-monitoring-backbone`, Warehouses `mimir`, `loki` (charts) and `opentelemetry-ingester` (image), Stages `rubik.mimir`, `rubik.loki`, `rubik.otel` with a `.report` each.
- **One Project per component** when each component is its own ApplicationSet and is versioned and released on its own: every `argocd-system` wrapper chart, Project `kargo-argocd-system-<component>` with Warehouse `<component>`.

What each side buys and costs:

| | One Project per repository | One Project per component |
|---|---|---|
| Authorization | one Application lists every Stage in one `kargo.akuity.io/authorized-stage` string | `argocd-system/patch-kargo.yaml` templates `kargo-argocd-system-{{ .values.component }}:{{ .values.component }}.<env>` for every ApplicationSet; it only works because Project and Stage names derive from the component |
| Stage names | written in full in each manifest, no `namePrefix`, since the Application names them literally | short names plus `namePrefix: <component>.` and a `kustomizeconfig.yaml` rewriting `sources.stages` |
| Isolation | one namespace, one ProjectConfig promotion policy, one UI view of a coupled rollout | a namespace, ProjectConfig and UI entry per component; a bad component cannot crowd another's view |
| Freight lookup | a Stage requesting from several Warehouses that could each provide the artifact needs `source_origin`; today each Stage requests one Warehouse | never ambiguous |
| Cost of adding a component | a Warehouse file and two Stage files | a whole Project directory |

Split a coupled repository per component only when its components genuinely ship on their own Applications. Keep an independently released chart in its own Project even when it is small.

## Soak and Report Chain

- Every deploy Stage has a report Stage beside it that sources only from it, with `requiredSoakTime: 2h0m0s`, auto-promotes, runs `report-pin` and verifies with ClusterAnalysisTemplate `report-verdict` (fails on `DEGRADED` and `ERRORED`).
- A downstream deploy Stage sources **only** from the upstream `.report` Stage, never from the upstream deploy Stage, and sets `report_previous` to that report Stage's full name.
- Soak on top of the report's 2h: `10h0m0s` after the first env's report (`development.report`), `4h0m0s` after any later report.
- Env order for chart repositories: `development`, `production`, `load-balancer`, `platform`, skipping envs a component does not pin (reloader, goldilocks and vpa source `platform` from `production.report`). The last report is a leaf.
- Chains are linear. The fan-in form (`sources.stages: [<up>, <up>.report]` with `availabilityStrategy: All`) is unusable on v1.11.4: `ListFreightAvailableToStage` requires the verified set to equal the sources (`verifiedStages.Equal`), so under `All` real Freight never lists for later Stages and they become manual-only.
- Durations are written normalized (`2h0m0s`, `10h0m0s`), or ArgoCD reports the Stage OutOfSync.
- A single-cluster workloads Project has no chain: each deploy Stage sources `direct: true` from its Warehouse.

## Process

1. **Classify the repository** as a chart or workloads repository per Repository Kinds, and pick the Project split per Choosing the Project Split.
2. **Locate or create the pin** per `kargo-kilic-pins`. Version decisions never live in `base`; one override patch per resource per cluster (or per env).
3. **Write the Warehouse and Stages** in `kargo-root`, wired per `kargo-kilic-stage-wiring`: the `pin_file` / `pin_key` / `pin_path` triple, `source_kind`, `argocd_apps` for workloads, the chain and soak above.
4. **Authorize the Stages on the Application** in its gitops repository (`kargo.akuity.io/authorized-stage`, comma-separated `<project>:<stage>`), per `kargo-kilic-stage-wiring`.
5. **Hand the version off from Renovate** in the same change set per `kargo-kilic-pins`, so the two never race on one pin.
6. **Verify by rendering**: `kustomize build .deploy/overseer` in `kargo-root`, and the workloads overlay with `--enable-helm` for a generator pin, before opening MRs.

## Key Principles

- **The repositories win.** Check `kargo-root` `CLAUDE.md` on `main` and the live manifests before relying on a fact here; a drifted fact is corrected in this skill in the same turn, per `current-state-only`.
- **One promotion pins one artifact in one key.** A second artifact is a second Warehouse or Stage, never a second key written by one Stage.
- **A pin has one writer.** Kargo or Renovate owns each dependency, never both.
- **Review, report, notify and comment default to `"on"`.** Turn one off only with a stated reason (the `prometheus-operator` and `opentelemetry-operator` Projects run review, report and notify off because Renovate automerges their charts).
