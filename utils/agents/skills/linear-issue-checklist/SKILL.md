---
name: linear-issue-checklist
description: linear-issue-checklist Tick or cancel items on a Linear issue's checklist. Use on "mark that task done", "check off this item". Not for leaving a comment, or for rewriting the description.
argumentHint: '[issue id or URL] [items to update]'
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear-prerequisite.md
  - ../references/output-diff.md
---

## Linear Issue Checklist Update

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill must be active first — detection rules in `linear-prerequisite`.

## Process

1. **Fetch the issue** using the appropriate Linear MCP tools. Also fetch comments using `list_comments` — comments may reference checklist items being completed, cancelled, or changed.
2. **Extract the current checklist** from the issue description.
3. **Present the checklist to the user** per `output-diff` and confirm which items to update.
4. **Apply changes** only after user confirmation.
5. **Status handoff** — if the checklist update completes the implementation or moves the issue into review, compose with `linear-issue-status` to move the issue to `In Review` or `Done`.

## Checklist Markup

- **Done:** `- [x] item text`
- **Cancelled:** `- [ ] ~item text~` (strikethrough, item remains unchecked).
- **Pending:** `- [ ] item text` (unchanged).

Cancellation is only applied when the user explicitly says an item is cancelled — never assume.

## Key Rules

- **Confirm before standalone updates** — show the user what will change.
- **Close-out exception** — when composed from status or pickup workflows, clear implementation evidence can mark checklist items done without a second confirmation.
- **Never cancel without explicit user input.**
- **Preserve all other issue content** — only modify the checklist items discussed.
- **Compose with status updates** — when checklist completion clearly implies `In Review` or `Done`, use `linear-issue-status` rather than editing state inline here.
