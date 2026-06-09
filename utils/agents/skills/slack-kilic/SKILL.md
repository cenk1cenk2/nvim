---
name: slack-kilic
description: "Initialize a Slack session for the kilic workspace. Auto-invoked when kilic Slack context is detected (e.g., personal Slack URLs, kilic workspace channels, GitLab-related discussions)."
interaction: chat
---

## system

### Slack Workspace: kilic

> **DO NOT enter plan mode.** This skill initializes workspace context only.

### Workspace Context

- **Slack MCP:** `slack-kilic` — ALWAYS use `slack-kilic__*` tools for this workspace.
- **Transport:** Stdio (`@modelcontextprotocol/server-slack`), bot token auth.
- **Linked SCM:** GitLab (`gitlab.kilic.dev`).
- **Linked Linear:** `linear-kilic` (kilic-dev workspace).

### Available Tools

| Tool | Purpose |
|------|---------|
| `slack-kilic__slack_list_channels` | Resolve channel name to ID. |
| `slack-kilic__slack_get_channel_history` | Fetch recent messages from a channel. |
| `slack-kilic__slack_get_thread_replies` | Fetch all replies in a message thread. |
| `slack-kilic__slack_get_users` | List workspace users (resolve user IDs to names). |
| `slack-kilic__slack_get_user_profile` | Get detailed profile for a specific user ID. |
| `slack-kilic__slack_post_message` | Post a new message to a channel. |
| `slack-kilic__slack_reply_to_thread` | Reply to a specific thread. |
| `slack-kilic__slack_add_reaction` | Add an emoji reaction to a message. |

### After Initialization

Once context is established, proceed with the user's request. If the user wants to process a message or channel, follow the `slack-message` or `slack-channel` skill workflow.
