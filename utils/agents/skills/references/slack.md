# Slack MCP Tools and Conventions

## ⛔ ABSOLUTE: the workspace decides the integration

**Each Slack workspace has exactly one route.** The kilic workspace is reachable only through the `slack-kilic` server; the Laravel workspace is reachable only through the claude.ai connector (`mcp__claude_ai_Slack__*`). Routing a workspace through the other integration reads or posts into the wrong workspace. See the `harness-connectors` reference for the precedence rule this mapping carves out of, and for loading deferred connector tools.

## Workspace Routing

| Action | kilic (`slack-kilic`) | Laravel (`mcp__claude_ai_Slack__*`, deferred) |
|--------|-----------------------|-----------------------------------------------|
| Find a channel | `slack-kilic__slack_list_channels` | `mcp__claude_ai_Slack__slack_search_channels` |
| Read a channel | `slack-kilic__slack_get_channel_history` | `mcp__claude_ai_Slack__slack_read_channel` |
| Read a thread | `slack-kilic__slack_get_thread_replies` | `mcp__claude_ai_Slack__slack_read_thread` |
| Find users | `slack-kilic__slack_get_users` | `mcp__claude_ai_Slack__slack_search_users` |
| Read a profile | `slack-kilic__slack_get_user_profile` | `mcp__claude_ai_Slack__slack_read_user_profile` |
| Post to a channel | `slack-kilic__slack_post_message` | `mcp__claude_ai_Slack__slack_send_message` |
| Reply in a thread | `slack-kilic__slack_reply_to_thread` | `mcp__claude_ai_Slack__slack_send_message` (with the thread) |
| React | `slack-kilic__slack_add_reaction` | `mcp__claude_ai_Slack__slack_add_reaction` |
| Search messages | — (no equivalent) | `mcp__claude_ai_Slack__slack_search_public` / `slack_search_public_and_private` |

The connector tools are deferred — load them via `ToolSearch` before the first call. Workspace-scoped skills decide *which* workspace and *which* channel; this table decides the tools.

## Message Formatting

**Which format to write depends on the integration you are sending through:**

- **Connector** (`mcp__claude_ai_Slack__slack_send_message`) — takes **standard markdown** (`**bold**`, `_italic_`, fenced blocks with a language hint, `[label](url)`) and converts it. Writing mrkdwn here renders literally.
- **`slack-kilic`** (`slack-kilic__slack_post_message` / `slack-kilic__slack_reply_to_thread`) — takes **mrkdwn**, per the table below.

Mentions (`<@U123>`), channel links (`<#C123>`), and emoji shortcodes are the same in both. When unsure, keep the message plain — short lines, hyphen lists, raw URLs — which renders correctly either way.

### mrkdwn (`slack-kilic`)

Slack does NOT render standard markdown. It uses its own format called **mrkdwn**. All messages sent via `slack-kilic__slack_post_message` and `slack-kilic__slack_reply_to_thread` MUST use Slack mrkdwn syntax.

| Intent | Markdown (WRONG) | Slack mrkdwn (CORRECT) |
|--------|-------------------|------------------------|
| Bold | `**text**` | `*text*` |
| Italic | `*text*` | `_text_` |
| Strikethrough | `~~text~~` | `~text~` |
| Inline code | `` `code` `` | `` `code` `` |
| Code block | ```` ```lang\ncode\n``` ```` | ```` ```\ncode\n``` ```` (no language hint) |
| Link | `[label](url)` | `<url\|label>` |
| Heading | `# Heading` | `*Heading*` (bold, no heading syntax) |
| Bulleted list | `- item` | `• item` or `- item` |
| Numbered list | `1. item` | `1. item` |
| Blockquote | `> text` | `> text` |
| User mention | n/a | `<@U12345>` |
| Channel link | n/a | `<#C12345>` |

**Rules:**
- Never use `**` for bold — Slack renders it literally as asterisks.
- Never use `*` for italic — Slack renders it as bold.
- Never put a language identifier after ` ``` ` — Slack ignores it and may render it as text.
- Links must use `<url|label>` pipe syntax, not `[label](url)`.
- Headings don't exist — use `*bold text*` on its own line as a section header.
- Nested lists are not supported — flatten them.

## Response Conventions

### Thread vs Channel

- **Single message** → reply in the thread ("Reply in a thread" above).
- **Batch of messages** → post a channel-level summary ("Post to a channel" above).
- Default to thread replies. Only use channel-level messages when there is no existing thread or the user explicitly asks.

### `:dark_sunglasses:` Reaction

`:dark_sunglasses:` means **"processed"** — only react to messages you actually wrote a response for (thread reply or included in a summary). Never react to messages you merely read but didn't act on.

### Approval Rules

- **Summaries and reactions** are automatic — post them without asking.
- **Other thread replies** require explicit user confirmation of the draft content before sending.
- Never send ad-hoc replies without approval.

### Large Results

Slack history responses may be large and saved to a tool-results file. When this happens, use `jq` via Bash to extract and filter:

```bash
# Extract timestamps to identify date range
cat <result-file> | jq -r '.[0].text' | jq '[.messages[] | {ts, date: (.ts | split(".")[0] | tonumber | strftime("%Y-%m-%d %H:%M:%S"))}]'

# Filter to today's messages (replace EPOCH with start-of-day unix timestamp)
cat <result-file> | jq -r '.[0].text' | jq '[.messages[] | select((.ts | split(".")[0] | tonumber) >= EPOCH)]'

# Extract message content for analysis
cat <result-file> | jq -r '.[0].text' | jq '[.messages[] | select((.ts | split(".")[0] | tonumber) >= EPOCH)] | .[] | {ts, text, user, bot_id, attachments}'
```

## General Principles

- **Slack context is ephemeral.** Summarize key information in chat so the user has it even if messages evolve.
- **Resolve user IDs to names.** Always run the workspace's user or profile lookup before presenting summaries — show real names, not IDs.
- **Track your position.** Note the timestamp of the last message you processed so you can offer to resume from there next time.
