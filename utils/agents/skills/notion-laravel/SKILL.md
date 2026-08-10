---
name: notion-laravel
description: notion-laravel Auto-invoked on Notion context - a Notion URL or page reference in Laravel work. Initialises the Notion session for that workspace. Not for pulling a page into the editor, or pushing one back.
---

## Notion Workspace: Laravel

## Workspace Context

- **Notion:** Available via **claude.ai connector** tools (prefix `mcp__claude_ai_Notion__*`, deferred).
- **Tools are deferred** — load via `ToolSearch` before each use:
  ```
  ToolSearch({ query: "select:mcp__claude_ai_Notion__notion-search,mcp__claude_ai_Notion__notion-fetch" })
  ```

## Available Tools (`mcp__claude_ai_Notion__`)

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

## After Initialization

Once context is established, proceed with the user's request. If the user wants to pull or push pages, follow the `notion-pull` or `notion-push` skill workflows.
