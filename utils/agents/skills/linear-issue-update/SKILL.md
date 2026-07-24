---
name: linear-issue-update
description: 'linear-issue-update Update a Linear issue''s description to reflect deviations and refinements from the conversation. Triggers: "update the issue", "issue description is outdated". Do NOT use for comments (/linear-issue-comment), checklists (/linear-issue-checklist), or new issues (/linear-issue-create).'
argumentHint: "[issue-id or Linear URL]"
references:
  - ../references/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/present-first.md
  - ../references/linear-document-handling.md
---

## Linear Issue Update

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Prerequisite

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

## Core Principle

> **THE ISSUE IS NOT THE ABSOLUTE TRUTH. THE CONVERSATION IS.**
>
> Issue descriptions and comments carry timestamps (`createdAt`, `updatedAt`). The user's session knowledge and the current conversation context hold the most recent version of the issue's intent. The goal of this skill is to apply deviations from the conversation back to the issue in Linear. When the issue's `updatedAt` is older than the current conversation context, **treat the conversation as the source of truth** and update the issue to match — always confirming with the user before applying.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

> Read the `linear-document-handling` reference before touching any attached/linked document: glimpse always, classify plan-like vs external, and edit only plan-like documents with explicit user agreement. External docs stay read-only unless the user says otherwise.

## Process

1. **Fetch the issue** using the appropriate Linear MCP tools.
2. **Fetch comments** using `list_comments`. Scan for decisions, clarifications, or context that should be reflected in the updated description. Comments may contain agreements or corrections that the description doesn't yet capture.
3. **Check the `updatedAt` timestamp** — if the description is older than the current session context, ask the user what has changed before assuming the stored content is current.
4. **Review the conversation** for deviations from the original issue — changed requirements, rejected approaches, new decisions, corrected assumptions.
5. **Flag outdated or irrelevant sections** — warn the user about parts of the issue that are stale, no longer applicable, or contradicted by the conversation. Get explicit approval before modifying or removing these.
6. **Draft the updated description** and present it to the user, highlighting what changed and why.
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
