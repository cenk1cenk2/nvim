# Annihilation

The contract shared by `agent-annihilate-handoff` and `agent-annihilate-pickup`. Handoff writes it into a Linear project; pickup executes it. Each rule here is stated once and both skills point at it.

## Roles

| Role | Who | Does |
|---|---|---|
| Owner | the session that wrote the handoff | creates the Linear project, writes its documents, runs the together-via-CLI steps with the user, answers escalations |
| Co-owners | every pickup crew session | executes the project and adjusts it: issues, sub-issues, relations, documents, always recording why |
| User | the captain | agrees names and decisions, runs or approves manual steps, merges every MR |

Crews are remote agents the user starts. Each starts from scratch: no conversation, no local state, only the Linear project and the skill catalog. A crew's goal is every MR created in the background and merge-ready. The user merges all of them.

## Blessing

- Handoff mode is the blessing to create and populate the Linear project that will be handed off.
- Pickup mode is the blessing, scoped to the project, to create branches, push, open and update MRs or PRs, and write issues, documents and relations.
- Merging is never blessed. Destructive actions, credentials and production applies keep their own gates.

## Delivery shape

| User's cue | Shape | Checkpoints |
|---|---|---|
| none | **Fewest MRs** (default): related work in one repository folded into one MR. | One, at completion or stand-down. |
| "step by step", "one at a time" | **Stepwise**: one stage at a time; the next stage starts after the user merges the previous one and says go. | One per stage. |
| "fully annihilate", "finish fast" | **Full push**: every MR opened as early as its dependencies allow. | One, at the end. |

- The charter records the shape. The crew never changes it on its own.
- **No shape is forced over dependencies.** Fewest MRs and full push never fold or open work across a real dependency.
- **Dependent work stacks.** A change that needs another change's code is branched from the prerequisite branch and its MR or PR targets that branch; load `git-branch` and the platform's PR/MR create skill for how.
- **Independent work runs in parallel** from the default branch.
- **Several units with mixed dependencies** are scheduled as a DAG; load `agent-plan` for it.
- **A release dependency** (an image, a package, a chart version) means the consumer MR is opened with the version it will need, marked waiting on the release, and its pipeline is re-run once the release exists.
- **Verification that needs a user step** (apply something, then look at the result) is a durable apply gate under the bounded-wait policy below. Prepare or open MRs independently of that deferred verification wherever their dependencies allow. In stepwise it closes the stage's checkpoint; otherwise it is the row right after the user step in the final table.
- **Merge order** follows the graph, is listed in the rollout document, and is mirrored by Linear `blocks` relations.

## Manual steps

Every step outside the crew's reach gets one class:

| Class | Who | When |
|---|---|---|
| IaC | an MR in the repository that already manages that kind of resource | preferred whenever the estate manages it as code |
| Together via CLI | the owner proposes the exact command, the user approves, the owner runs it | during handoff when the crew needs it to start (a repository must exist before a branch can), otherwise when the graph reaches it |
| User runs | the user alone | UI-only actions, credentials only the user holds |

Names are agreed with the user before any step runs: repositories, base branches, users and bots, channels, apps, hostnames, secret paths. Every together-via-CLI or user-runs step is a Linear issue assigned to the user, related as blocking what needs it, with the exact command or click path.

## Bounded waits and apply gates

This section owns annihilation's wait policy, including when composed postures or watcher guidance call for never idling, retrying, or re-arming. The charter records the budgets and gates; a more specific charter does not silently reset or widen them. Destructive actions, credentials, merges and applies retain their approval gates.

- **Human prerequisites are durable apply/rollout gates, not polling targets.** Credentials, UI actions, user approvals and user-run applies belong in the manual-step issue and rollout document with an owner, the exact action, the evidence that clears it, what it blocks, and the exact post-step verification command and expected result. Do not poll for them. Prepare and open all independently actionable MRs without crossing the gate; a missing prerequisite that prevents an MR or preview is reported as such.
- **Transient failures get an initial attempt plus TWO retries by default.** Runner outages, flaky tests, rate limits and registry/API/service timeouts consume the affected track's recorded budget. Fit retry delays to the cause and documented reset window. The same failure across new job ids still consumes the same budget. On exhaustion, suspend that track with attempt results, last authoritative evidence and the precise resume condition; keep independent tracks moving. A credential, permission or approval requirement is a gate, not a transient failure.
- **One bounded watcher per unchanged external condition.** Before arming, record the authoritative condition, evidence/version being watched, cadence, finite ceiling, remaining budget and action on success or expiry. Load `agent-background` when a permitted wait needs a watcher. A ceiling ends that wait: collect its outcome, retire it and suspend the track, rather than starting another timer. A failed watcher is diagnosed, not blindly replaced. Changed evidence relevant to the blocker or an explicit instruction is required to resume or authorize a new bounded wait; elapsed time, a different watcher name or an unchanged status is not new evidence.
- **Budgets survive turns, compaction and goal-timer wakes.** Persist attempts used/remaining, watcher handle and ceiling, latest evidence, suspension reason and resume condition in the charter's progress section as they change, before yielding. Restore that record before acting; do not infer a fresh budget from a new session, job id or wake. An existing goal-timer wake may read the authoritative prerequisite once and record the result, but does not reset budgets, restart blocked jobs or re-arm exhausted waits without changed evidence or explicit authorization. These skills create no competing scheduler and prescribe no invented goal CLI; scheduling stays with the runtime's existing facilities.
- **Active machine work keeps bounded completion coverage.** A running pipeline, release or deploy gets the appropriate bounded watcher unless the runtime already tracks and reports it. Runtime-tracked children need no redundant watcher: collect their completion through the runtime. Diagnose failed collection before redispatching. Count any retry against the existing failure budget; a new attempt does not erase prior failures.
- **Finish actionable work, then stand down honestly.** When only human prerequisites or exhausted waits remain, persist the gates and suspensions, reconcile issues/documents, issue the final table and retire watchers and agents after collecting their outcomes. Audit owned runtime state before claiming nothing remains armed. Do not terminate useful active machine work merely because another track is gated; finish or suspend it under its recorded budget first. Resume only on changed evidence or explicit instruction, with any new budget recorded before use.

## Documents

Linear documents on the project. Handoff writes them very detailed for agents that know nothing; pickup keeps them current.

- **Manifest**: the goal in one paragraph, scope and out of scope, every fixed decision with its reason, acceptance criteria as checkable statements.
- **Design**: components, the data flow between them, what each component owns, state and where it lives, concurrency, failure handling, what is deliberately left for later.
- **Implementation reference**: one section per integration and per component (each external service such as Slack or GitLab, the queue, the HTTP surface, configuration, deployment, CI). Each section names the sibling repositories that already do the same thing and the exact files to copy from, what to copy, and what to change. It states the estate's mechanisms and semantics the work must follow (how configuration is read and documented, how secrets reach the workload, how releases and deploys run). A section without a file reference is unfinished.
- **Configuration reference**: every setting with its default, its meaning, and where it is set (config map, secret store path, IaC file).
- **Rollout and manual steps**: the dependency graph with base branches, the merge order, and every manual step with the apply-gate fields above.
- **Crew charter**: per the template below.

## Delegation

The charter names one route for the project:

| Route | Use when | How |
|---|---|---|
| `harness` | the crew's runtime has tiers; the default | load `agent-delegate`; load `agent-harness` to resolve a tier to a model |
| `hyprpilot` | the work needs a runtime or profile the crew's harness lacks | load `hyprpilot-delegate`; the charter is the user's explicit ask for it |
| `none` | the project is too small to split | the crew lead implements |

Every sub-issue description ends with a `Delegate:` line. On `harness`: `cheap` for mechanical edits, renames and config wiring; `default` for implementation; `smart` for design-heavy, cross-repository or ambiguous work. On `hyprpilot`: the profile name.

## Investigations

Related ideas the user raises during planning (another source that could use the same mechanism, a follow-up integration) are folded into the same project as investigation issues, separate from the implementation issuesets. The charter says whether the crew researches them after the MRs are merge-ready or leaves them for the owner.

## Crew charter template

```markdown
# Crew charter

Delivery shape: <fewest MRs | stepwise | full push>
Checkpoints: <one at the end | one per stage: stage 1 = ..., stage 2 = ...>
Owner: <handoff session>. Co-owners: every pickup crew session (adjust issues, relations, documents; record why).

## Postures
Load agent-bulldozer, agent-coordinator and agent-bohrhammer immediately at pickup, before anything else.

## Delegation
Route: <harness | hyprpilot | none>
Why: <one line>
Tiers: on each sub-issue's `Delegate:` line.

## Dependency graph
| MR | Repository | Base branch | Depends on | Merge order |

## Manual steps and apply gates
| Issue | Class | Owner | Exact action | Needed before | Clearing evidence | Post-step verification command and expected result |

## Wait budgets and suspensions
Policy: agent-annihilation's bounded waits and apply gates take precedence over composed momentum and watcher rules.
| Track / condition | Evidence / version | Attempts used / remaining | Watcher handle, cadence and ceiling | On wake / expiry | Suspension reason | Resume condition |
<record budgets before use; update on every attempt, wake or suspension, before yielding; restore on resume without resetting them>

## Holds
<anything the crew must not do before a condition clears>

## Investigations
<research after merge-ready | leave for the owner>

## Final report
One table in merge/rollout order: every created or planned MR, base branch, source-check evidence, preview/pipeline status, user gate and resume condition; manual steps and exact post-step verification in between. Mark not-yet-created MRs explicitly. Report at completion or when only human prerequisites or suspended tracks remain; collect outcomes and retire watchers/agents before standing down.

## Progress
<updated by the crew at each checkpoint and whenever a gate, budget or suspension changes>
```

## Reporting

- **Tables only at checkpoints.** Between checkpoints a turn carries at most one line of momentum and no table.
- **At each checkpoint**: the report per `output-status`, the flow per `output-table`; update the charter's progress section on Linear.
- **At completion or stand-down**: one detailed final table, every row in the order the user acts. Stand-down with only gates or suspended tracks remaining is a checkpoint, not a claim that everything is finished.
  - every created or planned MR a row: link and title when it exists, repository, base branch, source-check evidence and separate preview/pipeline status; mark an MR not yet created rather than inventing a link;
  - distinguish code/source verified, merge-ready, user-gated, failed preview, unverified and not-yet-created work; a green source check does not make an unmet required preview green or prove merge-readiness;
  - every manual step a row between the merges it sits between, with its class, owner and clearing evidence;
  - every verification after a user step its own row, right after that step, with exact command, expected result and actual result or pending status;
  - release dependencies with their actual evidence or unmet status, not merely the producing MR's source checks;
  - under the table: what waits on the user, every deviation from the handoff with its issue, anything left unfinished with its reason and resume condition, and the audited disposition of watchers and agents.
