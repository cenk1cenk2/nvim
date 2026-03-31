---
name: agents-anonymous
description: Plan work and execute it across anonymous fire-and-forget agents with full permissions bypass. Use when user says "agents-anonymous", "fire and forget", or wants maximum speed without approval overhead. Agents bypass all permissions and report results only after completion. Do NOT use when approval propagation is needed (use /agents-team instead) or for single-task work.
interaction: chat
disable-model-invocation: true
argument-hint: "[goal or task list] [optional: 'without worktrees']"
references:
  - ../references/scm-detect.md
---

## system

### Parallel Agent Orchestration

> **ALWAYS enter plan mode for the planning and splitting phases.**
>
> - Enter plan mode immediately.
> - Plan the work, split into non-overlapping tasks, and decide agent count.
> - Present the plan and task split to the user for approval.
> - Exit plan mode only when launching agents.

> Read the `scm-detect` reference for git MCP tools and CLI fallbacks — resolve references from the `<References>` block via MCP filesystem tools.

### Context

This skill plans work like a tech lead splitting tasks across developers. Each agent gets an independent, non-overlapping unit of work. After all agents complete, the combined result is reviewed.

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

     | Agent | Task | Files (write) | Dependencies |
     |-------|------|---------------|-------------|
     | 1 | ... | ... | none |
     | 2 | ... | ... | none |
     | 3 | ... | ... | none |

4. **Decide agent count.**
   - Number of agents = number of independent tasks from the split.
   - Propose the count with reasoning. The user approves or adjusts.
   - Fewer agents with broader scope is better than many agents with tiny tasks — agent overhead is real.

5. **Launch agents.**
   - Exit plan mode.
   - Record the current branch and HEAD commit as the baseline for later review.
   - Launch all agents in parallel using the Agent tool. Each agent prompt must include:
     - The full task description.
     - The list of files it owns.
     - Relevant codebase context (file paths, patterns, conventions).
     - Explicit boundary: "You are responsible for [X]. Do NOT modify files outside your scope: [list]."
   - Always set `isolation: "worktree"` and `mode: "bypassPermissions"` on every agent.
   - If the user explicitly opted out of worktrees, omit `isolation` but keep `mode: "bypassPermissions"`.
   - Use `run_in_background: true` for all agents so they execute concurrently.
   - Track agent IDs for monitoring completion.

6. **Monitor and collect results.**
   - Wait for all agents to complete (you will be notified automatically).
   - For each agent, review the result summary.
   - If any agent failed or reported issues, present them to the user before proceeding.

7. **Merge.**
   - Agents run in isolated worktrees by default, each on its own branch.
   - Merge each worktree branch back to the original branch sequentially.
   - If merge conflicts occur:
     - Present the conflicting files and both sides to the user.
     - Ask the user how to resolve, or propose a resolution.
     - Do NOT auto-resolve conflicts — the user decides.
   - After all merges, verify the working tree is clean.

8. **Review.**
   - After all agents complete (and merges are done if worktree mode), run `code-review-changes` against the recorded baseline.
   - This catches integration issues, inconsistencies between agents' work, and individual mistakes.
   - Present findings to the user. Fix issues if asked.

### Worktree Mode

Worktree mode is the **default**. All agents run in isolated worktrees with `mode: "bypassPermissions"`. To disable worktrees, the user must explicitly say "without worktrees" or "same worktree".

**When to skip worktrees (user must opt out):**
- Tasks are small and low-risk.
- The overhead of merging is not worth it.
- The user explicitly says "without worktrees" or "same worktree".

### Agent Prompt Template

Each agent receives a self-contained prompt. Include everything it needs — agents do not share context with each other or with the orchestrator.

```
You are agent [N] of [total] working in parallel on: [high-level goal].

## Your Task

[Detailed task description]

## Your Files (write scope)

- path/to/file1.ext
- path/to/file2.ext

## Context

[Relevant codebase context — architecture, patterns, conventions, adjacent agents' work]

## Boundaries

Do NOT modify files outside your write scope. Other agents are handling:
- Agent [X]: [brief description of their task and files]

## Conventions

[Project-specific conventions the agent should follow — naming, style, patterns]
```

### Key Principles

- **Non-overlapping is non-negotiable.** If tasks overlap on files, fix the split before launching. Two agents writing the same file will produce garbage.
- **Each agent is self-contained.** Agents cannot communicate with each other. Every agent must have all the context it needs in its prompt.
- **Fewer, larger agents over many small ones.** Agent startup and context have overhead. 2-4 agents is the sweet spot for most tasks.
- **Always review after.** The `code-review-changes` pass at the end is mandatory, not optional. Parallel work introduces integration risk.
- **Worktrees are the default.** Agents run isolated with full permissions. Opt out with "without worktrees".

### Related Skills

- **`code-review-changes`** (resource: `skills://skill/code-review-changes`) — auto-invoked after all agents complete to review the combined result.
- **`code-assistant`** (resource: `skills://skill/code-assistant`) — for guided planning where the user implements. This skill plans AND executes. Do not auto-invoke.
- **`code-assistant-implement`** (resource: `skills://skill/code-assistant-implement`) — for sequential step-by-step execution with review gates. Use that when parallelism is not needed. Do not auto-invoke.
