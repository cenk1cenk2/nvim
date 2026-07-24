---
name: linear-project-update
description: 'linear-project-update Update a Linear project''s description and documents to reflect deviations and refinements. Triggers: "update the project", "project docs are stale". Do NOT use for structural audits (/linear-project-reconcile), state sync (/linear-project-match), status posts (/linear-project-post), or creation (/linear-project-create).'
argument-hint: "[project-name or Linear URL]"
references:
  - ../references/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/present-first.md
  - ../references/linear-absolute-approval.md
  - ../references/linear-project-documents.md
  - ../references/linear-document-handling.md
---

## Linear Project Update

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> **Absolute approval required.** Read the `linear-absolute-approval` reference — project writes always require explicit approval for the specific change; the present-first blessing shortcut (`g` / `go` / autopilot) does NOT clear them. Never call `save_project` / `save_document` before the user approves the drafted change.

## Prerequisite

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

## Core Principle

> **THE PROJECT RECORD IS NOT THE ABSOLUTE TRUTH. THE CONVERSATION IS.**
>
> The project description and its documents carry timestamps (`createdAt`, `updatedAt`). The user's session knowledge and the current conversation hold the most recent version of the project's intent. This skill applies deviations from the conversation back to the project's **prose** — the description and any plan-like documents. When the record's `updatedAt` is older than the current conversation, treat the conversation as the source of truth and update to match — always confirming with the user before applying.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

> Read the `linear-document-handling` reference before touching any document: glimpse always, classify plan-like vs external, and edit only plan-like documents with explicit user agreement. External docs stay read-only unless the user says otherwise.

## Scope

This skill edits the project's **own prose** — description and documents. It does NOT audit issue structure, priorities, estimates, or relations (that is `linear-project-reconcile`), and it does not post status updates (that is `linear-project-post`).

## Process

1. **Fetch the project** using the appropriate Linear MCP tools. Note the description's `updatedAt`.
2. **List and glimpse the project's documents** (`list_documents` / `get_document`), per the `linear-document-handling` reference. Classify each as plan-like or external.
3. **Check timestamps** — if the description or a plan-like document is older than the current session context, ask the user what has changed before assuming the stored content is current.
4. **Review the conversation** for deviations from the recorded project intent — changed goals, rejected approaches, new decisions, corrected assumptions, scope shifts.
5. **Flag outdated or contradicted sections** in the description and in plan-like documents. Warn the user; get explicit approval before modifying or removing them. Leave external documents read-only.
6. **Draft the updates** and present them via `output-diff` — one chunk per target (description, each document), highlighting what changed and why.
7. **Iterate** based on user feedback until the prose accurately reflects the current understanding.
8. **Apply changes** only after user approval — `save_project` for the description, `save_document` for each approved document.

## What to Update

- **Project description** — rewrite sections that no longer reflect the agreed goal, scope, or approach.
- **Plan-like documents** — bring agent-authored plans/specs in line with the conversation (with agreement).
- **`## Thoughts` section** — append to the description a markdown list of key deviations and the reasoning behind them.

## Thoughts Section Format

```markdown
## Thoughts

- Narrowed scope to X after deciding Y was out of band.
- Dropped the Z workstream — superseded by the new approach.
- Added milestone C which was missing from the original plan.
```

Only include deviations that matter for future readers understanding *why* the project prose looks different from what was originally written.

## Key Rules

- **Never modify the project or its documents without explicit, per-change user approval** — see the `linear-absolute-approval` reference; no blessing/autopilot shortcut applies.
- **Prose only.** For issue-level structure, priorities, estimates, and relations, use `linear-project-reconcile`.
- **Documents follow the handling policy.** Plan-like → editable with agreement; external → read-only unless the user explicitly says to edit.
- **Preserve content that hasn't changed** — only update what deviated.
- **The Thoughts section documents *why*, not *what*** — the description itself reflects the *what*.
- **Prefer a status post for progress narratives** — use `linear-project-post` when the user wants to communicate progress rather than correct the recorded intent.
