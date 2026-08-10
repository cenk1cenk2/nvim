---
name: plan-handoff
description: 'plan-handoff Create a self-contained plan for another Claude Code session or repository. Triggers: "create a handoff plan", "plan for another session", "plan this for later". Do NOT use for planning in the current session (/plan-hard) or loading existing plans (/plan-pickup).'
disableModelInvocation: true
argumentHint: "[same-repo|other-repo] [goal description]"
references:
  - ../references/reconcile-state.md
  - ../references/plan-mode.md
  - ../references/provider-paths.md
---

## Cross-Session / Cross-Repository Planning

When the work deviates from what this artifact claims, reconcile it per `reconcile-state` — on by default, ask when it is a judgement call.

> **⛔ ALWAYS enter plan mode** — full directives per `plan-mode`.
>
> - Enter plan mode immediately.
> - Create plan file in your internal plans directory as `YYYY-MM-DD-<project>-<name>.md`. Resolve the directory and filename default for the active runtime via `provider-paths`; never hardcode a path.
> - Present the plan to the user and iterate based on feedback.
> - Do NOT implement — the plan is consumed by a different session or agent.

## Context

This skill produces **self-contained plan files** that can be loaded by a future Claude Code session — either in the same repository or a different one. The plan must include everything the consuming session needs to understand the goal, the context, and the approach without access to the current conversation.

## Process

1. **Determine the target.**
   - Ask the user: is this plan for **another session in the same repository** or for **a different repository**?
   - If the user already stated this, skip asking.

2. **Branch by target type.**

### Same Repository — Full Plan

When planning for another session in the same repository:

3. **Gather context.** Research the current repository state, relevant files, architecture, and any related work. Use all available MCP tools (LSP, raw `git` CLI, file reading) to build a complete picture.
4. **Draft the plan file** with these sections in order:
   - **Issue / Problem Statement** — what is the problem or goal, recorded in full detail as if the reader has zero context from this conversation.
   - **Repository Context** — critical information about the repository: architecture, relevant files, conventions, stack, dependencies, gotchas. Include specific file paths and code references. The consuming session starts from scratch — give it what it needs to orient quickly.
   - **Goal** — in very detailed terms, describe what should be done and what the end state looks like. Be explicit about acceptance criteria.
   - **Plan** — if you have enough information, provide the step-by-step implementation approach. Include file paths, function names, and specific changes. If you lack information, state what research is needed before planning can be finalized.
5. **Present the plan** in chat and iterate with the user.

### Different Repository — Delegating Part of Current Work

When the current task requires changes in another repository:

6. **Establish the connection.** Document why the other repository needs changes — what you are doing in the current repo that depends on or triggers work in the target repo. This is the critical context the consuming session needs.
7. **Ask the user:** "Should I research the target repository myself, or delegate the research to the consuming session?"

#### Self-Research Mode (you do the research)

8. Research the target repository using available MCP tools (`github__get_file_contents`, `gitlab__get_file_contents`, `github__search_code`, etc.).
9. Draft the plan following the same structure as "Same Repository" above, but add a **Cross-Repository Context** section that explains:
   - What work is happening in the originating repository.
   - What the originating repo expects from the target repo (API contract, config changes, shared types, etc.).
   - Integration points — how the two sides connect.
10. Present and iterate.

#### Delegation Mode (consuming session does the research)

11. Draft a **delegation plan** with these sections:
    - **Originating Context** — what you are doing in the current repository, why it requires changes in the target repo, and what the current repo expects from the target. This is the "why" that the consuming session cannot derive on its own.
    - **Goal** — what needs to be achieved in the target repository, described completely and unambiguously.
    - **Approach** — how we expect to achieve it at a high level.
    - **Integration Points** — specific contracts, endpoints, config keys, shared types, or behaviors that the target repo must satisfy for the originating work to function.
    - **Research Needed** — explicit list of what the consuming session must research in the target repo before implementing.
    - **End State** — what "done" looks like. Acceptance criteria, expected behavior.
    - **Preliminary Steps (Unverified)** — your best understanding of the implementation steps, clearly marked as drafted without the necessary research.
12. Present and iterate.

## Plan File Format

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

To pick up this plan in a new session, use `/plan-pickup` with this file path.
```

## After Completion

After the skill finishes, always make the handoff location the first thing in the final response.

1. Write the plan file to your internal plans directory as `YYYY-MM-DD-<project>-<name>.md`.
2. Immediately output a compact handoff block before any other summary:
   - `Plan handoff: <plans-dir>/YYYY-MM-DD-<project>-<name>.md`.
   - `Pick up with: /plan-pickup <plans-dir>/YYYY-MM-DD-<project>-<name>.md`.
3. If the skill exits without writing a file, explicitly say no handoff file exists yet and why.
4. Any additional summary or caveats must come after the handoff block.

## Key Principles

- **Self-contained.** The plan must stand alone. No references to "what we discussed" — everything is explicit in the file.
- **Honest about gaps.** If research was not done, say so clearly. Never present unverified steps as confirmed.
- **Originating context is mandatory for cross-repo plans.** The consuming session must understand what triggered this work and what constraints it must satisfy.
- **Filename is the handoff.** The plan file is the only artifact that crosses session boundaries. Everything the consuming session needs must be in that file.
