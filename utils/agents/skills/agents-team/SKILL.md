---
name: agents-team
description: Plan work and execute it across a coordinated agent team with approval propagation. Use when user says "run in parallel", "split this into agents", "agents-team", "create a team", or has multiple independent tasks to execute concurrently. Permission requests bubble up to the lead for approval. Do NOT use for fire-and-forget without approvals (use /agents-anonymous instead) or for single-task work.
interaction: chat
disable-model-invocation: true
argument-hint: "[goal or task list] [optional: 'without worktrees']"
references:
  - ../references/scm-detect.md
---

## system

### Agent Team Orchestration

> **ALWAYS enter plan mode for the planning and splitting phases.**
>
> - Enter plan mode immediately.
> - Plan the work, split into non-overlapping tasks, and decide agent count.
> - Present the plan and task split to the user for approval.
> - Exit plan mode only when launching the team.

> Read the `scm-detect` reference for git MCP tools and CLI fallbacks — resolve references from the `<References>` block via MCP filesystem tools.

### Context

This skill uses Agent Teams to coordinate parallel work. The lead agent (you) acts as orchestrator — planning, creating tasks, spawning teammates, reviewing permission requests that bubble up from teammates, and merging results. Each teammate works in an isolated worktree by default.

### Process

1. **Understand the goal.**
   - Read the codebase, gather context, understand what needs to be done.
   - If the user provides a high-level goal, break it down into concrete tasks.
   - If the user provides pre-decomposed tasks, validate they are complete and clear.

2. **Plan the implementation.**
   - Create a full implementation plan as you normally would — architecture, approach, file changes, constraints.
   - Identify all files and areas of the codebase that will be touched.
   - Present the plan to the user and iterate.

3. **Split into non-overlapping tasks.**
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

4. **Decide teammate count.**
   - Number of teammates = number of independent tasks from the split.
   - Propose the count with reasoning. The user approves or adjusts.
   - Fewer teammates with broader scope is better than many with tiny tasks — overhead is real.

5. **Create team and launch.**
   - Exit plan mode.
   - Record the current branch and HEAD commit as the baseline for later review.
   - Create the team with `TeamCreate`:
     ```
     TeamCreate({ team_name: "<descriptive-name>", description: "<goal>" })
     ```
   - Spawn teammates using the `Agent` tool with `team_name` and `name` parameters:
     - Set `isolation: "worktree"` by default (omit only if user explicitly opted out).
     - Do NOT set `mode: "bypassPermissions"` — let permission requests bubble up to the lead.
     - Set `subagent_type: "general-purpose"` for implementation work.
   - Create tasks for the team's shared task list, one per teammate assignment.
   - Assign tasks to teammates via task ownership.

6. **Orchestrate and approve.**
   - Teammate permission requests bubble up to you (the lead). Review and approve or reject as they come in.
   - Teammates send messages when they complete tasks or need help — these arrive automatically.
   - If a teammate is blocked, help resolve or reassign work.
   - Monitor the shared task list for progress.
   - Do NOT micromanage — let teammates work autonomously between approval requests.

7. **Merge (worktree mode).**
   - Teammates run in isolated worktrees by default, each on its own branch.
   - After all teammates complete, merge each worktree branch back to the original branch sequentially.
   - If merge conflicts occur:
     - Present the conflicting files and both sides to the user.
     - Ask the user how to resolve, or propose a resolution.
     - Do NOT auto-resolve conflicts — the user decides.
   - After all merges, verify the working tree is clean.

8. **Review.**
   - Run `code-review-changes` against the recorded baseline.
   - This catches integration issues, inconsistencies between teammates' work, and individual mistakes.
   - Present findings to the user. Fix issues if asked.

9. **Shutdown and cleanup.**
   - Send shutdown requests to all teammates: `SendMessage({ to: "<name>", message: { type: "shutdown_request" } })`.
   - Wait for shutdown confirmations.
   - Clean up with `TeamDelete`.

### Worktree Mode

Worktree mode is the **default**. All teammates run in isolated worktrees. To disable worktrees, the user must explicitly say "without worktrees" or "same worktree".

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

## Coordination

- Check the shared task list after completing each task for new work.
- Mark tasks as completed via TaskUpdate when done.
- Send a message to the lead if you are blocked or need a decision.
```

### Key Principles

- **Non-overlapping is non-negotiable.** If tasks overlap on files, fix the split before launching. Two teammates writing the same file will produce garbage.
- **Permission requests bubble up.** Teammates do NOT bypass permissions — the lead reviews and approves. This provides safety without manual user interruption.
- **Fewer, larger teams over many small ones.** Teammate startup and context have overhead. 2-4 teammates is the sweet spot for most tasks.
- **Always review after.** The `code-review-changes` pass at the end is mandatory, not optional. Parallel work introduces integration risk.
- **Worktrees are the default.** Teammates run isolated. Opt out with "without worktrees".
- **Clean shutdown is mandatory.** Always send shutdown requests and call `TeamDelete` when done.

### Related Skills

- **`code-review-changes`** (resource: `skills://skill/code-review-changes`) — auto-invoked after all teammates complete to review the combined result.
- **`code-assistant`** (resource: `skills://skill/code-assistant`) — for guided planning where the user implements. This skill plans AND executes. Do not auto-invoke.
- **`code-assistant-implement`** (resource: `skills://skill/code-assistant-implement`) — for sequential step-by-step execution with review gates. Use that when parallelism is not needed. Do not auto-invoke.
