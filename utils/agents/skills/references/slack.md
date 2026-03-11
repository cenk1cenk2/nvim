# Slack MCP Tools and Conventions

## Available Tools

| Tool | Purpose |
|------|---------|
| `slack__slack_list_channels` | Resolve channel name to ID. |
| `slack__slack_get_channel_history` | Fetch recent messages from a channel. |
| `slack__slack_get_thread_replies` | Fetch all replies in a message thread. |
| `slack__slack_get_users` | List workspace users (resolve user IDs to names). |
| `slack__slack_get_user_profile` | Get detailed profile for a specific user ID. |
| `slack__slack_post_message` | Post a new message to a channel. |
| `slack__slack_reply_to_thread` | Reply to a specific thread. |
| `slack__slack_add_reaction` | Add an emoji reaction to a message. |

## Message Formatting (mrkdwn)

Slack does NOT render standard markdown. It uses its own format called **mrkdwn**. All messages sent via `slack__slack_post_message` and `slack__slack_reply_to_thread` MUST use Slack mrkdwn syntax.

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

- **Single message** → use `slack__slack_reply_to_thread` to reply in the thread.
- **Batch of messages** → use `slack__slack_post_message` to post a channel-level summary.
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
- **Resolve user IDs to names.** Always use `slack__slack_get_users` or `slack__slack_get_user_profile` before presenting summaries — show real names, not IDs.
- **Track your position.** Note the timestamp of the last message you processed so you can offer to resume from there next time.
