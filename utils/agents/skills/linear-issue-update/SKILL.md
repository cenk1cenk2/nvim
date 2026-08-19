---
name: linear-issue-update
description: linear-issue-update Rewrite a Linear issue's description so it reflects the deviations and refinements the conversation produced. Use on "update the issue", "the description is out of date". Not for a state change alone, a comment, checklist items, or a new issue.
argumentHint: '[issue id or URL]'
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/linear/linear-document-handling.md
  - ../references/linear/linear-issue-philosophy.md
  - ../references/linear/linear-description-structure.md
  - ../references/identifier-legibility.md
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## Linear Issue Update

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

## Core Principle

> **THE ISSUE IS NOT THE ABSOLUTE TRUTH. THE CONVERSATION IS.** Record vs conversation authority, and the timestamp check that decides it, per `linear-issue-philosophy`. The goal of *this* skill is to apply deviations from the conversation back to the issue in Linear: when the issue's `updatedAt` is older than the current conversation, update the issue to match, always confirming with the user before applying.

Attached/linked documents follow `linear-document-handling`: glimpse always, classify plan-like vs external, and edit only plan-like documents with explicit user agreement. External docs stay read-only unless the user says otherwise.

## Process

1. **Fetch the issue** using the appropriate Linear MCP tools.
2. **Fetch comments** using `list_comments`. Scan for decisions, clarifications, or context that should be reflected in the updated description. Comments may contain agreements or corrections that the description doesn't yet capture.
3. **Check the `updatedAt` timestamp** — if the description is older than the current session context, ask the user what has changed before assuming the stored content is current.
4. **Review the conversation** for deviations from the original issue — changed requirements, rejected approaches, new decisions, corrected assumptions.
5. **Flag outdated or irrelevant sections** — warn the user about parts of the issue that are stale, no longer applicable, or contradicted by the conversation. Get explicit approval before modifying or removing these.
6. **Draft the updated description**, section shape per `linear-description-structure`, and present it to the user per `output-diff`, highlighting what changed and why.
7. **Iterate** based on user feedback. This is a refining process — work with the user to get the issue into a state that accurately reflects the current understanding.
8. **Apply changes** only after user approval.

## What to Update

- **Description text** — rewrite sections that no longer reflect the agreed approach.
- **Task lists** — add, remove, check, or cancel items to match the current plan.
- **`## Thoughts` section** — add at the end of the description with a markdown list of key deviations and the reasoning behind them.

## Thoughts Section Format

```markdown
## Thoughts

- Switched from X to Y because Z.
- Dropped requirement A — not needed after discovering B.
- Added step C which was missing from the original scope.
```

Only include deviations that matter for future readers understanding *why* the issue looks different from what was originally written.

## Key Rules

- **Never modify the issue without user approval.**
- **Preserve content that hasn't changed** — only update what deviated.
- **The Thoughts section documents *why*, not *what*** — the description itself reflects the *what*.
- **Prefer comments for small deviations** — in autonomous agent workflows, update descriptions only when future agents need the rewritten description to stay aligned or when the issue requires a huge rewrite because it is materially out of whack.
