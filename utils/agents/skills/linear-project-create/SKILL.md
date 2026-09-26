---
name: linear-project-create
description: linear-project-create Create a Linear project with the research, planning, and issue breakdown behind it. Use on "create a project", "plan a new project". Not for auditing a project that exists, or for status updates.
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear/linear-prerequisite.md
  - ../references/linear/linear-mandatory-fields.md
  - ../references/linear/linear-description-structure.md
  - ../references/linear/linear-research-documentation.md
  - ../references/output-diff.md
  - ../references/linear/linear-absolute-approval.md
  - ../references/linear/linear-project-documents.md
  - ../references/linear/linear-scm-discovery.md
  - ../references/identifier-legibility.md
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## Linear Project Creation

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

Present reasoning and content in logical chunks for user approval per `output-diff` before writing to Linear.

> **Absolute approval required per `linear-absolute-approval`.** The project, its documents, and any initiative link each need explicit approval for that specific change; a general blessing (`g` / `go` / autopilot) does NOT clear them. Never call `save_project` / `save_document` before the user approves the drafted change.

Shared context lives in Linear project documents per `linear-project-documents`.

When the user explicitly asks to discover repositories, enrich the project from GitHub/GitLab, or create agent-ready implementation context, run SCM discovery per `linear-scm-discovery` — its Discovery Ladder picks the tools from what the active profile carries.

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
- **`labels`** — At minimum one label. **MUST be from the project label list (`list_project_labels`) — NEVER invent labels.**

### Initiative Matching

After gathering project context, fetch available initiatives using `list_initiatives` and present any that seem relevant to the project. Ask the user which initiative (if any) the project belongs to. If one matches, attach it via `addInitiatives`. Do NOT guess — always confirm with the user.

### Issue Fields

Required issue fields and relations per `linear-mandatory-fields`.

Project-specific overrides for issues created under this project:

- **`state`** — ALWAYS `backlog`. NO EXCEPTIONS unless the user explicitly says otherwise.
- **`priority`** — Defaults to the project priority unless the user specifies otherwise or dependency order suggests a different priority.
- **`project`** — Set to the newly created project.
- **`description`** — Keep light when shared project documentation exists: include the specific task scope, checklist or delta, and a "Read first" reference to the relevant project document instead of duplicating shared instructions.

### Order and Relations

- Create the project first, then its documents, then the issues that reference them.
- Think through the dependency graph so work order is clear, and batch create multiple issues with parallel tool calls.

## Description Structure

Project and issue description format per `linear-description-structure`.

## Research & Documentation

Research process, analysis, appendix, and link conventions per `linear-research-documentation`.
