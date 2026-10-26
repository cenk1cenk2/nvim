---
name: linear-research
description: linear-research Capture a session's research as a Linear issue or project, or adopt an existing one to refine, change, cancel, or finalize it into a project, issueset, or issues - documents for findings, plans, shortfalls and paths not taken. Use on "park this research in Linear", "turn this research into a ticket", "finalize the research issue". Not for filing work from an already settled plan.
argumentHint: '[capture | adopt issue-or-project id or URL] [optional: issue | project]'
references:
  - ../references/present-first.md
  - ../references/reconcile-state.md
  - ../references/agent-owned.md
  - ../references/output-diff.md
  - ../references/linear/linear-prerequisite.md
  - ../references/linear/linear-mandatory-fields.md
  - ../references/linear/linear-issue-states.md
  - ../references/linear/linear-absolute-approval.md
  - ../references/linear/linear-issuesets.md
  - ../references/linear/linear-project-documents.md
  - ../references/linear/linear-document-handling.md
  - ../references/linear/linear-description-structure.md
  - ../references/linear/linear-research-documentation.md
  - ../references/identifier-legibility.md
---

Issues, projects, MRs and PRs carry their title and link, per `identifier-legibility`.

## Linear Research

Posture: `present-first`.

A Linear workspace skill must be active first — detection rules in `linear-prerequisite`.

When work deviates from what the record claims, reconcile it per `reconcile-state` — only what this session created or the user handed you.

## Context

A **research record** is a Linear issue or project that holds an investigation which is not yet build-ready. It exists so a large session's research survives: the question, what was found, the plans drafted, where they fall short, the paths considered and dropped, and what is still open. It is parked for further investigation, or finalized into executable work once the research settles.

The record is light; the research lives in documents. The description states the question, the current conclusion, and a "Read first" list of the documents. Everything else goes into documents through `linear-document`, one concern per document per `linear-project-documents`.

Two modes:

| Mode | Trigger | Starts from |
|---|---|---|
| **Capture** | research in this session, no record yet | the conversation |
| **Adopt** | an issue or project id or URL that holds earlier research | the record, reconciled against the conversation |

## Document Set

Every concern the research touched gets its own document. Draft only what the session actually produced; skip a row with nothing behind it.

| Document | Holds |
|---|---|
| Findings | what was established, with evidence — files, commands, links, measurements |
| Plan: <name> | each candidate plan as its own document — steps, scope, repos, verification |
| Shortfalls and risks | where each plan falls short, failure modes, unknowns that could sink it |
| Paths considered | every alternative weighed and why it was dropped or deferred |
| Open questions | what still needs investigating, and how to settle each |
| References | repos, MRs/PRs, docs, prior art, appendix shape per `linear-research-documentation` |

A plan document names the shortfalls and paths documents rather than repeating them.

## Process — Capture

1. **Pick the record type.** Default to an **issue**. Propose a **project** when the research spans several repos or concerns, or already implies several issues, and confirm with the user.
2. **Draft the record.** Title, a description per `linear-description-structure` carrying the question, the current conclusion, and the "Read first" list. Fields per `linear-mandatory-fields`: issue state `Backlog`, labels only from the workspace list, never invented. A project starts in `backlog` state.
3. **Draft the document set** above from the conversation, and state the split (titles plus target) before drafting the bodies.
4. **Present** the record and every document per `output-diff`, then write on approval: `save_issue` or `save_project`, then Load `linear-document` to write each document onto the record.
5. **Report** the record and its documents with titled links, plus the open questions that decide what happens next.

## Process — Adopt

1. **Resolve the record** — `get_issue` or `get_project`, then `list_documents` and `list_comments`. Classify documents per `linear-document-handling`. An issue carrying sub-issues is an issueset per `linear-issuesets`.
2. **Reconcile against the conversation.** Name what the conversation changed since the record's `updatedAt`: new findings, a dropped plan, a corrected assumption.
3. **Ask which outcome** the user wants, unless the request already named it:

| Outcome | What happens |
|---|---|
| **Cancel** | Comment the reason and what was learned, then Load `linear-status` to move an issue to `Canceled`; a project goes to `canceled` through `save_project`, which needs explicit approval per `linear-absolute-approval`. |
| **Research further / refine** | Investigate, then fold the results in: new or updated documents through `linear-document`, each deviation as a comment. |
| **Change** | Load `linear-update` to rewrite the description and plan-like documents. |
| **Finalize** | Turn the record into executable work — see Finalize. |

4. **Record deviations as you go.** Each finding or changed decision that alters the record is a comment: Load `linear-issue-comment` on an issue, `linear-project-comment` on a project. A comment says what changed and why; the document carries the full content.

## Finalize

Load `linear-structure-agent` to shape the executable work before writing any issue.

| Record | Default | On request |
|---|---|---|
| **Project** | Keep the project. Load `linear-issue-create` to create the issues into it, then Load `linear-update` to move the description from research framing to the build plan, and set its state to `planned`. | — |
| **Issue** | Turn it into an issueset: the research issue becomes the parent container, its description rewritten to the shared description; Load `linear-issue-create` for the sub-issues with `parentId` set. The research documents stay on the parent. | **Project:** Load `linear-project-create` seeded with the research; write the documents onto the project through `linear-document`; comment on the original issue linking the project; Load `linear-status` to move it to `Done`. |

A finalized record keeps its research documents; the dropped plans and paths stay documented, so the build plan can be traced back to the research.

## Close Out — Reconcile to the End State

Every run ends with the record matching where the conversation landed:

1. Description states the current conclusion and the current "Read first" list.
2. Each document reflects the final state of its concern; a superseded plan is marked superseded with the reason, not deleted.
3. Each deviation from the previous record has a comment.
4. After Finalize, Load `linear-reconcile` on the resulting project or issueset to audit states, parents, and blocking relations.
5. Report the record, every document and comment written, and every issue created, with titled links.

## Examples

**Capture as an issue:**
1. User: "park this research in Linear" after a session comparing three cache invalidation strategies.
2. Propose one issue plus Findings, Plan: event-driven invalidation, Shortfalls and risks, Paths considered (TTL-only, write-through), Open questions.
3. Present, write on approval, report the issue and five documents.

**Adopt and finalize into an issueset:**
1. User: "finalize K-310" — an existing research issue.
2. Fetch the issue, its documents and comments; the conversation dropped one plan since the last update, so comment the deviation and mark that plan document superseded.
3. Shape the work with `linear-structure-agent`, rewrite K-310 as the parent, create the per-repo sub-issues under it, run `linear-reconcile` on the set, report.

**Adopt an issue and promote to a project:**
1. User: "this research is too big for an issue, make it a project."
2. Create the project through `linear-project-create`, write the research documents onto it, comment on the issue with the project link, move the issue to `Done`, report both.
