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
| none | **Fewest MRs** (default): related work in one repository folded into one MR. | One, when every MR is merge-ready. |
| "step by step", "one at a time" | **Stepwise**: one stage at a time; the next stage starts after the user merges the previous one and says go. | One per stage. |
| "fully annihilate", "finish fast" | **Full push**: every MR opened as early as its dependencies allow. | One, at the end. |

- The charter records the shape. The crew never changes it on its own.
- **No shape is forced over dependencies.** Fewest MRs and full push never fold or open work across a real dependency.
- **Dependent work stacks.** A change that needs another change's code is branched from the prerequisite branch and its MR or PR targets that branch; load `git-branch` and the platform's PR/MR create skill for how.
- **Independent work runs in parallel** from the default branch.
- **Several units with mixed dependencies** are scheduled as a DAG; load `agent-plan` for it.
- **A release dependency** (an image, a package, a chart version) means the consumer MR is opened with the version it will need, marked waiting on the release, and its pipeline is re-run once the release exists.
- **Verification that needs a user step** (apply something, then look at the result) waits until the user's step. It never stops MRs from being prepared or opened. In stepwise it closes the stage's checkpoint; otherwise it is the row right after the user step in the final table.
- **Merge order** follows the graph, is listed in the rollout document, and is mirrored by Linear `blocks` relations.

## Manual steps

Every step outside the crew's reach gets one class:

| Class | Who | When |
|---|---|---|
| IaC | an MR in the repository that already manages that kind of resource | preferred whenever the estate manages it as code |
| Together via CLI | the owner proposes the exact command, the user approves, the owner runs it | during handoff when the crew needs it to start (a repository must exist before a branch can), otherwise when the graph reaches it |
| User runs | the user alone | UI-only actions, credentials only the user holds |

Names are agreed with the user before any step runs: repositories, base branches, users and bots, channels, apps, hostnames, secret paths. Every together-via-CLI or user-runs step is a Linear issue assigned to the user, related as blocking what needs it, with the exact command or click path.

## Documents

Linear documents on the project. Handoff writes them very detailed for agents that know nothing; pickup keeps them current.

- **Manifest**: the goal in one paragraph, scope and out of scope, every fixed decision with its reason, acceptance criteria as checkable statements.
- **Design**: components, the data flow between them, what each component owns, state and where it lives, concurrency, failure handling, what is deliberately left for later.
- **Implementation reference**: one section per integration and per component (each external service such as Slack or GitLab, the queue, the HTTP surface, configuration, deployment, CI). Each section names the sibling repositories that already do the same thing and the exact files to copy from, what to copy, and what to change. It states the estate's mechanisms and semantics the work must follow (how configuration is read and documented, how secrets reach the workload, how releases and deploys run). A section without a file reference is unfinished.
- **Configuration reference**: every setting with its default, its meaning, and where it is set (config map, secret store path, IaC file).
- **Rollout and manual steps**: the dependency graph with base branches, the merge order, every manual step with its class, exact command or click path, the moment it is needed, and the verification after it.
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

## Manual steps
| Issue | Class | What | Needed before | Verification after |

## Holds
<anything the crew must not do before a condition clears>

## Investigations
<research after merge-ready | leave for the owner>

## Final report
One table: every MR in merge order with base branch and check; manual steps and the verification after each in between.

## Progress
<updated by the crew at each checkpoint>
```

## Reporting

- **Tables only at checkpoints.** Between checkpoints a turn carries at most one line of momentum and no table.
- **At each checkpoint**: load `output-status` for the report and `output-table` for the flow; update the charter's progress section on Linear.
- **When everything is finished**: one detailed final table, every row in the order the user acts.
  - every MR a row: its link and title, repository, base branch, and the check that proves it merge-ready;
  - every manual step a row between the merges it sits between, with its class;
  - every verification after a user step its own row, right after that step;
  - release dependencies as the check of the MR that produces them;
  - under the table: what waits on the user, every deviation from the handoff with its issue, anything left unfinished with its reason.
