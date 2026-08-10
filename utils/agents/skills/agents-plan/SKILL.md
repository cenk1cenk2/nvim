---
name: agents-plan
description: 'agents-plan Plan and execute multi-task work across agents via a dependency-aware DAG scheduler; layers run in parallel with review pauses between them. Modes: "team" (default, lead orchestrates) or "fire-and-forget" (autonomous, bypass permissions). Use on "agents-plan", "run these tasks in parallel", "fire and forget". Do NOT use for single-task delegation (use /agents-delegate).'
argumentHint: "[plan file or goal] [optional: 'fire' | 'fire-and-forget' | 'without worktrees' | 'per-task review' | 'final-only review']"
references:
  - ../references/plan-mode.md
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
  - ../references/provider-paths.md
---

## Agent DAG Orchestration

> **⛔ ALWAYS enter plan mode for the planning and scheduling phases** — full directives per `plan-mode`.
>
> - Enter plan mode immediately.
> - Plan the work, build the dependency DAG, decide review cadence and mode.
> - Present the plan, the proposed layer schedule, and the resolved mode+cadence to the user for approval.
> - Exit plan mode only when launching layer 0.

The planning phase runs per `agents-plan-split`; the between-layer and end-of-run phases per `agents-merge-review`.

## Context

This skill takes a plan (explicit file or inferred from a goal), builds a dependency DAG from each task's `depends_on` field, partitions tasks into layers, and executes layer by layer. Within a layer, tasks run in parallel in isolated worktrees; between layers, worktrees merge back, review runs, and the user can inject guidance before the next layer starts.

**Two orthogonal axes** control behaviour:

- **Mode** (coordination model):
  - **`team` (default)** — `TeamCreate` coordinates the run. The lead orchestrates and stays in the loop between layers.
  - **`fire-and-forget`** — no team coordination; agents run to completion and report. Use when the layer needs no lead involvement mid-flight.

  **Note:** mode does not control permissions. Subagents inherit the session's permission mode and any dispatch-time parameter is ignored — so autonomy is a property of the session you are running in, not of this axis. See `harness-<provider>-agents-delegate`.
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

- Repository and code discovery when planning starts from an organization-wide question or the target repository is not yet known: `sourcebot-discovery`.
- SCM platform detection and raw `git` CLI usage: `scm-detect`.
- Verification commands: `project-tooling`.
- Project conventions, discovered and agreed before any dispatch: `agents-conventions`.
- Plan quality criteria, including the optional `depends_on` field on tasks: `agents-write-plans`.
- Task splits aligned with Linear issue boundaries when the user supplies issues or a project: `linear-chunk-issues`.

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

> **Tip:** Want a second opinion on the DAG before launching? Suggest to the user: *"Invoke `/agents-review dag` with the schedule above to dispatch a reviewer (it picks the tier from the DAG's size and coupling)."* This is a nudge, not a step — the user decides whether to act on it.

### Step 7 — Decide agent count per layer

- Number of agents in a layer = number of tasks in that layer.
- 2–4 tasks per layer is the sweet spot. If a layer has >4 tasks, consider whether any should be merged; if a layer has 1 task, that's fine (sequential point in the DAG).

### Step 8 — Launch the first layer

> **⛔ Read the active runtime's mechanics from `~/.config/nvim/utils/agents/skills/references/harness-<provider>-agents-delegate.md` before the first dispatch.** A missed read is silent, and the blocking flag below is exactly what varies.

- Exit plan mode.
- Record the **run-level baseline** (current branch + HEAD) for the final review pass.
- For layer 0, the **layer baseline** = run baseline.
- Transition each Linear-linked task in this layer to `In Progress` per the `linear-state-transitions` reference. Report one line per id (`Linear state: moved K-xxx → In Progress (was Todo).`).

**Team mode (default):**

- Create the team with `TeamCreate({ team_name, description })` on the very first layer only (reused across layers).
- Spawn all teammates for this layer in a single message with multiple subagent dispatches. For each:
  - Worktree isolation (unless user opted out).
  - `team_name` set to the team created above.
  - No permission-mode parameter — it is ignored; teammates run under the session's own posture.
  - `run_in_background: false` — **set it explicitly.** A layer is a barrier, so it MUST block; on some providers (Claude Code) omitting the flag gets you background and the barrier silently does not hold. See `harness-<provider>-agents-delegate`.
  - A general-purpose subagent.

**Fire-and-forget mode:**

- No `TeamCreate`.
- Spawn all agents for this layer in a single message with multiple subagent dispatches. For each:
  - Worktree isolation (unless user opted out).
  - No permission-mode parameter — it is ignored; agents run under the session's posture.
  - `run_in_background: false` — **set it explicitly.** A layer is a barrier, so it MUST block; on some providers (Claude Code) omitting the flag gets you background and the barrier silently does not hold. See `harness-<provider>-agents-delegate`.
  - A general-purpose subagent.

**Per-task cadence override:** if the user chose `per-task` cadence, each layer still runs in parallel, but every task is implemented + reviewed by a pair (two dispatches — one implementer, one reviewer) before the layer considers itself done. See the "Per-Task Review Pattern" section below. This is heavier than per-layer review.

**Shared:**

- Dispatch parameters and mechanics per `agents-delegate`; resolve tiers to concrete models via the `agent-harness` skill.
- Verify each returned worktree path is absolute and in the runtime's agent-worktrees directory per `agents-worktrees` — the concrete worktrees and plans directories resolve via `provider-paths`, never hardcoded.
- Each agent prompt is self-contained. Use the template below. Include the running `## Accumulated Guidance` section (empty for layer 0).

### Step 9 — Collect layer results

- Blocking dispatch (`run_in_background: false` on every agent) — this turn pauses until every agent in the layer returns. **If results did not arrive as tool results, the dispatch was not actually blocking** — check the flag before concluding an agent failed.
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
- **Completion handoff.** Summarize and present options (commit / push / PR / leave); execute the user's choice per the `agents-completion` reference. Commit messages follow `commit-style`, with issue links per `commit-trailers`.

### Step 15 — Shutdown (team mode only)

- Send shutdown requests to all teammates: `SendMessage({ to: "<name>", message: { type: "shutdown_request" } })`.
- Wait for shutdown confirmations.
- Ensure every agent worktree tied to this team has been removed.
- Clean up with `TeamDelete`.

Fire-and-forget mode has no shutdown — agents exit on their own when their task completes.

## Worktree Mode

Worktree mode is the **default**. Every agent in every layer runs in its own worktree in the runtime's agent-worktrees directory. Worktree lifetime is one layer: created at layer launch, merged+removed at layer end.

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

FIRST, before writing anything: read [nearest sibling files] and [closest existing implementation of the same kind], and follow them. Extend the existing pattern rather than introducing a new one.

[Filled-in block from the `agents-conventions` reference — naming, formatting, errors, imports, tests, architecture]

Idiom above binds regardless of how novel the task is. For shape (decomposition, abstractions, signatures): mirror [analogous implementation] where one exists; where the task has no analogue, design it against the codebase's architecture and state in your report what you chose and why.

- Comments: match the surrounding density — [none | why-only]. Never restate what the code does. No banners, no narration, no added docstrings, no TODOs.
- Scope: modify only your write scope. No refactors, renames, reformatting, or dependency changes outside the task. A convention you dislike is still the convention — flag it, don't fix it.

Before reporting, self-check your diff against [reference file]: if it reads as though someone outside this codebase wrote it, fix it. New functionality may look new; it may not look foreign.

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

See the `agent-harness` skill for tier definitions, per-provider model lists, user shorthand, and mismatch handling. Per-agent, pick a tier based on task complexity and resolve to a concrete model:

- **Concrete model depends on the provider** — resolve via the `agent-harness` skill (Claude: cheap→`haiku`, default→`sonnet`, smart→`opus`, max→`fable`; OpenCode / Codex per its references). Same mapping applies to review subagents under per-task cadence.
- **Other providers:** if the mapping is unknown, ask the user.
- **Explicit model names from the user** override tiers — use verbatim.
- **Mismatched choices:** ask before dispatching.

## Reaping Between Layers

**⛔ Reap each layer's agents before launching the next.** A DAG run accumulates agents fastest of anything here, and a layer boundary is exactly where stale ones do damage: an unreaped agent from layer N can still be writing while layer N+1 starts, and two concurrent writers on one file clobber each other silently. Worktree cleanup is not the same as agent cleanup — do both.

Reap an agent when it delivered and its layer merged, when it went idle and you took its task back, when its task was superseded or dropped from the plan, or when you are re-dispatching it after a failed review — **reap before the re-dispatch**, never alongside it. Completion does not self-clean: finished agents linger in the runtime's task list, indistinguishable from live ones, which makes the layer's real state unreadable.

At the end of the run, and at every layer boundary, enumerate what is still alive and confirm each is stopped or *deliberately* still running with a stated reason.

## Key Principles

- **Reap each layer before the next launches.** Stale agents from a merged layer can still write and collide with the new one; a live agent list you cannot account for means you do not know what the run is doing.
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
