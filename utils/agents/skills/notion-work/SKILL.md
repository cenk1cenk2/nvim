---
name: notion-work
description: "Initialize a Notion session for the Laravel workspace. Auto-invoked when Notion context is detected (e.g., Notion URLs, references to Notion pages in Laravel workspace context). Do NOT use for pulling (notion-pull) or pushing (notion-push) pages."
interaction: chat
references:
  - ../references/claude-ai-connectors.md
---

## system

### Notion Workspace: Laravel

> **DO NOT enter plan mode.** This skill initializes workspace context only.

### Workspace Context

- **Notion:** Available via **claude.ai connector** tools (prefix `mcp__claude_ai_Notion__*`, deferred).
- **Tools are deferred** — load via `ToolSearch` before each use:
  ```
  ToolSearch({ query: "select:mcp__claude_ai_Notion__notion-search,mcp__claude_ai_Notion__notion-fetch" })
  ```

### Available Tools (`mcp__claude_ai_Notion__`)

| Tool | Purpose |
|------|---------|
| `notion-search` | Find pages by query. |
| `notion-fetch` | Retrieve page content by URL or ID. |
| `notion-update-page` | Modify page properties and content. |
| `notion-create-pages` | Create new pages. |
| `notion-create-comment` | Add comments to pages. |
| `notion-get-comments` | Read comments on a page. |
| `notion-get-users` | List workspace users. |
| `notion-get-teams` | List workspace teams. |
| `notion-create-database` | Create a new database. |
| `notion-create-view` | Create a database view. |
| `notion-update-view` | Update a database view. |
| `notion-update-data-source` | Update a data source. |
| `notion-duplicate-page` | Duplicate an existing page. |
| `notion-move-pages` | Move pages to a different parent. |

All tool names above are the short form. Full name: `mcp__claude_ai_Notion__<tool>` (e.g., `mcp__claude_ai_Notion__notion-search`).

### After Initialization

Once context is established, proceed with the user's request. If the user wants to pull or push pages, follow the `notion-pull` or `notion-push` skill workflows.
