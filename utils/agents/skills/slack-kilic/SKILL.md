---
name: slack-kilic
description: 'slack-kilic Initialize a Slack session for the kilic workspace. Auto-invoked on kilic Slack context (personal Slack URLs, kilic channels, GitLab-related discussions).'
references:
  - ../references/present-first.md
  - ../references/harness-connectors.md
---

## Slack Workspace: kilic

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> **⛔ This skill selects the workspace, not the transport.** Read the `harness-connectors` reference: when the harness provides Slack (on Claude Code, `mcp__claude_ai_Slack__*`), the calls go through it. `slack-kilic__*` is the fallback for when the harness offers no Slack integration or lacks a needed capability — and using it is stated out loud, never mixed into a flow that started on the connector.

## Workspace Context

- **Workspace:** kilic (`kilic-dev.slack.com`).
- **Fallback Slack MCP:** `slack-kilic` — stdio (`@modelcontextprotocol/server-slack`), bot token auth.
- **Linked SCM:** GitLab (`gitlab.kilic.dev`).
- **Linked Linear:** `linear-kilic` (kilic-dev workspace).

## Fallback Tools (workspace server)

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

## After Initialization

Once context is established, proceed with the user's request. If the user wants to process a message or channel, follow the `slack-message` or `slack-channel` skill workflow.
