---
name: slack-kilic
description: slack-kilic Auto-invoked on personal Slack context - kilic Slack URLs, kilic channels, or GitLab-related discussion. Initialises the Slack session for that workspace. Not for work Slack or Laravel context.
references:
  - ../references/harness/harness-connectors.md
  - ../references/slack.md
---

## Slack Workspace: kilic

> **ABSOLUTE — kilic routes through `slack-kilic` only, never the claude.ai connector.** Workspace routing per `slack`; harness precedence per `harness-connectors`.

## Workspace Context

- **Workspace:** kilic (`kilic-dev.slack.com`).
- **Slack MCP:** `slack-kilic` — stdio (`@modelcontextprotocol/server-slack`), bot token auth.
- **Linked SCM:** GitLab (`gitlab.kilic.dev`).
- **Linked Linear:** `linear-kilic` (kilic-dev workspace).

## After Initialization

Once context is established, proceed with the user's request. If the user wants to process a message or channel, follow the `slack-message` or `slack-channel` skill workflow.
