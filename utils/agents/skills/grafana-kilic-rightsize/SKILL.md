---
name: grafana-kilic-rightsize
description: grafana-kilic-rightsize Find and apply tight container rightsizing from VPA outliers, OOM kills, throttling and a week of usage, resolving each candidate to the repository and layer that owns it. Use on "find rightsizing candidates", "rightsize this workload", a CPUThrottlingHigh alert, "walStorage". Not for replica counts or node sizing.
disableModelInvocation: true
argumentHint: '[candidates|target] - e.g. ''find candidates on rubik'', ''rightsize loki-chunks-cache'''
references:
  - ../references/kilic/kilic-workload-resolution.md
  - ../references/kilic/kilic-resource-placement.md
  - ./references/rightsize-signals.md
  - ./references/rightsize-snap-grids.md
  - ./references/rightsize-hpa-anchor.md
  - ./references/rightsize-bursty-list.md
  - ./references/rightsize-vpa-percentiles.md
  - ./references/rightsize-charts-cross-cluster.md
  - ./references/rightsize-cnpg-walstorage.md
  - ./references/rightsize-throttling-alert.md
  - ./references/rightsize-slack-alert.md
  - ./references/rightsize-database-discovery.md
  - ./references/rightsize-vpa-inplace.md
---

## Container Rightsizing

Load `grafana-kilic` before the first query to its MCP server, which supplies metrics; `argocd-kilic` to resolve a workload to the repository that owns it, and `gitlab` for the change itself. Signals, weights, thresholds, and queries: `rightsize-signals`.

## Two Modes

**The ask decides the mode. Never widen one into the other.**

| The user gives | Mode | Ends at |
|---|---|---|
| No target — "find candidates", "what is badly sized" | **Discovery** | A ranked candidate list. Stop there. |
| A target or targets — a workload, namespace, or cluster to fix | **Implementation** | Changes landed in the right layer, merge request open. |

Discovery that finds ten candidates does not become ten merge requests. Present the list and let the user choose. Implementation on a named target still runs the evidence gathering below — a target the user names is a place to look, not a verdict that it is wrong.

## VPA Is a Suggestion, Not an Answer

The outlier dashboard is the entry point, and it is only that. A VPA recommendation is a decayed estimate over roughly eight days; it lags a workload that changed shape and it cannot see a container being killed for exceeding its limit.

**Every candidate needs corroboration from actual usage over 7d before it is proposed.** Where VPA and usage disagree, usage wins and the disagreement is worth reporting — it usually means the workload's behaviour changed recently.

**OOM kills and sustained throttling carry heavy weight and are worth raising on their own.** A container being killed is a live problem, not an efficiency one. When either shows up, surface it plainly, name the evidence, and offer to take it in hand in the same pass — do not bury it in a list of efficiency suggestions.

Short-lived workloads and brief throttle spikes carry little weight. A Job pegged at 100% throttle for ninety seconds is usually working as intended; list it separately rather than proposing a change for it.

## Tight Sizing

**Every value is the measured figure on the grid, with nothing added.** Queries and targets per `rightsize-signals`, grid and value floors per `rightsize-snap-grids`.

- **Requests** come from the 7d time-weighted average of the busiest pod per 5-minute step. Never from a per-series average: it inflates every workload whose pods churned in the window.
- **Limits** are the smallest grid stop at or above the 7d max. Never below the max, and never a new limit where none existed.
- **No multiplier.** Bursty workloads take the same rule; `rightsize-bursty-list` decides only whether the 7d window held a burst before a limit is lowered to its max.
- **Sustained throttling raises the CPU limit**, and only for a container steadily throttled by the summed figure. A container throttling in sub-second bursts while its average sits far below the limit — exporters, usually — is the quota working as designed and stays untouched.
- **Read every HPA before a request moves**, per `rightsize-hpa-anchor`. A Utilization target divides by the request, so a request cut scales the workload out at a fraction of the load: on envoy-gateway this is why its requests were held, and zitadel's `targetCPU: 300` is why its CPU request was held. Re-anchor per the `averageValue = floor(0.8 x limit)` rule only when the resize actually touches the HPA-anchored workload.

Scopes with their own arithmetic:

| Scope | Per |
|---|---|
| Chart repositories in `cluster/charts/*` — one version on every cluster, so the cross-cluster maximum | `rightsize-charts-cross-cluster` |
| CNPG `walStorage`, a WAL PVC filling up, with its backup-health gate | `rightsize-cnpg-walstorage` |
| The VPA recommender's own `extraArgs` percentiles | `rightsize-vpa-percentiles` |
| Applying requests through VPA itself — in-place resize, goldilocks | `rightsize-vpa-inplace` |
| A sweep over every database — CNPG and MariaDB CRs are often generated, not source | `rightsize-database-discovery` |
| A `CPUThrottlingHigh` alert, or a Slack thread carrying one — the alert is the specification | `rightsize-slack-alert`; already-changed limits per `rightsize-throttling-alert` |

The renovate KubeJob's `activeDeadlineSeconds` stays 600s. It is a run budget, not a resource, and a sizing change leaves it alone.

## Process

### Discovery

1. **Scope it.** Which clusters. Absent an answer, ask once. A sizing decision is per cluster, so read each cluster on its own — its `mimir-<cluster>` uid, or `cluster="<name>"` on the federated `mimir` — never as one All-cluster pass: that costs every tenant and ranks the outlier tables across the fleet, so one cluster's candidates get crowded out of the top 25.
2. **Read the outliers**, per `rightsize-signals`. Start from the VPA outlier tables, then pull OOM kills and throttling for the same scope. The tables cap at 25 rows, so a quiet table means nothing ranked highly, never that the cluster is clean.
3. **Corroborate each candidate against 7d usage.** Drop the ones usage contradicts, and say how many were dropped.
4. **Apply the materiality floors.** Below them the change is not worth a restart. Report what was skipped and why rather than dropping it silently.
5. **Resolve each survivor to its repository**, per `kilic-workload-resolution` — ArgoCD is the authority, never the name.
6. **Rank and present**, heaviest evidence first: OOM kills, then sustained throttling, then size deltas by magnitude. Stop here.

### Implementation

1. **Gather the evidence for the named target** — steps 2 through 4 above, scoped to it. A target named by the user still has to be shown to be wrong before it is changed.
2. **Resolve the target to its repository and count the spread** per `kilic-workload-resolution`.
3. **Choose the layer** per `kilic-resource-placement`: the common layer when the change points the same way on every cluster running it, an override when one or two genuinely differ. A single-cluster override on a system component is a git edit to `argocd-root`'s `annotations.yml` plus regenerating and committing `argocd/1-manifest` — say so instead of pushing it down a layer.
   - **Generic wins.** Test the generic value across clusters first: the fleet maximum of the corrected figures, landing in the chart default or `.deploy/base/` even where the clusters differ in degree. Only a cluster that genuinely deviates earns a per-cluster override, on top of the generic value.
   - **Never an override duplicating the common value.** An existing override that restates it is deleted in the same change — a per-cluster config-reloader block restating a generic 16Mi is the usual case.
4. **Land it.** Branch with `git-branch`, commit with `git-commit`, open the merge request with `gitlab-mr-create`. One repository per merge request. Report the current values, the proposed values, and the evidence line behind each one.
5. **When the change spans repositories**, load the `linear-structure-agent` skill and shape it as an issueset — a parent issue with one sub-issue per repository — rather than one sprawling change.

### A Sweep Across Many Repositories

1. Enumerate the target group with `gitlab__list_group_projects`, including subgroups, and skip repositories with no workload component.
2. Shape the work through `linear-kilic`: a project, one shared sizing-matrix document, and one issue per repository. A delegated prompt points at the issue rather than repeating the matrix.
3. Fan the repositories out per `agent-plan`, each agent sampling Mimir live with the queries from `rightsize-signals` pasted into its prompt, patching, running `kustomize build` on its own diff, and opening its merge request.
4. Review each batch per `gitlab-mr-review` as it lands while the next batch runs.

## Output Shape

Discovery ends with a table. One row per container, evidence before numbers, because the evidence is what decides whether a row is worth acting on.

```markdown
## Rightsizing candidates: <scope>

| Workload | Container | Evidence | Current | Proposed | Repo |
|---|---|---|---|---|---|
| monitoring/loki-chunks-cache | memcached | OOMKilled 2x in 7d | mem 1Gi | mem 1536Mi | workloads/monitoring |

Skipped: 4 below materiality floor, 2 contradicted by usage, 6 short-lived Job pods.
```

State the skips. A list that silently drops two thirds of what it found reads as a complete answer.

## Pitfalls

- **Mimir and Loki's own components run in `namespace="monitoring-backbone"` on rubik, not `namespace="mimir"` or `namespace="monitoring"`.** Only the per-cluster `mimir-proxy-nginx` and `loki-proxy-nginx` relays stay in `monitoring`. A query scoped to the wrong namespace returns empty and reads as no data. Confirm the namespace with `grafana-kilic__list_prometheus_label_values(datasourceUid="<the cluster's mimir uid>", labelName="namespace")` — both arguments are required, and the label argument is `labelName`, not `label` — before trusting an empty 7d result.
- **Agents round DOWN to the nearest grid stop and apply raw samples literally.** 520m becomes `500m` and 674m becomes `675m` even when the prompt says round up. Hardcode the exact post-snap value in a delegated prompt, phrased as the target plus the rejected value.
- **Agents copy the per-series average from an older query.** The inflated request is the signature: a value several times the workload's typical working set, on a workload whose pods restarted in the window. Paste the query from `rightsize-signals` into the prompt, not a description of it.
- **A threshold false alarm does not need the full method.** When an alert fires on a misconfigured threshold rather than real pressure, size each component against its own usage plus reasonable headroom; a control-plane component gets a proportional bump and only the public-facing data plane earns the generous sizing.
- **Stage exact paths.** Never `git add -A` in an agent worktree; check `git status --short` before committing.

## Key Principles

1. **VPA opens the case, usage decides it.** A recommendation alone is never grounds for a change.
2. **OOM and sustained throttling are floors.** Never shrink below what killed or throttled a container, and raise the finding on its own merits.
3. **Tight, from the right query.** Requests from the busiest-pod time-weighted average, limits at the smallest grid stop at or above the 7d max, no multiplier.
4. **Discovery stops at a list.** Turning findings into changes is the user's call.
5. **ArgoCD resolves ownership.** Never infer the repository from a pod, namespace, or workload name.
6. **Generic wins.** Test one value across clusters first; only a genuinely deviating cluster earns an override, and an override duplicating the common value is deleted.
7. **Skips get reported.** Materiality and corroboration remove rows; silence about that overstates the answer.
8. **One repository per merge request**, and a multi-repository change gets the issueset shape.

## Examples

**User says:** "find rightsizing candidates on rubik"

1. Discovery mode. Scope is one cluster, so no scoping question needed.
2. Read the VPA outlier tables, OOM kills, and throttling for rubik.
3. Corroborate against 7d usage; drop what it contradicts.
4. Apply floors; note the skips.
5. Resolve survivors through ArgoCD to their repositories.
6. Present the ranked table, OOM rows first. Stop.

**Result:** A list the user can choose from, with the two OOMKilled containers called out as live problems rather than efficiency items.

---

**User says:** "rightsize loki-chunks-cache"

1. Implementation mode, but evidence first — pull VPA, usage, OOM and throttling for that container.
2. Evidence shows OOMKilled twice in 7d, so memory has a floor and must go up, not down.
3. Resolve through ArgoCD: `cluster/workloads/monitoring`, running on five clusters.
4. The memory pressure shows on every cluster, so the change belongs in `.deploy/base/`, not an overlay.
5. Present current versus proposed with the OOM evidence, then branch, commit, and open the merge request.

**Result:** One change in the common layer, with the kill count as its justification.
