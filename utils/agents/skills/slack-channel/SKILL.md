---
name: slack-channel
description: Process a Slack channel — reads recent messages, analyzes automated and human messages, and acts per channel type. Use when the user wants to catch up on a Slack channel's activity.
interaction: chat
disable-model-invocation: true
argument-hint: "[channel-name-or-id] [optional: timeframe or instructions]"
---

## system

### Slack Channel Processor

> **DO NOT enter plan mode.** This skill reads channel history, classifies messages, and acts on them directly or by composing with other skills.

### Context

The user wants to catch up on a Slack channel. This skill reads the channel's recent messages, classifies them by type, and takes appropriate action depending on the channel's purpose. The skill supports both automated channels (CI/CD, deployments, publishes) and human channels (issues, echo/thoughts).

### Available Slack Tools

| Tool | Purpose |
|------|---------|
| `slack_get_channel_history` | Fetch recent messages from a channel. |
| `slack_get_thread_replies` | Fetch all replies in a message thread. |
| `slack_list_channels` | Resolve channel name to ID. |
| `slack_get_users` | List workspace users (resolve user IDs to names). |
| `slack_get_user_profile` | Get detailed profile for a specific user ID. |
| `slack_reply_to_thread` | Reply to a specific thread. |
| `slack_add_reaction` | Add an emoji reaction to a message. |

### Process

1. **Resolve the channel.**
   - If the user provides a channel name, use `slack_list_channels` to resolve it to a channel ID.
   - If the user provides a channel ID, use it directly.

2. **Determine the timeframe.**
   - If the user specifies a timeframe (e.g., "last 2 hours", "since yesterday"), use it.
   - If you have previously processed this channel (check your earlier messages in the conversation for timestamps), offer to start from where you left off.
   - Otherwise, ask the user how far back to look.

3. **Fetch messages.**
   - Use `slack_get_channel_history` to fetch messages within the timeframe.
   - For any message with thread replies, use `slack_get_thread_replies` to read the full thread.
   - Resolve user IDs to real names using `slack_get_users` or `slack_get_user_profile`.

4. **Classify and act per channel type.**

   Route processing based on the channel name or content pattern:

   #### `gitlab-publish` — Code Changes
   - Messages are automated notifications about merged MRs, tags, or releases.
   - For each message, extract the project and MR/commit references.
   - Use GitLab MCP tools to enrich:
     - `mcp__mcphub__gitlab__get_merge_request` — fetch MR details (title, description, author).
     - `mcp__mcphub__gitlab__get_merge_request_diffs` — fetch the actual changes.
     - `mcp__mcphub__gitlab__get_commit` / `get_commit_diff` — for commit-level detail.
     - `mcp__mcphub__gitlab__list_commits` — for tag/release commit ranges.
   - Summarize: what changed, who authored it, why (from MR description), and impact.

   #### `gitlab-pipelines` — CI/CD Status
   - Messages are automated pipeline status notifications.
   - For each message, extract the project and pipeline/MR references.
   - Use GitLab MCP tools to enrich:
     - `mcp__mcphub__gitlab__get_merge_request` — what triggered the pipeline.
     - `mcp__mcphub__gitlab__list_commits` — recent commits in the branch.
     - `mcp__mcphub__gitlab__get_commit` — specific commit details.
   - Summarize: which pipelines passed/failed, what projects are affected, and any failures that need attention.
   - **Highlight failures prominently** — these are actionable.

   #### `gitlab-deployments` — Deployment Status
   - Messages are automated deployment notifications.
   - For each message, extract the project, environment, and version references.
   - Use GitLab MCP tools to enrich:
     - `mcp__mcphub__gitlab__get_merge_request` / `list_merge_requests` — pending MRs not yet deployed.
     - `mcp__mcphub__gitlab__get_branch_diffs` — diff between deployed version and latest.
     - `mcp__mcphub__gitlab__list_commits` — commits since last deployment.
   - Summarize: what was deployed, where, and whether there are pending changes.
   - **Warn the user** if there are undeployed changes that may need attention.

   #### `issues` — Linear Issue Discussions
   - Messages reference Linear issues or contain issue discussions.
   - For each message thread, read the full thread via `slack_get_thread_replies`.
   - If the thread references a Linear issue, fetch it via `mcp__mcphub__linear_kilic-dev__get_issue`.
   - If the thread contains user comments with feedback or refinements:
     - Use `mcp__mcphub__linear_kilic-dev__list_comments` to see existing Linear comments.
     - Compose with the `/linear-kilic` skill to update the issue based on thread discussion.
   - Summarize: which issues were discussed, what feedback was given, what actions are needed.

   #### `echo` — Personal Thoughts & Ideas
   - Messages are the user's own thoughts, ideas, links, or quick notes.
   - For each message, read the full thread if it has replies.
   - **Always prompt the user** for what to do with each item. Common actions:
     - **Create a Linear issue** — compose with `/linear-kilic` skill, passing the thought as context.
     - **Create an Obsidian note** — compose with `/obsidian-note` skill, passing the content.
     - **Just acknowledge** — summarize and move on.
   - Do NOT auto-create issues or notes — always ask first.

   #### Unknown/Other Channels
   - Provide a general summary of messages grouped by topic or thread.
   - Ask the user how they'd like to handle the content.

5. **Present the summary.**
   - Group findings by channel type logic above.
   - Lead with actionable items (failures, pending deployments, unresolved feedback).
   - Follow with informational items (successful deploys, merged MRs, passed pipelines).
   - For `echo` channel, present items one by one and prompt for action on each.

6. **React to processed messages.**
   - Add `:dark_sunglasses:` reaction via `slack_add_reaction` to each message you have processed, so you and the user can track what's been covered.

### Composing with Other Skills

- **`/linear-kilic`** — for creating or updating Linear issues from channel content.
- **`/obsidian-note`** — for creating Obsidian notes from thoughts or discussions.
- **`/slack-message`** — if the user wants to deep-dive into a specific message thread.
- When delegating, pass the gathered context — do not make the other skill re-fetch it.

### Key Principles

- **Always reply in threads.** If you need to respond in Slack, use `slack_reply_to_thread`. Never post channel-level messages unless the user explicitly asks.
- **Signal processing.** React with `:dark_sunglasses:` on each message you process.
- **Never send messages without approval.** Reactions (`:dark_sunglasses:`) are automatic. All other Slack actions (replies, posts) require explicit user confirmation.
- **Enrich with source tools.** Don't just summarize Slack text — use GitLab/Linear MCP tools to provide real context (diffs, MR details, issue state).
- **Prompt for `echo`.** The echo channel is personal — always ask before creating issues or notes.
- **Track your position.** Note the timestamp of the last message you processed so you can offer to resume from there next time.
- **Slack context is ephemeral.** Summarize key information in chat so the user has it even if messages evolve.
