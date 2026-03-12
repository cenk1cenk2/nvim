---
name: plan-for-other
description: Create a self-contained plan for another Claude Code session or another repository. Use when user says "plan for another session", "plan for other repo", "create a handoff plan", "delegate this plan", or "plan this for later". Do NOT use for planning in the current session (use /assistant or EnterPlanMode directly).
interaction: chat
disable-model-invocation: true
argument-hint: "[same-repo|other-repo] [goal description]"
references:
  - ../references/plan-mode.md
---

## system

### Cross-Session / Cross-Repository Planning

> **ALWAYS enter plan mode.** Read the `plan-mode` reference (strict variant) for full directives — resolve references from the `<References>` block via `skills__read_reference`.
>
> - Use `EnterPlanMode` tool immediately.
> - Create plan file in `~/.claude/plans/YYYY-MM-DD-<project>-<name>.md`.
> - Present the plan to the user and iterate based on feedback.
> - Do NOT implement — the plan is consumed by a different session or agent.

### Context

This skill produces **self-contained plan files** that can be loaded by a future Claude Code session — either in the same repository or a different one. The plan must include everything the consuming session needs to understand the goal, the context, and the approach without access to the current conversation.

### Process

1. **Determine the target.**
   - Ask the user: is this plan for **another session in the same repository** or for **a different repository**?
   - If the user already stated this, skip asking.

2. **Branch by target type.**

#### Same Repository — Full Plan

When planning for another session in the same repository:

3. **Gather context.** Research the current repository state, relevant files, architecture, and any related work. Use all available MCP tools (LSP, git, file reading) to build a complete picture.
4. **Draft the plan file** with these sections in order:
   - **Issue / Problem Statement** — what is the problem or goal, recorded in full detail as if the reader has zero context from this conversation.
   - **Repository Context** — critical information about the repository: architecture, relevant files, conventions, stack, dependencies, gotchas. Include specific file paths and code references. The consuming session starts from scratch — give it what it needs to orient quickly.
   - **Goal** — in very detailed terms, describe what should be done and what the end state looks like. Be explicit about acceptance criteria.
   - **Plan** — if you have enough information, provide the step-by-step implementation approach. Include file paths, function names, and specific changes. If you lack information, state what research is needed before planning can be finalized.
5. **Present the plan** in chat and iterate with the user.

#### Different Repository — Delegating Part of Current Work

When the current task requires changes in another repository:

6. **Establish the connection.** Document why the other repository needs changes — what you are doing in the current repo that depends on or triggers work in the target repo. This is the critical context the consuming session needs.
7. **Ask the user:** "Should I research the target repository myself, or delegate the research to the consuming session?"

##### Self-Research Mode (you do the research)

8. Research the target repository using available MCP tools (`github__get_file_contents`, `gitlab__get_file_contents`, `github__search_code`, etc.).
9. Draft the plan following the same structure as "Same Repository" above, but add a **Cross-Repository Context** section that explains:
   - What work is happening in the originating repository.
   - What the originating repo expects from the target repo (API contract, config changes, shared types, etc.).
   - Integration points — how the two sides connect.
10. Present and iterate.

##### Delegation Mode (consuming session does the research)

11. Draft a **delegation plan** with these sections:
    - **Originating Context** — what you are doing in the current repository, why it requires changes in the target repo, and what the current repo expects from the target. This is the "why" that the consuming session cannot derive on its own.
    - **Goal** — what needs to be achieved in the target repository, described completely and unambiguously.
    - **Approach** — how we expect to achieve it at a high level.
    - **Integration Points** — specific contracts, endpoints, config keys, shared types, or behaviors that the target repo must satisfy for the originating work to function.
    - **Research Needed** — explicit list of what the consuming session must research in the target repo before implementing.
    - **End State** — what "done" looks like. Acceptance criteria, expected behavior.
    - **Preliminary Steps (Unverified)** — your best understanding of the implementation steps, clearly marked as drafted without the necessary research.
12. Present and iterate.

### Plan File Format

All plans follow this structure. Sections marked `(if applicable)` are included only when relevant.

```markdown
# [Descriptive Title]

> **Target:** [same-repo / other-repo: `<repo-name>`]
> **Created:** YYYY-MM-DD
> **Status:** draft | ready
> **Mode:** [full | delegation]

## Issue / Problem Statement

[Complete problem description — zero assumed context.]

## Originating Context (if applicable — cross-repo plans only)

[What is happening in `<originating-repo>` that requires this work.
What the originating repo expects — API contracts, config, shared types, behaviors.
Integration points between the two repositories.]

## Repository Context (if applicable — full mode only)

[Architecture, stack, conventions, relevant files, gotchas.]

## Goal

[Detailed description of the desired end state. Acceptance criteria.]

## Research Needed (if applicable — delegation mode only)

- [ ] [Specific research task 1.]
- [ ] [Specific research task 2.]

## Plan

[Step-by-step implementation — or "to be determined after research" for delegation mode.]

### Preliminary Steps (Unverified) (if applicable — delegation mode only)

> **DISCLAIMER:** These steps are drafted without completing the research listed above.
> They represent the current best understanding and MUST be revised after research is
> complete. Do not implement blindly.

1. [Step 1.]
2. [Step 2.]

## Loading Instructions

To apply this plan in a new session:
1. Read this file completely.
2. If "Research Needed" items exist, complete them first and revise the plan.
3. If the plan is complete, proceed with implementation step by step.
4. Update this file with any discoveries or deviations during implementation.
```

### After Completion

After the user approves the plan:

1. Write the plan file to `~/.claude/plans/YYYY-MM-DD-<project>-<name>.md`.
2. **Output the filename** to the user so they can reference it when starting the consuming session.
3. Inform the user: "To load this plan in the new session, tell the agent: `Load and apply the plan from <filename>`."

### Key Principles

- **Self-contained.** The plan must stand alone. No references to "what we discussed" — everything is explicit in the file.
- **Honest about gaps.** If research was not done, say so clearly. Never present unverified steps as confirmed.
- **Originating context is mandatory for cross-repo plans.** The consuming session must understand what triggered this work and what constraints it must satisfy.
- **Filename is the handoff.** The plan file is the only artifact that crosses session boundaries. Everything the consuming session needs must be in that file.
- **Loading is reverse planning.** When asked to LOAD a plan file, read it completely, complete any pending research, revise the plan if needed, then proceed with implementation or present a revised plan.
