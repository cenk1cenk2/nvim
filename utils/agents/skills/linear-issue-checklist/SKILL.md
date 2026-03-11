---
name: linear-issue-checklist
description: Update a Linear issue's checklist by marking items as done or cancelled. Use when user says "mark task as done", "update the checklist", "check off this item", or "cancel this task". Do NOT use for commenting (/linear-issue-comment) or updating the issue description (/linear-issue-update).
interaction: chat
argument-hint: "[issue-id or Linear URL] [items to update]"
---

## system

### Linear Issue Checklist Update

> **DO NOT enter plan mode for this prompt.**
>
> - Quick checklist updates — confirm with user, then apply.

### Prerequisite

> **PREREQUISITE: A Linear workspace skill MUST be active before this skill runs.**
>
> If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:
> - **kilic-dev workspace:** Load `~/.config/nvim/utils/agents/skills/linear-kilic/SKILL.md`
> - **Laravel workspace:** Load `~/.config/nvim/utils/agents/skills/linear-work/SKILL.md`
>
> Deduce the workspace from context: issue ID prefixes (K-xxx → kilic-dev, CLOUD-xxx → Laravel), Linear URLs, repository hosting (GitLab → kilic-dev, GitHub → Laravel). If a full Linear URL is provided, deduce the workspace from the URL directly.

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
