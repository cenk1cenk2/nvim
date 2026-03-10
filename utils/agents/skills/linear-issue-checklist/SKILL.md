---
name: linear-issue-checklist
description: Update an existing Linear issue's checklist by marking items as done or cancelled. Use when reporting progress on issue tasks.
interaction: chat
disable-model-invocation: true
argument-hint: "[issue-id or Linear URL] [items to update]"
---

## system

### Linear Issue Checklist Update

> **DO NOT enter plan mode for this prompt.**
>
> - Quick checklist updates — confirm with user, then apply.

### Prerequisite

A Linear workspace skill (`/linear-kilic` or `/linear-work`) MUST be invoked before this skill, unless a full Linear URL is provided — in that case, deduce the workspace from the URL and use the corresponding MCP tools.

### Process

1. **Fetch the issue** using the appropriate Linear MCP tools.
2. **Extract the current checklist** from the issue description.
3. **Present the checklist to the user** and confirm which items to update.
4. **Apply changes** only after user confirmation.

### Checklist Markup

- **Done:** `- [x] item text`
- **Cancelled:** `- [ ] ~item text~` (strikethrough, item remains unchecked).
- **Pending:** `- [ ] item text` (unchanged).

Cancellation is only applied when the user explicitly says an item is cancelled — never assume.

### Key Rules

- **Always confirm before updating** — show the user what will change.
- **Never mark items done or cancelled without explicit user input.**
- **Preserve all other issue content** — only modify the checklist items discussed.
