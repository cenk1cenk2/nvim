---
name: linear-document
description: linear-document Attach a document capturing this task's findings to a Linear issue or project, one document per concern. Use on "attach a document", "write this up in Linear". Not for editing descriptions or fields, for a short comment, or for creating a project.
references:
  - ../references/linear/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/linear/linear-absolute-approval.md
  - ../references/linear/linear-project-documents.md
  - ../references/linear/linear-document-handling.md
  - ../references/linear/linear-issuesets.md
  - ../references/linear/linear-description-structure.md
  - ../references/identifier-legibility.md
argumentHint: '[optional: issue or project, and the concern to capture]'
---

Issues, MRs and PRs carry their title and link, per `identifier-legibility`.

## Linear Document — Attach Task Details to an Issue or Project

A Linear workspace skill must be active first — detection rules in `linear-prerequisite`.

## Context

This skill packages the **current task's details** — findings, an investigation, decisions, references — into one or more Linear documents attached to the relevant issue or project via `save_document`. A document is durable, structured context, distinct from a short discussion comment or the issue's own description.

`save_document` attaches to exactly one parent: `issue` (e.g. `K-123`) or `project` (also `initiative` / `cycle` / `team` if the user asks).

## Process

1. **Resolve the target.** Get the issue or project from the user's URL/ID, or infer it from the current task and confirm. Pick the parent at the tightest scope that covers the content, per `linear-issuesets`.

2. **Scope the content — one document or several.** Decide whether the material is a single coherent topic or several distinct concerns. **Separate investigations, findings, or topics become separate documents** — each with its own title and target — never one blob. State the split (titles + targets) before drafting.

3. **Check for existing documents.** `list_documents` (filter by `projectId`, or read the issue's attached docs) and skim for one that already covers this concern. If found, update it per `linear-document-handling` instead of creating a duplicate.

4. **Draft each document.** Title + Markdown content capturing the task detail for that scope, self-contained: purpose/scope, current findings or state, decisions and rationale, key references (files, PRs/MRs, paths), and open questions / next steps. Keep issues light — put shared context in a project document and reference it, per `linear-project-documents`. Linear's markdown normaliser traps per `linear-description-structure`.

5. **Write each** with `save_document` (`issue` or `project` parent, `title`, `content`; pass `id` to update an existing one). A project-scope document is presented per `output-diff` and written only after explicit approval, per `linear-absolute-approval`.

6. **Report** each created/updated document and the entity it is attached to.

## Key Principles

- **Update, don't duplicate.** If a document already covers the concern, update it rather than creating a second one.
- **Document, not comment or description.** Durable structured context is a document; ephemeral discussion is a comment (`linear-issue-comment`); the entity's own scope is its description (`linear-update`).

## Examples

**Example 1 — single investigation onto an issue:**
1. User: "document these findings on K-142." Resolve the issue; the material is one coherent investigation.
2. Draft one document (title + findings + file refs + next steps), attach via `save_document { issue: "K-142", title, content }`, and report it.

**Example 2 — separate concerns become separate documents:**
1. Mid-task the work surfaced a perf finding and an unrelated security finding for the same project.
2. Propose two documents — "Query N+1 investigation" and "Auth token expiry finding" — each attached to the project. Present both per `output-diff` and write both after approval, since they land on the project.

**Example 3 — shared context onto the project:**
1. A migration guide applies to every issue in the project. Attach it to the project via `save_document { project, title, content }`; keep the issues light with a "Read first" pointer to it.

## Composition with Other Skills

- **`linear-issue-comment`** — for a short discussion note instead of a durable document.
- **`linear-update`** — to change the entity's own description or fields rather than attach a separate document.
- **`linear-project-create`** — creates a project and its initial documents from scratch; `linear-document` attaches documents on demand to entities that already exist.
