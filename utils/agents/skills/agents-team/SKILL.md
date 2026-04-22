---
name: agents-team
description: Plan work and execute it across a coordinated agent team with approval propagation. Use when user says "run in parallel", "split this into agents", "agents-team", "create a team", or has multiple independent tasks to execute concurrently. Permission requests bubble up to the lead for approval. Do NOT use for fire-and-forget without approvals (use /agents-anonymous instead) or for single-task work.
interaction: chat
disable-model-invocation: true
argument-hint: "[goal or task list] [optional: 'without worktrees']"
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
  - ../references/linear-state-transitions.md
---

## system

### Agent Team Orchestration

> **ALWAYS enter plan mode for the planning and splitting phases.**
>
> - Enter plan mode immediately.
> - Plan the work, split into non-overlapping tasks, and decide agent count.
> - Present the plan and task split to the user for approval.
> - Exit plan mode only when launching the team.

> Read the `agents-delegate` reference for agent dispatch parameters, tier selection (cheap/default/smart), ecosystem model mappings, and user shorthand — resolve references from the `<References>` block via MCP filesystem tools.
> Read the `agents-worktrees` reference for the mandatory worktree location rule (`.claude/worktrees/<name>/`), naming, verification, and cleanup — team worktrees MUST live there, no exceptions.
> Read the `scm-detect` reference for git MCP tools and CLI fallbacks.
> Read the `project-tooling` reference for discovering verification commands.
> Read the `agents-write-plans` reference for plan quality criteria when creating plans.
> Read the `agents-conventions` reference for discovering and agreeing on project conventions before dispatching teammates.
> Read the `agents-completion` reference for the completion handoff after verification passes.
> Read the `commit-style` reference for conventional commit format, types, subject line rules, and body rules — used during the completion handoff commit step.
> Read the `commit-trailers` reference for issue linking conventions (Linear, GitHub, GitLab) — used when commits reference issues.
> Read the `linear-chunk-issues` reference for aligning task splits with Linear issues — used during task splitting when the user provides Linear issues or a project as input.
> Read the `linear-state-transitions` reference for the auto-advance rules when teammate tasks carry Linear ids. Applied just before teammate launch (step 7) — each Linear-linked task advances to `In Progress`.

### Context

This skill uses Agent Teams to coordinate parallel work. The lead agent (you) acts as orchestrator — planning, creating tasks, spawning teammates, reviewing permission requests that bubble up from teammates, and merging results. Each teammate works in an isolated worktree by default.

### Process

1. **Understand the goal.**
   - Read the codebase, gather context, understand what needs to be done.
   - If the user provides a high-level goal, break it down into concrete tasks.
   - If the user provides pre-decomposed tasks, validate they are complete and clear.

2. **Discover project tooling.**
   - Follow the `project-tooling` reference to discover verification commands (lint, test, build, etc.).
   - Present discovered commands to the user for confirmation.
   - These commands will be included in each teammate's prompt and run after merge.

3. **Establish conventions.**
   - Follow the `agents-conventions` reference — read existing code to discover testing framework, code style, patterns, formatting, commit style.
   - Present the conventions block to the user for confirmation.
   - This block will be included in every teammate's prompt as the `## Conventions` section.

4. **Plan the implementation.**
   - Create a full implementation plan following the `agents-write-plans` reference — exact file paths, concrete steps, no placeholders.
   - Identify all files and areas of the codebase that will be touched.
   - Self-review the plan (spec coverage, placeholder scan, consistency) before presenting.
   - Present the plan to the user and iterate.

5. **Split into non-overlapping tasks.**
   - Break the plan into logically independent units. Think of it as developers branching off — each works on a different part of the codebase.
   - **Non-overlapping is critical.** Each task must touch different files. If two tasks need to modify the same file, either:
     - Restructure the split so one task owns that file.
     - Warn the user that overlap exists and propose a resolution.
   - For each task, define:
     - **What:** Clear description of what to implement.
     - **Files:** Explicit list of files this agent owns (reads from anywhere, writes only to these).
     - **Context:** What this agent needs to know about the broader goal and adjacent tasks.
     - **Constraints:** What NOT to touch — boundaries with other agents' work.
   - Present the task split to the user as a table:

     | Teammate | Task | Files (write) | Dependencies |
     |----------|------|---------------|-------------|
     | worker-1 | ... | ... | none |
     | worker-2 | ... | ... | none |
     | worker-3 | ... | ... | none |

6. **Decide teammate count.**
   - Number of teammates = number of independent tasks from the split.
   - Propose the count with reasoning. The user approves or adjusts.
   - Fewer teammates with broader scope is better than many with tiny tasks — overhead is real.

7. **Create team and launch (parallel, blocking).**
   - Exit plan mode.
   - Record the current branch and HEAD commit as the baseline for later review.
   - **Transition linked Linear issues to `In Progress`** before launch. Follow the `linear-state-transitions` reference: for each teammate task that carries a Linear id, fetch current `statusType` and call `save_issue` with `state: "In Progress"`, skipping when already at or past that state. Report one line per issue in the launch summary (`Linear state: moved K-xxx → In Progress (was Todo).`). Silent-with-report: no confirmation prompt; user opts out for the turn by saying "don't move the Linear state".
   - Create the team with `TeamCreate`:
     ```
     TeamCreate({ team_name: "<descriptive-name>", description: "<goal>" })
     ```
   - Spawn all teammates **in a single message with multiple `Agent` tool uses** — they run concurrently with the given `team_name` and this turn blocks until every teammate returns. For each teammate:
     - Set `isolation: "worktree"` by default (omit only if user explicitly opted out).
     - Do NOT set `mode: "bypassPermissions"` — let permission requests bubble up to the harness for interactive approval.
     - Do NOT set `run_in_background: true` — blocking dispatch keeps results in this turn. See the `agents-delegate` reference's Blocking Dispatch section.
     - Set `subagent_type: "general-purpose"` for implementation work.
   - Create tasks for the team's shared task list, one per teammate assignment.
   - Assign tasks to teammates via task ownership.
   - **Verify** each returned worktree path is absolute and under `<project_root>/.claude/worktrees/` per the `agents-worktrees` reference. If any path falls outside, abort that teammate's result, recreate the worktree manually at the correct location (see the Manual Fallback section), and re-dispatch.

8. **Collect results and resolve escalations.**
   - All teammates run concurrently; this turn blocks until every teammate returns.
   - Permission requests during execution still bubble up — the harness surfaces them to the user for interactive approval while the lead is blocked.
   - When the batch returns, review each teammate's report and the shared task list state.
   - Present a consolidated update to the user in this same turn — per-teammate status, blockers, next steps.
   - If a teammate escalated a blocker or needs follow-up, spawn a corrective teammate on the NEXT turn using the same `team_name`. No mid-execution `SendMessage` — teammates are blocked.

9. **Merge (worktree mode).**
   - Teammates run in isolated worktrees under `.claude/worktrees/` by default, each on its own branch.
   - After all teammates complete, merge each worktree branch back to the original branch sequentially.
   - If merge conflicts occur:
     - Present the conflicting files and both sides to the user.
     - Ask the user how to resolve, or propose a resolution.
     - Do NOT auto-resolve conflicts — the user decides.
   - After all merges, verify the working tree is clean.
   - **Cleanup:** remove each worktree with `git worktree remove .claude/worktrees/<name>`. If removal fails (uncommitted state or locked worktree), surface the error to the user before force-removing — don't `--force` silently.

10. **Review.**
   - Run `code-review-changes` against the recorded baseline.
   - This catches integration issues, inconsistencies between teammates' work, and individual mistakes.
   - Present findings to the user. Fix issues if asked.

11. **Final verification.**
    - Run the full verification command set from step 2.
    - Read the output. Confirm pass with evidence.
    - **Never claim completion without fresh verification output.**

12. **Completion handoff.**
    - Follow the `agents-completion` reference — summarize work, present options (commit, push, PR, leave uncommitted), execute the user's choice.

13. **Shutdown and cleanup.**
   - Send shutdown requests to all teammates: `SendMessage({ to: "<name>", message: { type: "shutdown_request" } })`.
   - Wait for shutdown confirmations.
   - Ensure every `.claude/worktrees/<name>/` tied to this team has been removed in step 9. If any remain (e.g., a teammate was aborted mid-run), remove them now or surface them to the user.
   - Clean up with `TeamDelete`.

### Worktree Mode

Worktree mode is the **default**. All teammates run in isolated worktrees under `.claude/worktrees/` (see the `agents-worktrees` reference). To disable worktrees, the user must explicitly say "without worktrees" or "same worktree".

**When to skip worktrees (user must opt out):**
- Tasks are small and low-risk.
- The overhead of merging is not worth it.
- The user explicitly says "without worktrees" or "same worktree".

### Teammate Prompt Template

Each teammate receives a self-contained prompt. Include everything it needs — teammates do not share context with each other automatically. They coordinate through the shared task list and messages.

```
You are teammate [name] in team [team-name] working on: [high-level goal].

## Your Task

[Detailed task description]

## Your Files (write scope)

- path/to/file1.ext
- path/to/file2.ext

## Context

[Relevant codebase context — architecture, patterns, conventions, adjacent teammates' work]

## Boundaries

Do NOT modify files outside your write scope. Other teammates are handling:
- [teammate-name]: [brief description of their task and files]

## Conventions

[Project-specific conventions the teammate should follow — naming, style, patterns]

## Verification Commands

[Commands discovered in step 2 — run these after implementation to confirm your work.]

## Coordination

- Check the shared task list after completing each task for new work.
- Mark tasks as completed via TaskUpdate when done.
- Send a message to the lead if you are blocked or need a decision.
```

### Model Selection

See the `agents-delegate` reference for tier definitions, ecosystem mappings, user shorthand, and mismatch handling. Per-teammate, pick a tier based on task complexity and resolve to a concrete model:

- **Anthropic via `Agent` tool:** cheap → `haiku`, default → `sonnet`, smart → `opus`.
- **Other ecosystems:** user declares the tier mapping.
- **Explicit model names from the user** override tiers — use verbatim.
- **If a user request looks mismatched** to a task (cheap for architecture, smart for trivial mechanical work), ask before dispatching.

### Key Principles

- **Non-overlapping is non-negotiable.** If tasks overlap on files, fix the split before launching. Two teammates writing the same file will produce garbage.
- **Permission requests bubble up.** Teammates do NOT bypass permissions — the lead reviews and approves. This provides safety without manual user interruption.
- **Fewer, larger teams over many small ones.** Teammate startup and context have overhead. 2-4 teammates is the sweet spot for most tasks.
- **Always review after.** The `code-review-changes` pass at the end is mandatory, not optional. Parallel work introduces integration risk.
- **Worktrees are the default.** Teammates run isolated. Opt out with "without worktrees".
- **Clean shutdown is mandatory.** Always send shutdown requests and call `TeamDelete` when done.
- **Verify before claiming completion.** After review, run the project's test/lint/build commands. Read the output. "Should pass" is not evidence — show the result.
- **Don't trust teammate success reports.** Check the VCS diff to verify teammates actually made the expected changes.

### Red Flags

- Starting implementation on main/master without explicit user consent.
- Claiming completion without running verification.
- Trusting teammate "success" reports without verifying the diff.
- Assuming verification commands without checking the project's actual tooling.
- Proceeding after review finds issues without fixing them.

### Related Skills

- **`agents-delegate`** (resource: `skills://skill/agents-delegate`) — for single-task, one-shot delegation to one agent at a user-chosen tier/model. Use when the work fits one agent and doesn't warrant a team.
- **`agents-sequential`** (resource: `skills://skill/agents-sequential`) — for sequential task-by-task execution with review gates. Use when task ordering or quality gates matter more than speed.
- **`code-review-changes`** (resource: `skills://skill/code-review-changes`) — auto-invoked after all teammates complete to review the combined result.
- **`code-assistant`** (resource: `skills://skill/code-assistant`) — for guided planning where the user implements. This skill plans AND executes. Do not auto-invoke.
- **`code-assistant-implement`** (resource: `skills://skill/code-assistant-implement`) — for sequential step-by-step execution with review gates. Use that when parallelism is not needed. Do not auto-invoke.
