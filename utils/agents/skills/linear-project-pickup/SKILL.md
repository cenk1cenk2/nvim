---
name: linear-project-pickup
description: linear-project-pickup Prepare a Linear project or slice for implementation - issues, documents, blockers, comments, execution scope - then wait for an explicit go. Use on "pick up this project", "implement this slice", or a project URL. Not for execution by subagents, a read-only refresh, or a structure audit.
argumentHint: '[project or URL] [optional: slice or filter]'
references:
  - ../references/long-running-work.md
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear-prerequisite.md
  - ../references/linear-pickup-execution.md
  - ../references/linear-project-documents.md
  - ../references/linear-scm-discovery.md
  - ../references/linear-chunk-issues.md
  - ../references/linear-state-transitions.md
  - ../references/output-diff.md
  - ../references/linear-issue-philosophy.md
---

## Linear Project Pickup

State that spans turns must be written durably per `long-running-work` — posture, armed watchers, and artifact truth do not survive a compaction or a handoff on their own.

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

> **THE PROJECT RECORD IS A TEMPLATE. THE USER IS THE SOURCE OF TRUTH.** Record vs conversation authority per `linear-issue-philosophy`, applied before treating the project's issues or description as requirements. Records go stale — written before the work started, by someone who did not yet know what implementation would reveal. The user may skip, reorder, add, or override anything in them; never push back with "but the project says…".

Scope resolution, early questions, issue selection, state updates, and handoff to `agent-pickup` follow `linear-pickup-execution`; apply `linear-state-transitions` before moving selected issues to `In Progress`, and `output-diff` before writing to Linear.

Load the `linear-structure-agent` skill before implementation starts, whether or not this tree was shaped with it — picking up is one of its two modes, and it owns what stays true throughout: the executable unit is one repo, one PR, one concern, a parent holds the description while sub-issues hold deviations, ownership is blessed once, and findings get recorded as they surface rather than reconstructed at wrap-up. When execution shows the project's shape is wrong, reshape it there instead of working around it.

## Purpose

This skill turns a project or project slice into an execution-ready issue set. It does not have to implement by itself; by default it hands the prepared context to `agent-pickup`.

## Process

1. **Resolve project and slice.**
   - Parse the project name, slug, URL, or user-provided slice.
   - Fetch project issues via `list_issues` with the `project` parameter.
   - Fetch project documents via `list_documents` filtered by project when available.
   - If the slice is ambiguous, ask one focused question before continuing.

2. **Filter and classify issues.**
   - Include issues explicitly requested by the user.
   - For project-wide pickup, include actionable `Todo`, `Backlog`, and existing `In Progress` issues unless the user narrows scope.
   - Treat `In Review` blockers as mostly complete but verify linked PR/MR status when a dependent task is about to start.
   - Exclude `Done` and `Canceled` unless the user asks for reconciliation.

3. **Read context.**
   - Read descriptions, comments, relations, labels, estimates, and priorities for selected issues.
   - Read project documents that provide agent instructions, migration guides, candidate matrices, or shared verification commands, handled per `linear-project-documents` — including propagating investigations, solved problems, and deviations as tightly focused documents via the `linear-document` skill.
   - When the user explicitly asks to enrich pickup context from GitHub/GitLab, discover repositories, or produce agent-ready implementation guidance, use SCM discovery per `linear-scm-discovery` to enrich repository inventory, implementation guidance, prior art, file boundaries, and verification expectations — its Discovery Ladder picks the tools from what the active profile carries.
   - Identify stale descriptions, contradictory comments, missing details, and project documentation that needs updates.

4. **Prepare execution set.**
   - Map project issues to executable tasks per `linear-chunk-issues`.
   - Group issues by repository, concern, and dependency.
   - Identify direct implementation candidates, agent candidates, sequential prerequisites, and parallel-safe groups.
   - Note likely branch/PR boundaries.
   - Ask early for unresolved scope or intent.

5. **Report and hand off.**
   - Summarize selected issues, skipped issues, blockers, documents read, uncertainties, and recommended execution shape.
   - If the user requested confirmation, stop here.
   - Otherwise compose with `agent-pickup` for implementation.

## Output Shape

```markdown
## Project Pickup: <project>

### Selected Scope
- <issue-id>: <title> — <why included>

### Shared Context
- Project document: <title> — <what agents must read>

### Execution Shape
- Direct: <issues/tasks>
- Agents: <issues/tasks and recommended tier>
- Sequential prerequisites: <issue chain>
- Parallel candidates: <issue group>

### Questions / Risks
- <blocking question or stale information>

### Next
- Hand off to `agent-pickup` with <N> tasks.
```

## Key Principles

- **Project pickup is not project refresh.** For read-only survey, use `linear-project-read`.
- **Do not duplicate project docs into every issue.** Reference shared documents instead.
- **Ask early when project scope is not final.** Do not let agents discover missing intent mid-implementation.
- **Preserve issue boundaries unless there is a strong reason to merge or split.**
