# Linear Document Handling

How to deal with **existing** attached/linked documents while reading or updating a Linear issue or project. This is the consume/reconcile side; for authoring shared context into documents, see the `linear-project-documents` reference.

Scope: Linear documents are project- and initiative-scoped (`list_documents` / `get_document` / `save_document`). An issue reaches documents through its parent project, plus its own attachments (`list_comments`, attachment links). "Attached document" below means any of these, plus linked plan-like files the conversation points at.

## Always Glimpse

During read and update flows, list and skim the attached/linked documents for context and drift — don't ignore them just because the description reads fine. Note each document's `updatedAt` when judging staleness.

## Classify Before Touching

- **Plan-like / LLM-authored** — an agent-written plan or spec, a `~/.claude/plans`-style file, a document this or a prior agent generated. Editing it to stay in sync with the conversation is reasonable.
- **External / human-authored reference** — a design doc, shared spec, research writeup, or customer-facing doc. **Read-only by default.** Editing is not automatically appropriate even when it looks stale.

When the type is unclear, treat it as external (read-only) and ask.

## Editing Requires Explicit Agreement — Every Time

- **Read skills never edit.** They only surface relevant document content and flag staleness (quote `updatedAt`). For anything actionable, hand off to the matching update skill.
- **Update skills may edit — but only after the user agrees.** Even for plan-like documents: present the proposed change via the `output-diff` convention, name which document and why, and wait for approval before calling `save_document`. Never edit an external document without the user explicitly saying to.

## In Practice

- **Read mode:** glimpse → summarize what's relevant → flag stale/contradicted docs with their timestamps → recommend (don't perform) any follow-up edits.
- **Update mode:** glimpse → classify each document → for plan-like ones, propose edits that reflect the agreed conversation → get agreement → write. Leave external docs untouched unless told otherwise.
