---
name: agents-anonymous
description: Plan work and execute it across anonymous fire-and-forget agents with full permissions bypass. Use when user says "agents-anonymous", "fire and forget", or wants maximum speed without approval overhead. Agents bypass all permissions and report results only after completion. Do NOT use when approval propagation is needed (use /agents-team instead) or for single-task work.
interaction: chat
disable-model-invocation: true
argument-hint: "[goal or task list] [optional: 'without worktrees']"
references:
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

### Parallel Agent Orchestration

> **ALWAYS enter plan mode for the planning and splitting phases.**
>
> - Enter plan mode immediately.
> - Plan the work, split into non-overlapping tasks, and decide agent count.
> - Present the plan and task split to the user for approval.
> - Exit plan mode only when launching agents.

> Read the `scm-detect` reference for git MCP tools and CLI fallbacks — resolve references from the `<References>` block via MCP filesystem tools.
> Read the `project-tooling` reference for discovering verification commands.
> Read the `agents-write-plans` reference for plan quality criteria when creating plans.
> Read the `agents-conventions` reference for discovering and agreeing on project conventions before dispatching agents.
> Read the `agents-completion` reference for the completion handoff after verification passes.
> Read the `commit-style` reference for conventional commit format, types, subject line rules, and body rules — used during the completion handoff commit step.
> Read the `commit-trailers` reference for issue linking conventions (Linear, GitHub, GitLab) — used when commits reference issues.
> Read the `linear-chunk-issues` reference for aligning task splits with Linear issues — used during task splitting when the user provides Linear issues or a project as input.

### Context

This skill plans work like a tech lead splitting tasks across developers. Each agent gets an independent, non-overlapping unit of work. After all agents complete, the combined result is reviewed.

### Process

1. **Understand the goal.**
   - Read the codebase, gather context, understand what needs to be done.
   - If the user provides a high-level goal, break it down into concrete tasks.
   - If the user provides pre-decomposed tasks, validate they are complete and clear.

2. **Discover project tooling.**
   - Follow the `project-tooling` reference to discover verification commands (lint, test, build, etc.).
   - Present discovered commands to the user for confirmation.
   - These commands will be included in each agent's prompt and run after merge.

3. **Establish conventions.**
   - Follow the `agents-conventions` reference — read existing code to discover testing framework, code style, patterns, formatting, commit style.
   - Present the conventions block to the user for confirmation.
   - This block will be included in every agent's prompt as the `## Conventions` section.

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

     | Agent | Task | Files (write) | Dependencies |
     |-------|------|---------------|-------------|
     | 1 | ... | ... | none |
     | 2 | ... | ... | none |
     | 3 | ... | ... | none |

6. **Decide agent count.**
   - Number of agents = number of independent tasks from the split.
   - Propose the count with reasoning. The user approves or adjusts.
   - Fewer agents with broader scope is better than many agents with tiny tasks — agent overhead is real.

7. **Launch agents.**
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

8. **Monitor, guide, and collect results.**
   - Agents run in the background — you will be notified when each completes.
   - **While agents are running, the user can provide guidance at any time.** When the user gives new instructions, corrections, or context:
     - Forward the guidance to the relevant agent(s) via `SendMessage({ to: "<agent-name>", message: "..." })`.
     - If the guidance applies to all agents, send it to each one.
     - If the guidance changes the scope or approach, inform the user which agents are affected.
   - For each completed agent, review the result summary.
   - If any agent failed or reported issues, present them to the user before proceeding.

9. **Merge.**
   - Agents run in isolated worktrees by default, each on its own branch.
   - Merge each worktree branch back to the original branch sequentially.
   - If merge conflicts occur:
     - Present the conflicting files and both sides to the user.
     - Ask the user how to resolve, or propose a resolution.
     - Do NOT auto-resolve conflicts — the user decides.
   - After all merges, verify the working tree is clean.

10. **Review.**
   - After all agents complete (and merges are done if worktree mode), run `code-review-changes` against the recorded baseline.
   - This catches integration issues, inconsistencies between agents' work, and individual mistakes.
   - Present findings to the user. Fix issues if asked.

11. **Final verification.**
    - Run the full verification command set from step 2.
    - Read the output. Confirm pass with evidence.
    - **Never claim completion without fresh verification output.**

12. **Completion handoff.**
    - Follow the `agents-completion` reference — summarize work, present options (commit, push, PR, leave uncommitted), execute the user's choice.

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

## Verification Commands

[Commands discovered in step 2 — run these after implementation to confirm your work.]

## Conventions

[Project-specific conventions the agent should follow — naming, style, patterns]
```

### Model Selection

Set the `model` parameter on each agent based on task complexity:

| Task type | Model | Signals |
|-----------|-------|---------|
| Mechanical implementation | `haiku` | 1-2 files, clear spec, isolated function. |
| Integration work | `sonnet` | Multi-file, pattern matching, moderate judgment. |
| Architecture/design | `opus` | Design decisions, broad codebase understanding. |

### Key Principles

- **Non-overlapping is non-negotiable.** If tasks overlap on files, fix the split before launching. Two agents writing the same file will produce garbage.
- **Each agent is self-contained.** Agents cannot communicate with each other. Every agent must have all the context it needs in its prompt.
- **Fewer, larger agents over many small ones.** Agent startup and context have overhead. 2-4 agents is the sweet spot for most tasks.
- **Always review after.** The `code-review-changes` pass at the end is mandatory, not optional. Parallel work introduces integration risk.
- **Worktrees are the default.** Agents run isolated with full permissions. Opt out with "without worktrees".
- **Verify before claiming completion.** After review, run the project's test/lint/build commands. Read the output. "Should pass" is not evidence — show the result.
- **Don't trust agent success reports.** Check the VCS diff to verify agents actually made the expected changes.

### Red Flags

- Starting implementation on main/master without explicit user consent.
- Claiming completion without running verification.
- Trusting agent "success" reports without verifying the diff.
- Assuming verification commands without checking the project's actual tooling.
- Proceeding after review finds issues without fixing them.

### Related Skills

- **`agents-sequential`** (resource: `skills://skill/agents-sequential`) — for sequential task-by-task execution with review gates. Use when task ordering or quality gates matter more than speed.
- **`code-review-changes`** (resource: `skills://skill/code-review-changes`) — auto-invoked after all agents complete to review the combined result.
- **`code-assistant`** (resource: `skills://skill/code-assistant`) — for guided planning where the user implements. This skill plans AND executes. Do not auto-invoke.
- **`code-assistant-implement`** (resource: `skills://skill/code-assistant-implement`) — for sequential step-by-step execution with review gates. Use that when parallelism is not needed. Do not auto-invoke.
