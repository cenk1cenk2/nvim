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

| Tool                        | Purpose                                           |
| --------------------------- | ------------------------------------------------- |
| `slack_get_channel_history` | Fetch recent messages from a channel.             |
| `slack_get_thread_replies`  | Fetch all replies in a message thread.            |
| `slack_list_channels`       | Resolve channel name to ID.                       |
| `slack_get_users`           | List workspace users (resolve user IDs to names). |
| `slack_get_user_profile`    | Get detailed profile for a specific user ID.      |
| `slack_reply_to_thread`     | Reply to a specific thread.                       |
| `slack_add_reaction`        | Add an emoji reaction to a message.               |

### Process

1. **Resolve the channel.**
   - If the user provides a channel name, use `slack_list_channels` to resolve it to a channel ID.
   - If the user provides a channel ID, use it directly.

2. **Determine the timeframe.**
   - If the user specifies a timeframe (e.g., "last 2 hours", "since yesterday"), use it.
   - If you have previously processed this channel (check your earlier messages in the conversation for timestamps), offer to start from where you left off.
   - Otherwise, ask the user how far back to look.

3. **Fetch and filter messages.**
   - Use `slack_get_channel_history` with a generous `limit` to fetch messages.
   - The result may be large and saved to a tool-results file. When this happens, use `jq` via Bash to extract and filter:

     ```bash
     # Extract timestamps to identify date range
     cat <result-file> | jq -r '.[0].text' | jq '[.messages[] | {ts, date: (.ts | split(".")[0] | tonumber | strftime("%Y-%m-%d %H:%M:%S"))}]'

     # Filter to today's messages (replace EPOCH with start-of-day unix timestamp)
     cat <result-file> | jq -r '.[0].text' | jq '[.messages[] | select((.ts | split(".")[0] | tonumber) >= EPOCH)]'

     # Extract message content for analysis
     cat <result-file> | jq -r '.[0].text' | jq '[.messages[] | select((.ts | split(".")[0] | tonumber) >= EPOCH)] | .[] | {ts, text, user, bot_id, attachments}'
     ```

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
   - For each message, extract the project, environment, and commit references.
   - **Always use GitLab MCP tools to verify actual status:**
     - Use `mcp__mcphub__gitlab__list_pipelines` to get recent pipeline status.
     - For pipelines in "manual" status, use `mcp__mcphub__gitlab__get_pipeline` and `mcp__mcphub__gitlab__list_pipeline_jobs` to check if deploy job is waiting.
     - For pipelines showing "failed" or "canceled", use `mcp__mcphub__gitlab__get_pipeline_job_output` to check logs for infrastructure variations.
   - **Categorize findings:**
     - **No action needed:** Pulumi/Terraform plan shows no infrastructure changes (e.g., "153 resources unchanged").
     - **Needs attention:** Failed pipelines, actual infrastructure changes detected, or manual deploys with real changes pending.
   - Summarize: what was deployed, actual status from GitLab MCP tools, and specific action items.

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

5. **Respond back to Slack.**

   The response method depends on whether you processed a single message or a batch:

   **Single message** → reply in thread:
   - Use `slack_reply_to_thread` on the message you processed.
   - Add `:dark_sunglasses:` reaction to that message.

   **Batch of messages** → post channel-level summary:
   - Use `slack_post_message` to post a summary to the channel.
   - Add `:dark_sunglasses:` reaction to **each message that was included in the summary**.
   - Group findings by channel type logic above.
   - Lead with actionable items (failures, pending deployments, unresolved feedback).
   - Follow with informational items (successful deploys, merged MRs, passed pipelines).

   **`:dark_sunglasses:` means "processed"** — only react to messages you actually wrote a response for (thread reply or included in a summary). Never react to messages you merely read but didn't act on.
   - For `echo` channel, present items one by one in chat and prompt for action on each (do NOT post to Slack automatically for echo).
   - The Slack summary also serves as a record that can be used to create Linear issues later.
   - Unless the user explicitly asks for chat-only output, always write back to Slack.

### Composing with Other Skills

- **`/linear-kilic`** — for creating or updating Linear issues from channel content.
- **`/obsidian-note`** — for creating Obsidian notes from thoughts or discussions.
- **`/slack-message`** — if the user wants to deep-dive into a specific message thread.
- When delegating, pass the gathered context — do not make the other skill re-fetch it.

### Key Principles

- **Single message → thread reply. Batch → channel post.** Use `slack_reply_to_thread` when processing one message. Use `slack_post_message` when summarizing multiple messages.
- **`:dark_sunglasses:` = processed.** Only react to messages you actually responded to (thread reply or included in summary). Never react to messages you merely read.
- **Always write back to Slack.** Default behavior is to respond in Slack, not just in chat. The posted content doubles as a record for creating Linear issues.
- **Never send ad-hoc replies without approval.** Summaries and reactions are automatic. Other thread replies require explicit user confirmation.
- **Enrich with source tools.** Don't just summarize Slack text — use GitLab/Linear MCP tools to provide real context (diffs, MR details, issue state).
- **Prompt for `echo`.** The echo channel is personal — always ask before creating issues or notes.
- **Track your position.** Note the timestamp of the last message you processed so you can offer to resume from there next time.
- **Slack context is ephemeral.** Summarize key information in chat so the user has it even if messages evolve.
