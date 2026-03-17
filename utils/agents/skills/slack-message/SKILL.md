---
name: slack-message
description: Process a Slack message link — reads the thread, understands context, and acts on user instructions by composing with other skills. Always manually invoked. Do NOT use for channel-wide catch-up (/slack-channel).
interaction: chat
disable-model-invocation: true
argument-hint: "[slack-message-url] [what to do with it]"
references:
  - ../references/slack.md
  - ../references/output-diff.md
---

## system

### Slack Message Processor

> **DO NOT enter plan mode.** This skill gathers context and delegates to other skills or acts directly based on user instructions.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

### Context

> Read the `slack` reference for available Slack MCP tools, response conventions, reaction rules, and large results handling — resolve references from the `<References>` block via MCP filesystem tools.

The user provides a Slack message URL and a task. This skill reads the message and its full thread, synthesizes the context, and then acts on the user's request — which may involve invoking other skills (e.g., `/linear-issue-implement`, `/obsidian-note`, `/code-pull`) or performing direct actions (research, code changes, summarization).

### Process

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

1. **Parse the message.**
   - Parse the Slack message URL to identify the channel ID and message timestamp.

2. **Extract the message.**
   - Use `slack__slack_get_channel_history` to fetch the message if only the channel and timestamp are known.
   - If the message is part of a thread, use `slack__slack_get_thread_replies` to read the **entire thread** (all replies).
   - Resolve user IDs to real names using `slack__slack_get_users` or `slack__slack_get_user_profile` for a readable summary.
   - If the URL contains a channel name instead of an ID, use `slack__slack_list_channels` to resolve it.
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
     - **Create a Linear issue** — invoke the appropriate Linear workspace skill and compose with `/linear-issue-implement` or create directly.
     - **Create an Obsidian note** — invoke `/obsidian-note` with the thread context.
     - **Research a topic** — use web search, Context7, or codebase exploration based on what the thread discusses.
     - **Write or modify code** — use the thread context to inform implementation.
     - **Summarize** — reply in thread via `slack__slack_reply_to_thread` with the summary and add `:dark_sunglasses:` reaction to the message.
     - **Reply** — draft a response and present it for approval. **Always use `slack__slack_reply_to_thread`** to keep conversations in threads. Only use `slack__slack_post_message` for a new channel-level message when there is no thread context or the user explicitly asks.
     - **React** — add an emoji reaction via `slack__slack_add_reaction` when the user asks.

5. **Compose with other skills.**
   - When delegating to another skill, pass the thread context as input — do not make the other skill re-fetch it.
   - Respect the invoked skill's workflow (plan mode, prompts, etc.).
   - If multiple skills are relevant, ask the user which to use.

### Key Principles

- **Read the full thread.** A single message without thread context is often insufficient. Always fetch the complete thread.
- **Compose, don't duplicate.** When another skill handles the action better, invoke it with the gathered context rather than reimplementing its workflow.
- Follow the response conventions (thread vs channel, `:dark_sunglasses:`, approval rules) from the slack reference.

### Examples

**User says:** `/slack-message https://slack.com/archives/C123/p456 create a Linear issue from this`

1. Parse URL → channel `C123`, timestamp `456`.
2. Fetch thread via `slack__slack_get_thread_replies`.
3. Resolve user IDs to names.
4. Summarize: "Alice reported a DNS resolution bug in cluster-rubik. Bob confirmed it affects all pods."
5. Invoke `/linear-kilic` → compose with issue creation using thread context.

**Result:** Linear issue created with thread summary, participants, and relevant details.

---

**User says:** `/slack-message https://slack.com/archives/C789/p012 summarize this`

1. Parse URL, fetch full thread.
2. Resolve user names.
3. Present summary in chat.
4. Reply in thread with summary via `slack__slack_reply_to_thread`.
5. Add `:dark_sunglasses:` reaction.

**Result:** Summary posted in thread, reaction added.
