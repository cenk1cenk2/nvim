---
name: slack-work
description: "Initialize a Slack session for the Laravel enterprise workspace. Auto-invoked when enterprise Slack context is detected (e.g., work Slack URLs, Laravel organization channels, GitHub Laravel repositories)."
interaction: chat
---

## system

### Slack Workspace: Laravel

> **DO NOT enter plan mode.** This skill initializes workspace context only.

### Workspace Context

- **Slack MCP:** `slack/laravel` — ALWAYS use `slack_laravel__*` tools for this workspace.
- **Transport:** Remote HTTP (`https://mcp.slack.com/mcp`), OAuth auth.
- **Linked SCM:** GitHub (Laravel organization).
- **Linked Linear:** `linear_laravel` (Laravel workspace).

### Available Tools

The remote Slack MCP server exposes a different tool set from the stdio server:

| Category | Capabilities |
|----------|-------------|
| **Search** | Messages, files, users, channels with date/user/content filters. |
| **Messaging** | Send messages, read channel history, read thread conversations. |
| **Canvases** | Create, update, read, and export formatted documents as markdown. |
| **Users** | Fetch profiles, access custom fields and statuses. |

**Notable differences from `slack-kilic`:**
- Has powerful **search** capabilities (not available in kilic workspace).
- Has **canvas** support for document creation.
- Does **NOT** have `slack_add_reaction` — no emoji reaction support.

> **Note:** Exact tool names will be confirmed after initial OAuth authorization. Update this skill with the actual tool inventory once connected.

### After Initialization

Once context is established, proceed with the user's request. If the user wants to process a message or channel, follow the `slack-message` or `slack-channel` skill workflow.
