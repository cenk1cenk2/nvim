---
name: agents-sequential
description: Execute a plan task-by-task using fresh subagents with review gates after each. Use when user says "execute this plan", "implement step by step", "sequential agents", or has ordered tasks where quality gates matter. Do NOT use for parallel work (use /agents-team or /agents-anonymous) or single-task work.
interaction: chat
disable-model-invocation: true
argument-hint: "[plan file or goal]"
references:
  - ../references/agents-delegate.md
  - ../references/agents-worktrees.md
  - ../references/scm-detect.md
  - ../references/project-tooling.md
  - ../references/agents-write-plans.md
  - ../references/agents-conventions.md
  - ../references/agents-completion.md
  - ../references/commit-style.md
  - ../references/commit-trailers.md
  - ../references/linear-chunk-issues.md
---

## system

### Sequential Subagent Execution

> **ALWAYS enter plan mode for the planning phase.** Exit when launching the first subagent.

> Read the `agents-delegate` reference for agent dispatch parameters, tier selection (cheap/default/smart), ecosystem model mappings, and user shorthand.
> Read the `agents-worktrees` reference for the mandatory worktree location rule (`.claude/worktrees/<name>/`), naming, verification, and cleanup — agent worktrees MUST live there, no exceptions.
> Read the `scm-detect` reference for git MCP tools and CLI fallbacks.
> Read the `project-tooling` reference for discovering verification commands.
> Read the `agents-write-plans` reference for plan quality criteria when creating plans.
> Read the `agents-conventions` reference for discovering and agreeing on project conventions before dispatching subagents.
> Read the `agents-completion` reference for the completion handoff after verification passes.
> Read the `commit-style` reference for conventional commit format, types, subject line rules, and body rules — used during the completion handoff commit step and per-task commits.
> Read the `commit-trailers` reference for issue linking conventions (Linear, GitHub, GitLab) — used when commits reference issues.
> Read the `linear-chunk-issues` reference for aligning task splits with Linear issues — used during planning when the user provides Linear issues or a project as input.

### Context

This skill executes an implementation plan task-by-task. Each task gets a fresh subagent with isolated context — subagents never inherit your session history. After each task, a review subagent verifies the work before proceeding. You (the lead) coordinate, provide context, and handle escalations.

**Why fresh subagents:** Isolated context keeps each subagent focused. Your own context stays clean for coordination. No context pollution between tasks.

### Process

#### Step 1: Load or Create the Plan

- If the user provides a plan file, read it from the Claude plans directory (`~/.claude/plans/`).
- If the user provides a goal, create a plan following the `agents-write-plans` reference — exact file paths, concrete steps, no placeholders.
  - Break into ordered tasks with: What, Files, Steps, Verification.
  - If the project has tests, steps should include writing/updating tests. If not, follow implement → verify → commit.
  - Self-review the plan (spec coverage, placeholder scan, consistency) before presenting.
- Present the plan to the user and iterate until approved.

#### Step 2: Discover Project Tooling

Follow the `project-tooling` reference to discover verification commands (lint, test, build, etc.). Present discovered commands to the user for confirmation. These commands are used after every task and at the end.

#### Step 3: Establish Conventions

Follow the `agents-conventions` reference — read existing code to discover testing framework, code style, patterns, formatting, commit style. Present the conventions block to the user for confirmation. This block will be included in every subagent's prompt.

#### Step 4: Set Up Workspace

- Record the current branch and HEAD commit as the baseline.
- Create a worktree if the user wants isolation (offer but don't force).
- If a worktree is created, it MUST live at `<project_root>/.claude/worktrees/<name>/` per the `agents-worktrees` reference — no exceptions. Verify the path after creation; abort and recreate manually if it ends up elsewhere.

#### Step 5: Execute Tasks Sequentially

For each task:

**a. Dispatch implementer subagent.**
- Use the `Agent` tool with a self-contained prompt (see Implementer Prompt Template).
- Dispatch is **foreground/blocking** by default — this turn pauses until the subagent returns its result. Do NOT set `run_in_background: true`. See the `agents-delegate` reference's Blocking Dispatch section.
- Include: task description, file list, codebase context, conventions, what adjacent tasks will do, **and the verification commands discovered in Step 2**.
- Set `mode: "bypassPermissions"` for speed.
- Select model based on task complexity (see Model Selection).

**b. Handle implementer status.**
- **DONE** — proceed to review.
- **DONE_WITH_CONCERNS** — read concerns. If correctness/scope, address before review. If observational, note and proceed.
- **NEEDS_CONTEXT** — provide missing context, re-dispatch.
- **BLOCKED** — assess: provide more context, use a more capable model, break task smaller, or escalate to user. Never retry blindly without changing something.

**c. Dispatch review subagent.**
- Get the git diff since the task started.
- Dispatch a review subagent using the Review Prompt Template below.
- Spec compliance is the gating check — if the code doesn't match what the task specified, quality doesn't matter yet.
- If the reviewer finds issues:
  1. Dispatch a fresh implementer subagent with the original task prompt **plus** a `## Issues to Fix` section containing the reviewer's specific feedback.
  2. After the fix subagent completes, dispatch the reviewer again with the updated diff.
  3. Repeat until the reviewer approves.
- Do not skip re-review after fixes. Do not accept "close enough."

**d. Run verification commands.**
- Run the commands from Step 2 (lint, test, build — whatever applies).
- Read the full output. If anything fails, fix before proceeding.

**e. Check for user guidance.**
- Between tasks, present a brief status to the user: which task just completed, which is next.
- The user may provide corrections, revised requirements, new context, or style feedback based on what they've seen so far.
- **Accumulate all user guidance** across tasks. Maintain a running `## Accumulated Guidance` section that grows as the user provides input.
- Include this section in every subsequent subagent prompt so later subagents benefit from everything learned earlier.

**f. Mark task complete.** Update the todo list and proceed to the next task.

#### Step 6: Final Review

- After all tasks complete, run `code-review-changes` against the recorded baseline.
- This catches integration issues across tasks.
- Present findings to the user. Fix if asked.

#### Step 7: Final Verification

- Run the full verification command set from Step 2.
- Read the output. Confirm pass with evidence.
- **Never claim completion without fresh verification output.** "Should pass" is not evidence.

#### Step 8: Completion Handoff

Follow the `agents-completion` reference — summarize work, present options (commit, push, PR, leave uncommitted), execute the user's choice.

### Model Selection

See the `agents-delegate` reference for tier definitions, ecosystem mappings, user shorthand, and mismatch handling. Per-subagent, pick a tier based on task complexity and resolve to a concrete model:

- **Anthropic via `Agent` tool:** cheap → `haiku`, default → `sonnet`, smart → `opus` (also for review subagents).
- **Other ecosystems:** user declares the tier mapping.
- **Explicit model names from the user** override tiers — use verbatim.
- **If a user request looks mismatched** to a task (cheap for architecture or review, smart for trivial mechanical work), ask before dispatching.

### Implementer Prompt Template

```
You are implementing task [N] of [total]: [task name].

## Goal
[High-level goal of the full plan — one sentence.]

## Your Task
[Full task description with steps.]

## Files (write scope)
- path/to/file1.ext
- path/to/file2.ext

## Context
[Codebase context: architecture, patterns, conventions, what adjacent tasks do.]

## Boundaries
Do NOT modify files outside your write scope.

## Accumulated Guidance
[Running list of user corrections and feedback from previous tasks. Empty for task 1. Grows with each task.]

## Verification Commands
[Commands from Step 2 — run these after implementation to confirm your work.]

## Process
1. If anything is unclear, ask before implementing.
2. Implement the changes.
3. If the project has tests for this area, write/update tests.
4. Run verification commands and confirm they pass.
5. Stage all with `git__git_add` (path `.`) and commit following conventional commit format: `<type>(<scope>): <imperative summary>`. If an issue ID is known, add a trailer (`refs <ID>` or `closes <ID>`).

## Report
When done, report one of:
- **DONE** — implemented and verified.
- **DONE_WITH_CONCERNS** — implemented but [describe concern].
- **NEEDS_CONTEXT** — cannot proceed without [what's missing].
- **BLOCKED** — cannot complete because [reason].
```

### Review Prompt Template

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

### Key Principles

- **Fresh subagent per task.** No context pollution between tasks.
- **Discover tooling first.** Verification commands come from the project, not assumptions. If unsure, ask the user.
- **Review after every task.** Do not skip. Do not proceed with open issues.
- **Evidence before claims.** Run verification, read output, then claim success. Never "should pass."
- **Escalate, don't force.** If a subagent is blocked, change something (context, model, task scope) — don't retry blindly.
- **No parallel implementation.** Tasks execute sequentially. Use `agents-anonymous` or `agents-team` for parallel work.
- **Plans live in `~/.claude/plans/`.** Never use `docs/superpowers/` or any other location.

### Red Flags

- Starting implementation on main/master without explicit user consent.
- Skipping review because "it's simple."
- Proceeding with unfixed reviewer issues.
- Dispatching multiple implementer subagents in parallel (conflicts).
- Claiming completion without running verification.
- Ignoring subagent questions or BLOCKED status.
- Trusting subagent "success" reports without verifying the diff.
- Assuming verification commands without checking the project's actual tooling.

### Related Skills

- **`agents-delegate`** (resource: `skills://skill/agents-delegate`) — for single-task, one-shot delegation to one agent at a user-chosen tier/model. Use when the work fits one task and doesn't need sequential gates.
- **`agents-anonymous`** — for parallel fire-and-forget when tasks are independent.
- **`agents-team`** — for parallel with approval propagation.
- **`code-review-changes`** (resource: `skills://skill/code-review-changes`) — auto-invoked for final integration review.
