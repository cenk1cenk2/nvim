---
name: slack-laravel
description: 'slack-laravel Initialize a Slack session for the Laravel enterprise workspace. Auto-invoked on enterprise Slack context (work Slack URLs, Laravel org channels, GitHub Laravel repos).'
references:
  - ../references/present-first.md
  - ../references/harness-connectors.md
---

## Slack Workspace: Laravel

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> **⛔ This skill selects the workspace, not the transport.** Read the `harness-connectors` reference — the harness-provided Slack integration is used for this service; a standalone Slack MCP server would be a stated fallback only.

## Workspace Context

- **Slack:** Available via **claude.ai connector** tools (prefix `mcp__claude_ai_Slack__*` in direct Claude Code CLI).
- **Transport:** Remote HTTP (`https://mcp.slack.com/mcp`), OAuth via claude.ai.
- **Linked SCM:** GitHub (Laravel organization).
- **Linked Linear:** `linear-laravel` (Laravel workspace).

## Available Tools

These tools are **deferred** — they must be loaded via `ToolSearch` before use. Load only the tools you need for the current task.

| Tool                              | Purpose                                             |
| --------------------------------- | --------------------------------------------------- |
| `slack_search_public`             | Search messages in public channels.                 |
| `slack_search_public_and_private` | Search messages across public and private channels. |
| `slack_search_channels`           | Search for channels by name or topic.               |
| `slack_search_users`              | Search for users by name or email.                  |
| `slack_read_channel`              | Read recent messages from a channel.                |
| `slack_read_thread`               | Read all replies in a message thread.               |
| `slack_read_user_profile`         | Get detailed profile for a specific user.           |
| `slack_send_message`              | Send a message to a channel or thread.              |
| `slack_send_message_draft`        | Draft and format a message before sending.          |
| `slack_schedule_message`          | Schedule a message for later delivery.              |
| `slack_create_canvas`             | Create a new Slack canvas document.                 |
| `slack_read_canvas`               | Read an existing canvas.                            |
| `slack_update_canvas`             | Update an existing canvas.                          |

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
- Has `slack_add_reaction` — emoji reactions are supported (connector tool `mcp__claude_ai_Slack__slack_add_reaction`).

## After Initialization

Once context is established, proceed with the user's request. If the user wants to process a message or channel, follow the `slack-message` or `slack-channel` skill workflow.
