---
name: linear-document
description: linear-document Attach a document capturing this task's findings to a Linear issue or project, one document per concern. A workspace skill must be active first. Use on "attach a document", "write this up in Linear". Not for editing descriptions or fields, for a short comment, or for creating a project.
references:
  - ../references/present-first.md
  - ../references/linear/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/linear/linear-project-documents.md
  - ../references/linear/linear-document-handling.md
  - ../references/linear/linear-description-structure.md
  - ../references/identifier-legibility.md
argumentHint: '[optional: issue or project, and the concern to capture]'
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## Linear Document — Attach Task Details to an Issue or Project

Posture: `present-first`.
A Linear workspace skill must be active first — detection rules in `linear-prerequisite`.

## Context

This skill packages the **current task's details** — findings, an investigation, decisions, references — into one or more Linear documents attached to the relevant issue or project via `save_document`. A document is durable, structured context, distinct from a short discussion comment or the issue's own description.

`save_document` attaches to exactly one parent: `issue` (e.g. `LIN-123`) or `project` (also `initiative` / `cycle` / `team` if the user asks). **Scope determines the parent, at the tightest level that covers it:** detail specific to one issue attaches to that issue; context shared across a parent's sub-issues attaches to the **parent issue**; context shared project-wide attaches to the **project**.

## Process

1. **Resolve the target.** Get the issue or project from the user's URL/ID, or infer it from the current task and confirm. Pick the parent at the tightest scope that covers the content: specific to one issue → that issue; shared across a parent's sub-issues → the parent issue; project-wide → the project.

2. **Scope the content — one document or several.** Decide whether the material is a single coherent topic or several distinct concerns. **Separate investigations, findings, or topics become separate documents** — each with its own title and target — never one blob. Present the proposed split (titles + targets) before drafting.

3. **Check for existing documents.** `list_documents` (filter by `projectId`, or read the issue's attached docs) and skim for one that already covers this concern. If found, update it per `linear-document-handling` instead of creating a duplicate.

4. **Draft each document.** Title + Markdown content capturing the task detail for that scope, self-contained: purpose/scope, current findings or state, decisions and rationale, key references (files, PRs/MRs, paths), and open questions / next steps. Keep issues light — put shared context in a project document and reference it, per `linear-project-documents`.

5. **Present via `output-diff`**, iterate, and on approval write each with `save_document` (`issue` or `project` parent, `title`, `content`; pass `id` to update an existing one).

6. **Report** each created/updated document and the entity it is attached to.

## Key Principles

- **One document per concern.** If the task details span multiple distinct investigations or topics, split them into separate documents — each attached to the relevant issue or project. Never fold unrelated concerns into one document.
- **Scope picks the parent — tightest level that covers it.** Detail specific to one issue → that issue; context shared across a parent's sub-issues → the parent issue; project-wide context → the project. Keep the narrower issues light and pointing at the shared doc.
- **Update, don't duplicate.** If a document already covers the concern, update it with agreement rather than creating a second one.
- **Self-contained.** A document should make sense to a reader (or implementing agent) with no conversation history — include the paths, links, and rationale it needs.
- **Document, not comment or description.** Durable structured context is a document; ephemeral discussion is a comment (`linear-issue-comment`); the entity's own scope is its description (`linear-issue-update` / `linear-project-update`).

## Examples

**Example 1 — single investigation onto an issue:**
1. User: "document these findings on LIN-142." Resolve the issue; the material is one coherent investigation.
2. Draft one document (title + findings + file refs + next steps), present, attach via `save_document { issue: "LIN-142", title, content }`.

**Example 2 — separate concerns become separate documents:**
1. Mid-task the work surfaced a perf finding and an unrelated security finding for the same project.
2. Propose two documents — "Query N+1 investigation" and "Auth token expiry finding" — each attached to the project. Present both, write both after approval.

**Example 3 — shared context onto the project:**
1. A migration guide applies to every issue in the project. Attach it to the project via `save_document { project, title, content }`; keep the issues light with a "Read first" pointer to it.

## Composition with Other Skills

- **`linear-document-handling`** — the mechanics for updating an existing attached document (glimpse, classify, edit-with-agreement).
- **`linear-project-documents`** — when a document earns its place, issue-vs-project scoping, and lightweight issues.
- **`linear-issue-comment`** — for a short discussion note instead of a durable document.
- **`linear-issue-update` / `linear-project-update`** — to change the entity's own description or fields rather than attach a separate document.
- **`linear-project-create`** — creates a project and its initial documents from scratch; `linear-document` attaches documents on demand to entities that already exist.
