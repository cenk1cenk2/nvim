---
name: linear-issue-checklist
description: Update a Linear issue's checklist by marking items as done or cancelled. Use when user says "mark task as done", "update the checklist", "check off this item", or "cancel this task". Do NOT use for commenting (/linear-issue-comment) or updating the issue description (/linear-issue-update).
interaction: chat
argument-hint: "[issue-id or Linear URL] [items to update]"
references:
  - ../references/output-diff.md
---

## system

### Linear Issue Checklist Update

> **DO NOT enter plan mode for this prompt.**
>
> - Quick checklist updates — confirm with user, then apply.
> - When composed from `linear-issue-status` or `agents-kilic-pickup` for `In Review` / `Done` close-out, apply checklist updates directly when completion evidence is clear.

### Prerequisite

> **PREREQUISITE: A Linear workspace skill MUST be active before this skill runs.**
>
> If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:
> - **kilic-dev workspace:** Load skill `linear-kilic` via the `linear-kilic` skill (load it as defined in `load-skills`)
> - **Laravel workspace:** Load skill `linear-laravel` via the `linear-laravel` skill (load it as defined in `load-skills`)
>
> Deduce the workspace from context: issue ID prefixes (K-xxx → kilic-dev, CLOUD-xxx → Laravel), Linear URLs, repository hosting (GitLab → kilic-dev, GitHub → Laravel). If a full Linear URL is provided, deduce the workspace from the URL directly.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

### Process

1. **Fetch the issue** using the appropriate Linear MCP tools. Also fetch comments using `list_comments` — comments may reference checklist items being completed, cancelled, or changed.
2. **Extract the current checklist** from the issue description.
3. **Present the checklist to the user** and confirm which items to update.
4. **Apply changes** only after user confirmation.
5. **Status handoff** — if the checklist update completes the implementation or moves the issue into review, compose with `linear-issue-status` to move the issue to `In Review` or `Done`.

### Checklist Markup

- **Done:** `- [x] item text`
- **Cancelled:** `- [ ] ~item text~` (strikethrough, item remains unchecked).
- **Pending:** `- [ ] item text` (unchanged).

Cancellation is only applied when the user explicitly says an item is cancelled — never assume.

### Key Rules

- **Confirm before standalone updates** — show the user what will change.
- **Close-out exception** — when composed from status or pickup workflows, clear implementation evidence can mark checklist items done without a second confirmation.
- **Never cancel without explicit user input.**
- **Preserve all other issue content** — only modify the checklist items discussed.
- **Compose with status updates** — when checklist completion clearly implies `In Review` or `Done`, use `linear-issue-status` rather than editing state inline here.
