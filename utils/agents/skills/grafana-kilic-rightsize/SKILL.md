---
name: grafana-kilic-rightsize
description: grafana-kilic-rightsize Find and apply container rightsizing from VPA outliers, OOM kills, throttling and a week of usage, resolving each candidate to the repository and layer that owns it. Use on "find rightsizing candidates", "rightsize this workload". Not for replica counts, HPA tuning, or node sizing.
disableModelInvocation: true
argumentHint: '[candidates|target] - e.g. ''find candidates on rubik'', ''rightsize loki-chunks-cache'''
references:
  - ../references/kilic-workload-resolution.md
  - ../references/kilic-resource-placement.md
  - ./references/rightsize-signals.md
  - ../references/output-diff.md
---

## Container Rightsizing

Uses the `grafana-kilic` MCP server for metrics, `argocd-kilic` to resolve a workload to the repository that owns it, and `gitlab` for the change itself. Signals, weights, thresholds, and queries: `rightsize-signals`.

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

## Process

### Discovery

1. **Scope it.** Which clusters. Absent an answer, ask once — there is no fleet-wide datasource, so every cluster is a separate sweep and "all of them" is a real cost.
2. **Read the outliers**, per `rightsize-signals`. Start from the VPA outlier tables, then pull OOM kills and throttling for the same scope. The tables cap at 25 rows, so a quiet table means nothing ranked highly, never that the cluster is clean.
3. **Corroborate each candidate against 7d usage.** Drop the ones usage contradicts, and say how many were dropped.
4. **Apply the materiality floors.** Below them the change is not worth a restart. Report what was skipped and why rather than dropping it silently.
5. **Resolve each survivor to its repository**, per `kilic-workload-resolution` — ArgoCD is the authority, never the name.
6. **Rank and present**, heaviest evidence first: OOM kills, then sustained throttling, then size deltas by magnitude. Stop here.

### Implementation

1. **Gather the evidence for the named target** — steps 2 through 4 above, scoped to it. A target named by the user still has to be shown to be wrong before it is changed.
2. **Resolve the target to its repository and count the spread** per `kilic-workload-resolution`.
3. **Choose the layer** per `kilic-resource-placement`: the common layer when the change points the same way on every cluster running it, an override when one or two genuinely differ. A single-cluster override on a system component is a **Vault** write, not a commit — say so instead of pushing it down a layer.
4. **Present the change** per `output-diff`: the current values, the proposed values, and the evidence line behind each one.
5. **Land it.** Branch with `git-branch`, commit with `git-commit`, open the merge request with `gitlab-mr-create`. One repository per merge request.
6. **When the change spans repositories**, load the `linear-structure-agent` skill and shape it as a parent issue with one sub-issue per repository, rather than one sprawling change.

## Output Shape

Discovery ends with a table. One row per container, evidence before numbers, because the evidence is what decides whether a row is worth acting on.

```markdown
## Rightsizing candidates: <scope>

| Workload | Container | Evidence | Current | Proposed | Repo |
|---|---|---|---|---|---|
| monitoring/loki-chunks-cache | memcached | OOMKilled 2x in 7d | mem 1Gi | mem 1.5Gi | workloads/monitoring |

Skipped: 4 below materiality floor, 2 contradicted by usage, 6 short-lived Job pods.
```

State the skips. A list that silently drops two thirds of what it found reads as a complete answer.

## Key Principles

1. **VPA opens the case, usage decides it.** A recommendation alone is never grounds for a change.
2. **OOM and sustained throttling are floors.** Never shrink below what killed or throttled a container, and raise the finding on its own merits.
3. **Discovery stops at a list.** Turning findings into changes is the user's call.
4. **ArgoCD resolves ownership.** Never infer the repository from a pod, namespace, or workload name.
5. **Common case in the common layer, outliers as overrides.** An override duplicating the common value is drift waiting to happen.
6. **Skips get reported.** Materiality and corroboration remove rows; silence about that overstates the answer.
7. **One repository per merge request**, and a multi-repository change gets the parent and sub-issue shape.

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
