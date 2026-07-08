---
name: agents-plan
description: Plan work and execute it across agents using a dependency-aware DAG scheduler. Builds layers from task `depends_on` declarations plus file-overlap verification; runs each layer in parallel, pauses between layers for review and user guidance. Default mode is "team" (lead orchestrates, permissions bubble up); "fire-and-forget" mode opts into autonomous execution with bypass permissions. Use when user says "agents-plan", "run these tasks", "execute this plan", "run in parallel", "split into agents", "sequential agents", "create a team", "fire and forget", "agents-parallel", "agents-sequential". Do NOT use for single-task one-shot delegation (use /agents-delegate).
disable-model-invocation: true
argument-hint: "[plan file or goal] [optional: 'fire' | 'fire-and-forget' | 'without worktrees' | 'per-task review' | 'final-only review']"
references:
  - ../references/agents-delegate.md
  - ../references/agents-worktrees.md
  - ../references/scm-detect.md
  - ../references/sourcebot-discovery.md
  - ../references/project-tooling.md
  - ../references/agents-write-plans.md
  - ../references/agents-conventions.md
  - ../references/agents-completion.md
  - ../references/agents-plan-split.md
  - ../references/agents-merge-review.md
  - ../references/commit-style.md
  - ../references/commit-trailers.md
  - ../references/linear-chunk-issues.md
  - ../references/linear-state-transitions.md
---

## Agent DAG Orchestration

> **ALWAYS enter plan mode for the planning and scheduling phases.**
>
> - Enter plan mode immediately.
> - Plan the work, build the dependency DAG, decide review cadence and mode.
> - Present the plan, the proposed layer schedule, and the resolved mode+cadence to the user for approval.
> - Exit plan mode only when launching layer 0.

> Read the `agents-plan-split` reference for the planning phase — understand goal, discover tooling, establish conventions, write the plan. Also covers `depends_on` declarations, layer assignment, and file-overlap verification.
> Read the `agents-merge-review` reference for between-layer and end-of-run phases — per-layer worktree merge, per-layer review, final `code-review-changes` against the run-level baseline, final verification, completion handoff.
> Read the `agents-delegate` reference for agent dispatch parameters, tier selection (cheap/default/smart), ecosystem model mappings, and user shorthand.
> Read the `agents-worktrees` reference for the mandatory worktree location rule (`.claude/worktrees/<name>/`), naming, verification, and cleanup — agent worktrees MUST live there, no exceptions.
> Read the `scm-detect` reference for git MCP tools and CLI fallbacks.
> Read the `sourcebot-discovery` reference when planning starts from an organization-wide question or the target repository is not yet known.
> Read the `project-tooling` reference for discovering verification commands.
> Read the `agents-write-plans` reference for plan quality criteria — including the optional `depends_on` field on tasks.
> Read the `agents-conventions` reference for discovering and agreeing on project conventions before dispatching agents.
> Read the `agents-completion` reference for the completion handoff after verification passes.
> Read the `commit-style` reference for conventional commit format — used during handoff and per-task commits.
> Read the `commit-trailers` reference for issue linking conventions — used when commits reference Linear/GitHub/GitLab issues.
> Read the `linear-chunk-issues` reference for aligning task splits with Linear issues — used when the user provides Linear issues or a project as input.
> Read the `linear-state-transitions` reference for the auto-advance rules. Applied before each layer's launch — each Linear-linked task in the launching layer advances to `In Progress`.

## Context

This skill takes a plan (explicit file or inferred from a goal), builds a dependency DAG from each task's `depends_on` field, partitions tasks into layers, and executes layer by layer. Within a layer, tasks run in parallel in isolated worktrees; between layers, worktrees merge back, review runs, and the user can inject guidance before the next layer starts.

**Two orthogonal axes** control behaviour:

- **Mode** (permission model):
  - **`team` (default)** — `TeamCreate` coordinates the run. Permission requests bubble up to the lead (you) for interactive approval. Lead orchestrates.
  - **`fire-and-forget`** — agents dispatch with `mode: "bypassPermissions"`. No team coordination. Autonomous execution.
- **Review cadence** (when `code-review-changes` runs):
  - **`per-layer` (default)** — review after each layer merges, before the next launches. Catches integration issues layer by layer.
  - **`per-task`** — implementer + reviewer pair for every task. Strictest. Use for risky refactors.
  - **`final-only`** — one review at the end against the run baseline. Fastest.

The DAG subsumes the degenerate shapes:
- All-parallel: one layer with N tasks + final-only cadence.
- All-sequential: N layers of 1 task + per-task cadence.
- Mixed DAGs (most real work): 2–4 layers of 1–4 tasks each + per-layer cadence.

## Mode & Cadence Resolution

Detect both axes from the user's wording before leaving plan mode.

**Mode:**

| User wording | Resolved mode |
|--------------|---------------|
| nothing specified, "team", "with approval", "supervised", "lead orchestrates" | `team` (default) |
| "fire and forget", "anonymous", "bypass permissions", "fire", "fire-and-forget", "autonomous" | `fire-and-forget` |

**Review cadence:**

| User wording | Resolved cadence |
|--------------|------------------|
| nothing specified, "per-layer", "review between layers" | `per-layer` (default) |
| "per-task", "gated review", "review every task", "tight gates" | `per-task` |
| "final-only", "quick run", "no per-layer review", "one review" | `final-only` |

Present both resolutions in the plan summary. If either is ambiguous, default to the safer choice (`team` / `per-layer`) and state that explicitly.

## Process

### Steps 1–4 — Planning

Follow the `agents-plan-split` reference steps 1–4: understand the goal, discover tooling, establish conventions, write the plan. The plan must include a `depends_on: [task-id, ...]` field on each task (empty/absent = layer 0).

### Step 5 — Build the schedule

Follow the `agents-plan-split` reference's "Task dependencies" section:

- Read each task's `depends_on`. Compute the layer for each task: `layer(task) = max(layer(dep) for dep in depends_on) + 1`, or `0` if `depends_on` is empty.
- Group tasks by layer. Within each layer, verify no two tasks write to the same file. If overlap exists, flag it to the user — propose promoting one task to a later layer, splitting the overlap into a new task, or merging the two conflicting tasks. Do NOT auto-resolve.
- Output the schedule as a layer-by-layer table:

  | Layer | Task | Depends on | Files (write) |
  |-------|------|-----------|---------------|
  | 0 | task-a | — | src/foo.ts |
  | 0 | task-b | — | src/bar.ts |
  | 1 | task-c | task-a | src/foo-test.ts |

### Step 6 — Present the schedule

- Show the proposed layer table plus the resolved mode and review cadence.
- User approves or adjusts (reshuffle layers, change mode, change cadence, add/remove tasks).
- Iterate until approved.

> **Tip:** Want a second opinion on the DAG before launching? Suggest to the user: *"Invoke `/agents-review dag` with the schedule above to dispatch a reviewer (cheap by default)."* This is a nudge, not a step — the user decides whether to act on it.

### Step 7 — Decide agent count per layer

- Number of agents in a layer = number of tasks in that layer.
- 2–4 tasks per layer is the sweet spot. If a layer has >4 tasks, consider whether any should be merged; if a layer has 1 task, that's fine (sequential point in the DAG).

### Step 8 — Launch the first layer

- Exit plan mode.
- Record the **run-level baseline** (current branch + HEAD) for the final review pass.
- For layer 0, the **layer baseline** = run baseline.
- Transition each Linear-linked task in this layer to `In Progress` per the `linear-state-transitions` reference. Report one line per id (`Linear state: moved K-xxx → In Progress (was Todo).`).

**Team mode (default):**

- Create the team with `TeamCreate({ team_name, description })` on the very first layer only (reused across layers).
- Spawn all teammates for this layer in a single message with multiple `Agent` tool uses. For each:
  - `isolation: "worktree"` (unless user opted out).
  - `team_name` set to the team created above.
  - No `bypassPermissions` — permissions bubble up.
  - No `run_in_background` — blocking dispatch.
  - `subagent_type: "general-purpose"`.

**Fire-and-forget mode:**

- No `TeamCreate`.
- Spawn all agents for this layer in a single message with multiple `Agent` tool uses. For each:
  - `isolation: "worktree"` (unless user opted out).
  - `mode: "bypassPermissions"`.
  - No `run_in_background` — blocking dispatch.
  - `subagent_type: "general-purpose"`.

**Per-task cadence override:** if the user chose `per-task` cadence, each layer still runs in parallel, but every task is implemented + reviewed by a pair (two dispatches — one implementer, one reviewer) before the layer considers itself done. See the "Per-Task Review Pattern" section below. This is heavier than per-layer review.

**Shared:**

- Verify each returned worktree path is absolute and under `<project_root>/.claude/worktrees/` per the `agents-worktrees` reference.
- Each agent prompt is self-contained. Use the template below. Include the running `## Accumulated Guidance` section (empty for layer 0).

### Step 9 — Collect layer results

- Blocking dispatch — this turn pauses until every agent in the layer returns.
- Review each agent's result. Handle statuses (DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED) per the standard conventions.
- If any task fails or is BLOCKED: **finish the in-flight layer, then halt before the next layer.** Surface all failures to the user in the same turn, with a consolidated summary. Wait for user guidance — do not retry or auto-advance.

### Step 10 — Merge this layer's worktrees

Follow the `agents-merge-review` reference "Merge worktrees (per-layer)" section:

- Merge each layer worktree's branch back to the active branch sequentially.
- On merge conflicts: present to user, wait for resolution decision, do NOT auto-resolve.
- Remove each worktree via `git worktree remove`. Surface failures; do not force-remove silently.

### Step 11 — Review this layer

- If cadence is `per-layer`: run `code-review-changes` against the **layer baseline** (recorded before this layer's launch). This catches integration issues between parallel tasks within the layer.
- If cadence is `per-task`: the per-task reviewer already ran during step 8; no separate layer review.
- If cadence is `final-only`: skip layer review; review happens only at end of run.

Present findings. If the reviewer flags issues, fix them (directly or via a corrective agent) before proceeding.

### Step 12 — Pause for user guidance

- Present a brief layer summary: tasks completed, review findings, next layer preview.
- Allow the user to provide corrections, revised requirements, or style feedback based on what they've seen.
- **Append all user guidance to a running `## Accumulated Guidance` section**, which grows across layers. Every subsequent agent prompt includes this section verbatim — later layers benefit from everything learned earlier.

### Step 13 — Launch the next layer (loop)

- Record the next layer's baseline (current HEAD after this layer's merges).
- Loop back to step 8 for layer N+1 with updated accumulated guidance, fresh Linear transitions, and the same mode+cadence flags.

### Step 14 — Final review, verification, handoff

Follow the `agents-merge-review` reference steps 2–4:

- **Final review.** Run `code-review-changes` against the **run-level baseline** (recorded in step 8 for layer 0). This catches cross-layer integration issues regardless of cadence choice.
- **Final verification.** Run the full verification command set from the planning phase. Read the output. Confirm with evidence.
- **Completion handoff.** Summarize and present options (commit / push / PR / leave); execute the user's choice per the `agents-completion` reference.

### Step 15 — Shutdown (team mode only)

- Send shutdown requests to all teammates: `SendMessage({ to: "<name>", message: { type: "shutdown_request" } })`.
- Wait for shutdown confirmations.
- Ensure every `.claude/worktrees/<name>/` tied to this team has been removed.
- Clean up with `TeamDelete`.

Fire-and-forget mode has no shutdown — agents exit on their own when their task completes.

## Worktree Mode

Worktree mode is the **default**. Every agent in every layer runs in its own worktree under `.claude/worktrees/`. Worktree lifetime is one layer: created at layer launch, merged+removed at layer end.

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

## Conventions

[Project-specific conventions — naming, style, patterns]

## Accumulated Guidance

[Running list of user corrections and feedback from previous layers. Empty for layer 0. Grows with each layer.]

## Verification Commands

[Commands discovered in planning — run these after implementation to confirm your work.]

## Report

When done, report one of:
- **DONE** — implemented and verified.
- **DONE_WITH_CONCERNS** — implemented but [describe concern].
- **NEEDS_CONTEXT** — cannot proceed without [what's missing].
- **BLOCKED** — cannot complete because [reason].
```

**Team mode additions:** Replace "agent" with "teammate" throughout. Append:

```
## Coordination

- Check the shared task list after completing each task for new work.
- Mark tasks as completed via TaskUpdate when done.
- Send a message to the lead if you are blocked or need a decision.
```

## Per-Task Review Pattern (when cadence is `per-task`)

For each task in a layer (still parallel across tasks within the layer):

1. Dispatch implementer. Wait.
2. Handle implementer status. If DONE, get git diff since task started.
3. Dispatch reviewer with the diff + task spec. Wait.
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

See the `agents-delegate` reference for tier definitions, ecosystem mappings, user shorthand, and mismatch handling. Per-agent, pick a tier based on task complexity and resolve to a concrete model:

- **Anthropic via `Agent` tool:** cheap → `haiku`, default → `sonnet`, smart → `opus` (also for review subagents under per-task cadence).
- **Other ecosystems:** user declares the tier mapping.
- **Explicit model names from the user** override tiers — use verbatim.
- **Mismatched choices:** ask before dispatching.

## Key Principles

- **DAG is the default model.** All-parallel and all-sequential are just degenerate shapes of a DAG — write plans with `depends_on` so the scheduler works correctly.
- **Non-overlapping within a layer is non-negotiable.** Two agents in the same layer writing the same file = garbage output. Fix the split before launch.
- **Per-layer merge is mandatory when layers have dependencies.** Layer N+1 must branch from the post-layer-N state to see earlier work.
- **Team mode is the default.** Opt into fire-and-forget explicitly. Permission bubbling is safer than bypass.
- **Per-layer review is the default.** Opt into per-task (stricter) or final-only (faster) explicitly.
- **Finish-layer-halt on failure.** Never auto-advance past a failed layer without user guidance.
- **Accumulated guidance compounds.** User feedback between layers folds into every subsequent agent prompt.
- **Worktrees are the default.** Opt out with "without worktrees".
- **Verify before claiming completion.** Read verification output; paste evidence. "Should pass" is not evidence.
- **Don't trust agent success reports.** Check the VCS diff to verify agents actually made the expected changes.
- **Clean shutdown is mandatory in team mode.** Always send shutdown requests and call `TeamDelete` when done.

## Red Flags

- Starting a layer without recording its baseline.
- Defaulting to fire-and-forget without the user explicitly asking.
- Defaulting to `final-only` review when per-layer would catch integration issues earlier.
- Auto-advancing past a failed or BLOCKED task.
- Auto-resolving merge conflicts between layers.
- Force-removing a worktree silently when `git worktree remove` fails.
- Trusting agent "success" reports without verifying the diff.
- Assuming verification commands without checking the project's actual tooling.
- Starting implementation on main/master without explicit user consent.
- Skipping the team shutdown step when in team mode.

## Related Skills

- **`agents-delegate`** — for single-task, one-shot delegation to one agent at a user-chosen tier/model. Use when the work fits one agent and doesn't warrant a plan + DAG.
- **`code-review-changes`** — invoked per-layer (default cadence) and at end-of-run for integration review.
- **`agents-review`** — dispatch a reviewer to cross-check the DAG before launching. Suggested after step 6 (optional; cheap tier by default).
