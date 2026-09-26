---
name: agent-plan
description: 'agent-plan Plan and execute multi-task work across agents as a dependency-aware DAG; layers run in parallel with review pauses between them. Modes: team, where the lead orchestrates, or fire-and-forget. Use on "run these in parallel", "fire and forget", "schedule these tasks". Not for a single task with no dependencies.'
argumentHint: '[plan file or goal] [optional: ''fire-and-forget'' | ''without worktrees'' | review cadence]'
references:
  - ../references/long-running-work.md
  - ../references/reconcile-state.md
  - ../references/plan-mode.md
  - ../references/agent/agent-delegate.md
  - ../references/agent/agent-worktrees.md
  - ../references/scm/scm-detect.md
  - ../references/project-tooling.md
  - ../references/agent/agent-write-plans.md
  - ../references/agent/agent-conventions.md
  - ../references/agent/agent-completion.md
  - ../references/agent/agent-plan-split.md
  - ./references/agent-merge-review.md
  - ../references/harness/provider-paths.md
  - ../references/identifier-legibility.md
  - ../references/harness/agent-delegate-harness-claude.md
  - ../references/harness/agent-delegate-harness-codex.md
  - ../references/harness/agent-delegate-harness-opencode.md
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## Agent DAG Orchestration

State that spans turns must be written durably per `long-running-work` — posture, armed watchers, and artifact truth do not survive a compaction or a handoff on their own.

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

> **ALWAYS enter plan mode for the planning and scheduling phases** — per `plan-mode`, unless the user asked you to plan with yourself.
>
> - Enter plan mode immediately.
> - Plan the work, build the dependency DAG, decide review cadence and mode.
> - Present the plan, the proposed layer schedule, and the resolved mode+cadence to the user for approval.
> - Exit plan mode only when launching layer 0.

The planning phase runs per `agent-plan-split`; the between-layer and end-of-run phases per `agent-merge-review`.

## Context

This skill takes a plan (explicit file or inferred from a goal), builds a dependency DAG from each task's `depends_on` field, partitions tasks into layers, and executes layer by layer. Within a layer, tasks run in parallel in isolated worktrees; between layers, worktrees merge back, review runs, and the user can inject guidance before the next layer starts.

**Two orthogonal axes** control behaviour:

- **Mode** (coordination model):
  - **`team` (default)** — every agent in the layer is dispatched **named**, so the lead can message it mid-run and it can answer. The lead orchestrates and stays in the loop between layers.
  - **`fire-and-forget`** — agents are dispatched **unnamed**, with no mid-run steering; the lead only collects their reports. Use when the layer needs no lead involvement mid-flight.

  In both modes **a layer is a barrier held by collecting every agent's completion** — never by the dispatch returning.

  **Note:** mode does not control permissions — the permission context is the session's, per `agent-delegate`.
- **Review cadence** (when `code-review-changes` runs):
  - **`per-layer` (default)** — review after each layer merges, before the next launches. Catches integration issues layer by layer.
  - **`per-task`** — implementer + reviewer pair for every task. Strictest. Use for risky refactors.
  - **`final-only`** — one review at the end against the run baseline. Fastest.

The DAG covers the flat shapes too, each with its natural cadence:
- All-parallel: one layer with N tasks + final-only cadence.
- All-sequential: N layers of 1 task + per-task cadence.
- Mixed DAGs (most real work): 2–4 layers of 1–4 tasks each + per-layer cadence.

## Mode & Cadence Resolution

Detect both axes from the user's wording before leaving plan mode.

**Mode:**

| User wording | Resolved mode |
|--------------|---------------|
| nothing specified, "team", "with approval", "supervised", "lead orchestrates" | `team` (default) |
| "fire and forget", "anonymous", "no lead involvement", "fire", "fire-and-forget", "autonomous" | `fire-and-forget` |

**Review cadence:**

| User wording | Resolved cadence |
|--------------|------------------|
| nothing specified, "per-layer", "review between layers" | `per-layer` (default) |
| "per-task", "gated review", "review every task", "tight gates" | `per-task` |
| "final-only", "quick run", "no per-layer review", "one review" | `final-only` |

Present both resolutions in the plan summary. If either is ambiguous, default to the safer choice (`team` / `per-layer`) and state that explicitly.

## Process

### Steps 1–4 — Planning

Follow the `agent-plan-split` reference steps 1–4: understand the goal, discover tooling, establish conventions, write the plan. The plan must include a `depends_on: [task-id, ...]` field on each task (empty/absent = layer 0).

- Repository and code discovery when planning starts from an organization-wide question or the target repository is not yet known: a code-discovery MCP when the active profile has one, otherwise the workspace SCM tools, saying which. When that MCP is Sourcebot, load `sourcebot-discovery` before the first call.
- SCM platform detection and raw `git` CLI usage: `scm-detect`.
- Verification commands: `project-tooling`.
- Project conventions, discovered and agreed before any dispatch: `agent-conventions`.
- Plan quality criteria, including the optional `depends_on` field on tasks: `agent-write-plans`.
- When the input is Linear — issues or a project — load `linear-pickup`; task splits align with issue boundaries per `linear-chunk-issues`, and state moves follow `linear-state-transitions`.

### Step 5 — Build the schedule

Build the layer schedule per `agent-plan-split` step 6 — the layer formula, the within-layer collision check (flagged to the user, never auto-resolved), and the layer-by-layer table.

### Step 6 — Present the schedule

- Show the proposed layer table plus the resolved mode and review cadence.
- User approves or adjusts (reshuffle layers, change mode, change cadence, add/remove tasks).
- Iterate until approved.

> **Tip:** Want a second opinion on the DAG before launching? Suggest to the user: *"Invoke `/agent-review dag` with the schedule above to dispatch a reviewer (it picks the tier from the DAG's size and coupling)."* This is a nudge, not a step — the user decides whether to act on it.

### Step 7 — Decide agent count per layer

Per `agent-plan-split` step 7 — one agent per task, a later layer's task steered to the named agent that did its dependency while it is still reachable, and a tier per task resolved by loading `agent-harness`.

### Step 8 — Launch the first layer

> **Fetch `agent-delegate-harness-<provider>` before the first dispatch.** A missed read is silent, and whether blocking exists, how a finished agent's report arrives, and whether the prompt needs a delivery instruction are exactly what varies.

- Exit plan mode.
- Record the **run-level baseline** (current branch + HEAD) for the final review pass.
- For layer 0, the **layer baseline** = run baseline.
- Transition each Linear-linked task in this layer to `In Progress` per `linear-state-transitions`. Report one line per id (`Linear state: moved K-xxx → In Progress (was Todo).`).

**Team mode (default):**

- Spawn all teammates for this layer in a single message with multiple subagent dispatches. For each:
  - Worktree isolation (unless user opted out).
  - A name — that is what makes a teammate addressable for mid-run steering and for its own report. There is no team-creation step and no team parameter.
  - A delivery instruction naming the recipient, only where `agent-delegate-harness-<provider>` says the runtime needs one — without it there, the report is lost and the layer cannot close.
  - A general-purpose agent type.

**Fire-and-forget mode:**

- Spawn all agents for this layer in a single message with multiple subagent dispatches. For each:
  - Worktree isolation (unless user opted out).
  - No name.
  - Where the runtime offers blocking dispatch, block explicitly, so the dispatch itself holds the barrier; otherwise the barrier is held by collection, as in team mode.
  - A general-purpose agent type.

**Per-task cadence override:** if the user chose `per-task` cadence, each layer still runs in parallel, but every task is implemented + reviewed by a pair (two dispatches — one implementer, one reviewer) before the layer considers itself done. See the "Per-Task Review Pattern" section below. This is heavier than per-layer review.

**Shared:**

- Dispatch parameters and mechanics per `agent-delegate`; load the `agent-harness` skill to resolve tiers to concrete models.
- Verify each returned worktree path per `agent-worktrees`; the concrete plans directory resolves via `provider-paths`, never hardcoded.
- Each agent prompt is self-contained. Use the template below. Include the running `## Accumulated Guidance` section (empty for layer 0).

### Step 9 — Collect layer results

- **The layer closes when every agent's completion has been collected**, per `agent-delegate`. A pending agent is still running — never pre-empt it, and never read its silence as a failure.
- Review each agent's result. Handle statuses (DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED) per `agent-delegate`.
- If any task fails or is BLOCKED: **finish the in-flight layer, then halt before the next layer.** Surface all failures to the user in the same turn, with a consolidated summary. Wait for user guidance — do not retry or auto-advance.

### Step 10 — Merge this layer's worktrees

Per `agent-merge-review` step 1: merge sequentially, conflicts go to the user, worktrees removed without silent force.

### Step 11 — Review this layer

Per `agent-merge-review` step 2, against the **layer baseline** recorded before this layer's launch; the resolved cadence decides whether a layer review runs.

### Step 12 — Pause for user guidance

- Present a brief layer summary: tasks completed, review findings, next layer preview.
- Allow the user to provide corrections, revised requirements, or style feedback based on what they've seen.
- **Append all user guidance to a running `## Accumulated Guidance` section**, which grows across layers. Every subsequent agent prompt includes this section verbatim — later layers benefit from everything learned earlier.

### Step 13 — Launch the next layer (loop)

- Record the next layer's baseline (current HEAD after this layer's merges).
- Loop back to step 8 for layer N+1 with updated accumulated guidance, fresh Linear transitions, and the same mode+cadence flags.

### Step 14 — Final review, verification, handoff

Per `agent-merge-review` steps 2–4 — the end-of-run review against the **run-level baseline** recorded in step 8, final verification with evidence, and the completion handoff.

### Step 15 — Shutdown (team mode only)

- Send each teammate a shutdown request through the runtime's messaging channel, per `agent-delegate-harness-<provider>`, and wait for the confirmations.
- Ensure every agent worktree tied to this team has been removed.
- Confirm every teammate is stopped — collect before you reap, per `agent-delegate`.

Fire-and-forget mode has no shutdown — agents exit on their own when their task completes.

## Worktree Mode

Worktree mode is the **default**. Every agent in every layer runs in its own worktree, created and removed per `agent-worktrees`. Worktree lifetime is one layer: created at layer launch, merged+removed at layer end.

**When to skip worktrees (user must opt out with "without worktrees" or "same worktree"):**
- Tasks are small and low-risk.
- The overhead of per-layer merging is not worth it.

## Agent Prompt Template

Each agent receives a self-contained prompt:

```
You are agent [N] in layer [L] of [total] working on: [high-level goal].

## Your Task

[Detailed task description]

## Your Files (write scope)

- path/to/file1.ext
- path/to/file2.ext

## Context

[Relevant codebase context — architecture, patterns, conventions, what earlier layers produced]

## Boundaries

Do NOT modify files outside your write scope. Other agents in this layer:
- Agent [X]: [brief description]

## Conventions — match the house style

[The filled-in prompt block from `agent-conventions`, verbatim.]

## Accumulated Guidance

[Running list of user corrections and feedback from previous layers. Empty for layer 0. Grows with each layer.]

## Verification Commands

[Commands discovered in planning — run these after implementation to confirm your work.]

## Report

State which files you used as your pattern reference, and anything you had to invent for lack of local precedent. Then report one of:
- **DONE** — implemented and verified.
- **DONE_WITH_CONCERNS** — implemented but [describe concern].
- **NEEDS_CONTEXT** — cannot proceed without [what's missing].
- **BLOCKED** — cannot complete because [reason].
```

**Team mode additions:** Replace "agent" with "teammate" throughout. Append:

```
## Coordination

- Send a message to the lead if you are blocked or need a decision.
```

## Per-Task Review Pattern (when cadence is `per-task`)

For each task in a layer (still parallel across tasks within the layer):

1. Dispatch implementer. Collect its completion.
2. Handle implementer status. If DONE, get git diff since task started.
3. Dispatch reviewer with the diff + task spec. Collect its completion.
4. If reviewer finds issues: dispatch a fresh implementer with the original prompt + `## Issues to Fix` section. Re-review after the fix. Repeat until APPROVED.
5. Run verification commands after the layer's per-task loops all pass.

Per-task cadence is heavier — use it only when the task is risky (complex refactors, tricky logic, security-sensitive code).

**Review Prompt Template:**

```
Review the implementation of task [N]: [task name].

## What was implemented
[Brief description.]

## Requirements
[Task spec — what it should do.]

## Diff
[Git diff of changes since task started.]

## Review checklist
1. Does the code do what the spec says? No more, no less.
2. Are there bugs, missing edge cases, or error handling gaps?
3. Does it follow existing codebase patterns?
4. Are tests adequate (if the project has tests)?

Report: APPROVED or list specific issues to fix.
```

## Model Selection

A tier per agent, including review subagents under per-task cadence, per `agent-delegate` Model Selection.

## The Run Board

Between layers, show where the run actually is - brief, current state only:

| Layer | Tasks | State | Worktrees |
|---|---|---|---|
| 1 | 3 | done | merged, removed |
| 2 | 2 | running | `task-04-a3f`, `task-05-b91` live |
| 3 | 4 | blocked on layer 2 | not created |

**Worktrees is the column that matters** — a worktree still listed after its layer merged is orphaned work, and nothing else in the run will tell you.

## Reaping Between Layers

**Reap each layer's agents before launching the next.** A DAG run accumulates agents fastest of anything here, and a layer boundary is exactly where stale ones do damage: an unreaped agent from layer N can still be writing while layer N+1 starts, and two concurrent writers on one file clobber each other silently. Worktree cleanup is not the same as agent cleanup — do both.

Reap an agent when it delivered and its layer merged, when its task was superseded or dropped from the plan, or when you are re-dispatching it after a failed review — **reap before the re-dispatch**, never alongside it — collecting first, per `agent-delegate` Reaping.

At the end of the run, and at every layer boundary, enumerate what is still alive and confirm each is stopped or *deliberately* still running with a stated reason.

## Key Principles

- **Reap each layer before the next launches.** Stale agents from a merged layer can still write and collide with the new one; a live agent list you cannot account for means you do not know what the run is doing.
- **DAG is the default model.** All-parallel and all-sequential are just degenerate shapes of a DAG — write plans with `depends_on` so the scheduler works correctly.
- **Non-overlapping within a layer is non-negotiable.** Two agents in the same layer writing the same file = garbage output. Fix the split before launch.
- **Per-layer merge is mandatory when layers have dependencies.** Layer N+1 must branch from the post-layer-N state to see earlier work.
- **Team mode is the default.** Opt into fire-and-forget explicitly.
- **Per-layer review is the default.** Opt into per-task (stricter) or final-only (faster) explicitly.
- **Finish-layer-halt on failure.** Never auto-advance past a failed layer without user guidance.
- **Accumulated guidance compounds.** User feedback between layers folds into every subsequent agent prompt.
- **Worktrees are the default.** Opt out with "without worktrees".
- **Verify before claiming completion.** Read verification output; paste evidence. "Should pass" is not evidence.
- **Don't trust agent success reports.** Check the VCS diff to verify agents actually made the expected changes.
- **Clean shutdown is mandatory in team mode.** Collect every teammate's report first, then send shutdown requests and confirm each one stopped.

## Red Flags

- Starting a layer without recording its baseline.
- Defaulting to fire-and-forget without the user explicitly asking.
- Defaulting to `final-only` review when per-layer would catch integration issues earlier.
- Auto-advancing past a failed or BLOCKED task.
- Auto-resolving merge conflicts between layers.
- Force-removing a worktree silently when removal fails.
- Trusting agent "success" reports without verifying the diff.
- Assuming verification commands without checking the project's actual tooling.
- Starting implementation on main/master without explicit user consent.
- Skipping the team shutdown step when in team mode.

## Related Skills

- **`agent-delegate`** — for single-task, one-shot delegation to one agent at a user-chosen tier/model. Use when the work fits one agent and doesn't warrant a plan + DAG.
- **`code-review-changes`** — invoked per-layer (default cadence) and at end-of-run for integration review.
- **`agent-review`** — dispatch a reviewer to cross-check the DAG before launching. Suggested after step 6 (optional).
