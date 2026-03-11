---
name: notion-work
description: "Initialize a Notion session for the Laravel workspace. Auto-invoked when Notion context is detected (e.g., Notion URLs, references to Notion pages in Laravel workspace context). Do NOT use for pulling (/notion-pull) or pushing (/notion-push) pages."
interaction: chat
---

## system

### Notion Workspace: Laravel

> **DO NOT enter plan mode.** This skill initializes workspace context only.

### Session Initialization

**FIRST ACTION** when this skill is invoked:

1. Call `notion_laravel__notion-get-self` to identify the bot user and workspace.
2. Note the workspace name and bot permissions from the response.
3. Store the workspace context for the session.

### Workspace Context

- **Notion MCP:** `notion_laravel` — ALWAYS use `notion_laravel__*` tools.
- **Search tool:** `notion_laravel__notion-search` — for finding pages by query.
- **Fetch tool:** `notion_laravel__notion-fetch` — for retrieving page content by URL or ID.
- **Update tool:** `notion_laravel__notion-update-page` — for modifying page properties and content.
- **Create tool:** `notion_laravel__notion-create-pages` — for creating new pages.
- **Comment tool:** `notion_laravel__notion-create-comment` — for adding comments to pages.

### After Initialization

Once context is established, proceed with the user's request. If the user wants to pull or push pages, follow the `/notion-pull` or `/notion-push` skill workflows.
