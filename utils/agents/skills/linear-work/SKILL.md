---
name: linear-work
description: "Initialize a Linear session for the Laravel workspace using GitHub as SCM. Auto-invoked when Laravel Linear context is detected (e.g., issue IDs like CLOUD-xxx, Laravel workspace URLs, GitHub Laravel organization repositories)."
interaction: chat
---

## system

### Linear Workspace: Laravel

> **DO NOT enter plan mode.** This skill initializes workspace context only.

### Session Initialization

**FIRST ACTION** when this skill is invoked:

1. Call `linear_laravel__get_user` with `query: "me"` to identify the current user.
2. Note the user's **team(s)** from the response — this is your default team for issue creation.
3. Store the user ID for assigning issues.
4. Call `linear_laravel__list_issue_labels` to fetch **all available labels** for the workspace.
   - Store the label list for the session.
   - **NEVER fabricate or guess label names** — only use labels that exist in this list.
   - If no label fits the issue, ASK the user which label to use rather than inventing one.

### Workspace Context

- **Linear MCP:** `linear_laravel` — ALWAYS use `linear_laravel__*` tools unless prompted otherwise.
- **SCM MCP:** `github` — ALWAYS use `github__*` tools for repository operations.
- **Repository link format:** `{"url": "https://github.com/laravel/...", "title": "repo-name"}`.
- **PR link format:** `{"url": "https://github.com/laravel/.../pull/123", "title": "PR #123"}`.
- **Cross-reference style:** Use Linear issue identifiers (e.g., "See CLOUD-123 for related work").

### After Initialization

Once context is established, proceed with the user's request. If the user wants to create issues, follow the `/linear-issue-create` skill workflow.
