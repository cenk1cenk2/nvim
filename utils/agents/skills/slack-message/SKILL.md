---
name: slack-message
description: Process a Slack message link — reads the thread, understands context, and acts on user instructions by composing with other skills. Use when the user shares a Slack message URL and wants to take action based on its content.
interaction: chat
disable-model-invocation: true
argument-hint: "[slack-message-url] [what to do with it]"
---

## system

### Slack Message Processor

> **DO NOT enter plan mode.** This skill gathers context and delegates to other skills or acts directly based on user instructions.

### Context

The user provides a Slack message URL and a task. This skill reads the message and its full thread, synthesizes the context, and then acts on the user's request — which may involve invoking other skills (e.g., `/linear-issue-pick`, `/obsidian-note`, `/code-pull`) or performing direct actions (research, code changes, summarization).

### Available Tools

| Tool | Purpose |
|------|---------|
| `mcp__mcphub__slack__slack_get_channel_history` | Fetch recent messages from a channel. |
| `mcp__mcphub__slack__slack_get_thread_replies` | Fetch all replies in a message thread. |
| `mcp__mcphub__slack__slack_list_channels` | Resolve channel name to ID. |
| `mcp__mcphub__slack__slack_get_users` | List workspace users (resolve user IDs to names). |
| `mcp__mcphub__slack__slack_get_user_profile` | Get detailed profile for a specific user ID. |
| `mcp__mcphub__slack__slack_post_message` | Post a new message to a channel. |
| `mcp__mcphub__slack__slack_reply_to_thread` | Reply to a specific thread. |
| `mcp__mcphub__slack__slack_add_reaction` | Add an emoji reaction to a message. |

### Process

1. **Parse the message.**
   - Parse the Slack message URL to identify the channel ID and message timestamp.

2. **Extract the message.**
   - Use `slack_get_channel_history` to fetch the message if only the channel and timestamp are known.
   - If the message is part of a thread, use `slack_get_thread_replies` to read the **entire thread** (all replies).
   - Resolve user IDs to real names using `slack_get_users` or `slack_get_user_profile` for a readable summary.
   - If the URL contains a channel name instead of an ID, use `slack_list_channels` to resolve it.
   - If the thread references other channels or messages, note them but do not fetch unless the user asks.

3. **Summarize the context.**
   - Present a concise summary of the thread to the user:
     - Who is involved (resolved names, not IDs).
     - What is being discussed.
     - Key decisions, requests, or action items.
     - Any links, code snippets, or references shared.
   - Keep the summary brief — focus on what's actionable.

4. **Determine the action.**
   - If the user provided explicit instructions (e.g., "create a Linear issue from this", "summarize this in Obsidian"), follow them.
   - If the user's intent is unclear, present the summary and ask what they'd like to do.
   - Common actions:
     - **Create a Linear issue** — invoke the appropriate Linear workspace skill and compose with `/linear-issue-pick` or create directly.
     - **Create an Obsidian note** — invoke `/obsidian-note` with the thread context.
     - **Research a topic** — use web search, Context7, or codebase exploration based on what the thread discusses.
     - **Write or modify code** — use the thread context to inform implementation.
     - **Summarize** — reply in thread via `slack_reply_to_thread` with the summary and add `:dark_sunglasses:` reaction to the message.
     - **Reply** — draft a response and present it for approval. **Always use `slack_reply_to_thread`** to keep conversations in threads. Only use `slack_post_message` for a new channel-level message when there is no thread context or the user explicitly asks.
     - **React** — add an emoji reaction via `slack_add_reaction` when the user asks.

5. **Compose with other skills.**
   - When delegating to another skill, pass the thread context as input — do not make the other skill re-fetch it.
   - Respect the invoked skill's workflow (plan mode, prompts, etc.).
   - If multiple skills are relevant, ask the user which to use.

### Key Principles

- **Read the full thread.** A single message without thread context is often insufficient. Always fetch the complete thread.
- **Always reply in threads.** This skill processes a single message — use `slack_reply_to_thread` by default. Channel-level messages (`slack_post_message`) only when there is no existing thread or the user explicitly requests it.
- **`:dark_sunglasses:` = processed.** Add the reaction only after you have written a response (thread reply or summary) for the message. It means "I handled this", not "I read this".
- **Never send ad-hoc replies without approval.** Summaries and reactions are automatic. Other thread replies require explicit user confirmation of the draft content.
- **Compose, don't duplicate.** When another skill handles the action better, invoke it with the gathered context rather than reimplementing its workflow.
- **Slack context is ephemeral.** Summarize key information in chat so the user has it even if the thread evolves later.
