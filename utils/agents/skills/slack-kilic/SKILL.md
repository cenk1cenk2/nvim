---
name: slack-kilic
description: slack-kilic Auto-invoked on personal Slack context - kilic Slack URLs, kilic channels, or GitLab-related discussion. Initialises the Slack session for that workspace.
references:
  - ../references/harness-connectors.md
  - ../references/slack.md
---

## Slack Workspace: kilic

> **⛔ The workspace decides the integration.** kilic is reachable **only** through the standalone `slack-kilic` server. The claude.ai Slack connector (`mcp__claude_ai_Slack__*`) reaches the Laravel workspace and nothing else — routing kilic traffic through it reads and posts into the wrong workspace. Tool-by-tool routing per `slack`; the harness precedence this mapping carves out of is in `harness-connectors`.

## Workspace Context

- **Workspace:** kilic (`kilic-dev.slack.com`).
- **Slack MCP:** `slack-kilic` — stdio (`@modelcontextprotocol/server-slack`), bot token auth.
- **Linked SCM:** GitLab (`gitlab.kilic.dev`).
- **Linked Linear:** `linear-kilic` (kilic-dev workspace).

## After Initialization

Once context is established, proceed with the user's request. If the user wants to process a message or channel, follow the `slack-message` or `slack-channel` skill workflow.
