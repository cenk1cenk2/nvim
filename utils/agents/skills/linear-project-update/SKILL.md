---
name: linear-project-update
description: linear-project-update Rewrite a Linear project's description and documents so they reflect the deviations and refinements the work produced. Use on "update the project", "the project docs are stale". Not for structural audits, syncing state from merged work, posting an update, or creating a project.
argumentHint: '[project or URL]'
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/linear-absolute-approval.md
  - ../references/linear-document-handling.md
  - ../references/linear-issue-philosophy.md
---

## Linear Project Update

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

> **Absolute approval required — see `linear-absolute-approval`.** Project writes always require explicit approval for the specific change; a general blessing (`g` / `go` / autopilot) does NOT clear them. Never call `save_project` / `save_document` before the user approves the drafted change.

## Core Principle

> **THE PROJECT RECORD IS NOT THE ABSOLUTE TRUTH. THE CONVERSATION IS.** Record vs conversation authority, and the timestamp check that decides it, per `linear-issue-philosophy`. This skill applies deviations from the conversation back to the project's **prose** — the description and any plan-like documents — always confirming with the user before applying.

Documents follow `linear-document-handling`: glimpse always, classify plan-like vs external, and edit only plan-like documents with explicit user agreement. External docs stay read-only unless the user says otherwise.

## Scope

This skill edits the project's **own prose** — description and documents. It does NOT audit issue structure, priorities, estimates, or relations (that is `linear-project-reconcile`), and it does not post status updates (that is `linear-project-post`).

## Process

1. **Fetch the project** using the appropriate Linear MCP tools. Note the description's `updatedAt`.
2. **List and glimpse the project's documents** (`list_documents` / `get_document`) per `linear-document-handling`. Classify each as plan-like or external.
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

- **Never modify the project or its documents without explicit, per-change user approval** — per `linear-absolute-approval`; no blessing/autopilot shortcut applies.
- **Prose only.** For issue-level structure, priorities, estimates, and relations, use `linear-project-reconcile`.
- **Documents follow the handling policy.** Plan-like → editable with agreement; external → read-only unless the user explicitly says to edit.
- **Preserve content that hasn't changed** — only update what deviated.
- **The Thoughts section documents *why*, not *what*** — the description itself reflects the *what*.
- **Prefer a status post for progress narratives** — use `linear-project-post` when the user wants to communicate progress rather than correct the recorded intent.
