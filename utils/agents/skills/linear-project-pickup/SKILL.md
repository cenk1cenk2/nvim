---
name: linear-project-pickup
description: 'linear-project-pickup Prepare a Linear project or slice for implementation - fetch issues, documents, blockers, comments, and execution scope. Triggers: "pick up this project", "implement this project slice", project URL for execution. Do NOT use for read-only refreshes or structure audits.'
argumentHint: "[project name or URL] [optional slice/filter]"
references:
  - ../references/linear-prerequisite.md
  - ../references/linear-pickup-execution.md
  - ../references/linear-project-documents.md
  - ../references/linear-scm-discovery.md
  - ../references/sourcebot-discovery.md
  - ../references/linear-chunk-issues.md
  - ../references/linear-state-transitions.md
  - ../references/output-diff.md
  - ../references/present-first.md
---

## Linear Project Pickup

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

> Read the `linear-pickup-execution` reference for scope resolution, early questions, issue selection, state updates, and handoff to `agents-pickup`.
> Read the `linear-project-documents` reference for shared project document handling and for propagating investigations, solved problems, and deviations as tightly focused documents via the `linear-document` skill.
> Read the `linear-scm-discovery` reference when the user explicitly asks to enrich pickup context from GitHub/GitLab, discover repositories, or produce agent-ready implementation guidance. Use `sourcebot-discovery` through that workflow for broad or unknown-repo searches when available.
> Read the `linear-chunk-issues` reference for mapping project issues to executable tasks.
> Read the `linear-state-transitions` reference before moving selected issues to `In Progress`.
> Read the `output-diff` reference before writing to Linear.

## Purpose

This skill turns a project or project slice into an execution-ready issue set. It does not have to implement by itself; by default it hands the prepared context to `agents-pickup`.

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
   - Read project documents that provide agent instructions, migration guides, candidate matrices, or shared verification commands.
   - If explicitly requested, use SCM discovery to enrich repository inventory, implementation guidance, prior art, file boundaries, and verification expectations.
   - Identify stale descriptions, contradictory comments, missing details, and project documentation that needs updates.

4. **Prepare execution set.**
   - Group issues by repository, concern, and dependency.
   - Identify direct implementation candidates, agent candidates, sequential prerequisites, and parallel-safe groups.
   - Note likely branch/PR boundaries.
   - Ask early for unresolved scope or intent.

5. **Report and hand off.**
   - Summarize selected issues, skipped issues, blockers, documents read, uncertainties, and recommended execution shape.
   - If the user requested confirmation, stop here.
   - Otherwise compose with `agents-pickup` for implementation.

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
- Hand off to `agents-pickup` with <N> tasks.
```

## Key Principles

- **Project pickup is not project refresh.** For read-only survey, use `linear-project-read`.
- **Do not duplicate project docs into every issue.** Reference shared documents instead.
- **Ask early when project scope is not final.** Do not let agents discover missing intent mid-implementation.
- **Preserve issue boundaries unless there is a strong reason to merge or split.**
