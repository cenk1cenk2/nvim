---
name: notion-laravel
description: notion-laravel Auto-invoked on Notion context - a Notion URL or page reference in Laravel work. Initialises the Notion session for that workspace. Not for pulling a page into the editor, or pushing one back.
references:
  - ../references/harness/harness-connectors.md
---

## Notion Workspace: Laravel

## Workspace Context

- **Notion:** Available via **claude.ai connector** tools (prefix `mcp__claude_ai_Notion__*`, deferred) — connector-only, no standalone server fallback. Tool list per `harness-connectors` (Notion section).
- **Tools are deferred** — load via `ToolSearch` before each use:
  ```
  ToolSearch({ query: "select:mcp__claude_ai_Notion__notion-search,mcp__claude_ai_Notion__notion-fetch" })
  ```

## After Initialization

Once context is established, proceed with the user's request. If the user wants to pull or push pages, follow the `notion-pull` or `notion-push` skill workflows.
