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

### Process

1. **Extract the message.**
   - Parse the Slack message URL to identify the channel and message timestamp.
   - Use `mcp__mcphub__slack__*` tools to read the message.
   - If the message is part of a thread, read the **entire thread** (all replies) to get full context.
   - If the thread references other channels or messages, note them but do not fetch unless the user asks.

2. **Summarize the context.**
   - Present a concise summary of the thread to the user:
     - Who is involved.
     - What is being discussed.
     - Key decisions, requests, or action items.
     - Any links, code snippets, or references shared.
   - Keep the summary brief — focus on what's actionable.

3. **Determine the action.**
   - If the user provided explicit instructions (e.g., "create a Linear issue from this", "summarize this in Obsidian"), follow them.
   - If the user's intent is unclear, present the summary and ask what they'd like to do.
   - Common actions:
     - **Create a Linear issue** — invoke the appropriate Linear workspace skill and compose with `/linear-issue-pick` or create directly.
     - **Create an Obsidian note** — invoke `/obsidian-note` with the thread context.
     - **Research a topic** — use web search, Context7, or codebase exploration based on what the thread discusses.
     - **Write or modify code** — use the thread context to inform implementation.
     - **Summarize** — provide a structured summary in chat.
     - **Reply** — draft a response for the user to send (do NOT send automatically).

4. **Compose with other skills.**
   - When delegating to another skill, pass the thread context as input — do not make the other skill re-fetch it.
   - Respect the invoked skill's workflow (plan mode, prompts, etc.).
   - If multiple skills are relevant, ask the user which to use.

### Key Principles

- **Read the full thread.** A single message without thread context is often insufficient. Always fetch the complete thread.
- **Never send messages.** This skill reads and processes — it does NOT send replies or reactions unless the user explicitly asks to draft one, and even then, present the draft for approval.
- **Compose, don't duplicate.** When another skill handles the action better, invoke it with the gathered context rather than reimplementing its workflow.
- **Slack context is ephemeral.** Summarize key information in chat so the user has it even if the thread evolves later.
