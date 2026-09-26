---
name: slack-laravel
description: slack-laravel Auto-invoked on work Slack context - Laravel workspace URLs, org channels, or Laravel GitHub repos. Initialises the Slack session for that workspace. Not for personal kilic Slack context.
references:
  - ../references/harness/harness-connectors.md
  - ../references/slack.md
---

## Slack Workspace: Laravel

> **ABSOLUTE — Laravel routes through the claude.ai Slack connector only; the catalog holds no standalone server for it.** Workspace routing per `slack`.

## Workspace Context

- **Slack:** Available via **claude.ai connector** tools (prefix `mcp__claude_ai_Slack__*` in direct Claude Code CLI).
- **Transport:** Remote HTTP (`https://mcp.slack.com/mcp`), OAuth via claude.ai.
- **Linked SCM:** GitHub (Laravel organization).
- **Linked Linear:** `linear-laravel` (Laravel workspace).

## Available Tools

Connector tool list per `harness-connectors` (Slack section). These tools are **deferred** — load only the ones the current task needs.

**Loading tools:** Use `ToolSearch` to load tools before calling them:

```
ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message,mcp__claude_ai_Slack__slack_read_channel" })
```

Or search by keyword:

```
ToolSearch({ query: "+Slack send message" })
```

## Notable Differences from `slack-kilic`

- Has powerful **search** capabilities (not available in kilic workspace).
- Has **canvas** support for document creation.
- Has **message scheduling** and **draft** support.
- Has `slack_add_reaction` — emoji reactions are supported.

## After Initialization

Once context is established, proceed with the user's request. If the user wants to process a message or channel, follow the `slack-message` or `slack-channel` skill workflow.
