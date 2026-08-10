---
name: linear-project-create
description: linear-project-create Create a Linear project with the research, planning, and issue breakdown behind it. A Linear workspace skill must be active first. Use on "create a project", "plan a new project". Not for auditing a project that exists, or for status updates.
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear-prerequisite.md
  - ../references/linear-mandatory-fields.md
  - ../references/linear-description-structure.md
  - ../references/linear-research-documentation.md
  - ../references/output-diff.md
  - ../references/linear-project-documents.md
  - ../references/linear-scm-discovery.md
  - ../references/sourcebot-discovery.md
---

## Linear Project Creation

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

Present reasoning and content in logical chunks for user approval per `output-diff` before writing to Linear.

Shared context lives in Linear project documents per `linear-project-documents`. Use project documents for repeated guidance, research, matrices, and agent instructions; keep issues focused on task-specific details.

When the user explicitly asks to discover repositories, enrich the project from GitHub/GitLab, or create agent-ready implementation context, run SCM discovery per `linear-scm-discovery`. Use `sourcebot-discovery` through that workflow for broad or unknown-repo searches when available.

## Core Requirements

### Project Fields

- **`name`** — Required. Keep it concise and descriptive.
- **`summary`** — Required. Max 255 characters. A brief one-liner summarizing the project scope. Distinct from the full description.
- **`description`** — Required. Full project description following the structure below.
- **`addTeams`** — Required. Use the current user's team unless the user specifies otherwise.
- **`lead`** — Set to the current user.
- **`priority`** — Discuss with the user during planning. Present the scale (0=None, 1=Urgent, 2=High, 3=Medium, 4=Low) and agree on a value.
- **`state`** — Default to `planned`. Ask the user if they want `backlog` or `started` instead.
- **`startDate` / `targetDate`** — Discuss with the user. If the user has a timeline in mind, set these. Otherwise skip.
- **`labels`** — At minimum one label. **MUST be from the fetched label list — NEVER invent labels.**

### Initiative Matching

After gathering project context, fetch available initiatives using `list_initiatives` and present any that seem relevant to the project. Ask the user which initiative (if any) the project belongs to. If one matches, attach it via `addInitiatives`. Do NOT guess — always confirm with the user.

### Issue Fields

Required issue fields (team, state, labels, estimate, priority, assignee) per `linear-mandatory-fields`.

Project-specific overrides for issues created under this project:

- **`state`** — ALWAYS `backlog`. NO EXCEPTIONS unless the user explicitly says otherwise.
- **`priority`** — Defaults to the project priority unless the user specifies otherwise or dependency order suggests a different priority.
- **`project`** — Set to the newly created project.
- **`description`** — Keep light when shared project documentation exists: include the specific task scope, checklist or delta, and a "Read first" reference to the relevant project document instead of duplicating shared instructions.

### Project Documents

- Use the active Linear workspace's `save_document` tool to create or update project-scoped documents for shared information.
- Prefer project documents for repeated agent instructions, migration guides, repository inventories, candidate matrices, research findings, shared verification commands, and acceptance criteria.
- Create the project first, then create project documents attached to it, then create issues that reference those documents.
- When issue work is repetitive, put the shared "how agents should execute this project" context in project documents and use issues only for the per-repo, per-layer, or per-candidate specifics.

### Relations

- Use `blocks` / `blockedBy` to express dependency order between project issues.
- Use `relatedTo` to link issues to relevant issues in other projects.
- Use `parentId` for sub-issues.
- Think through the dependency graph so work order is clear.
- When creating multiple issues, batch create them using parallel tool calls.

## Description Structure

Project and issue description format per `linear-description-structure`.

When the same analysis or documentation applies to many issues, place the full analysis or appendix in a project document and summarize or reference it briefly from the project description and issues.

## Research & Documentation

Research process, analysis, appendix, and link conventions per `linear-research-documentation`.
