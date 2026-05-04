# claude.ai Connector Tools

Claude.ai connectors provide MCP tools for services authorized through claude.ai (e.g., Slack, Notion, Linear, Plain). These tools are **deferred** — their schemas are not loaded at startup and must be fetched before use.

## Tool Naming

All claude.ai connector tools follow the pattern: `mcp__claude_ai_<Connector>__<tool_name>`.

| Connector | Full prefix | Example |
|-----------|-------------|---------|
| Slack | `mcp__claude_ai_Slack__` | `mcp__claude_ai_Slack__slack_send_message` |
| Notion | `mcp__claude_ai_Notion__` | `mcp__claude_ai_Notion__notion-search` |
| Linear | `mcp__claude_ai_Linear__` | `mcp__claude_ai_Linear__get_issue` |
| Plain | `mcp__claude_ai_Plain__` | `mcp__claude_ai_Plain__getThreads` |
| Granola | `mcp__claude_ai_Granola__` | `mcp__claude_ai_Granola__list_meetings` |

## Loading Tools

Use `ToolSearch` to load deferred tools before calling them. Use keyword search to find tools by connector name:

```
ToolSearch({ query: "+Slack send message" })
ToolSearch({ query: "+Notion search" })
```

Or load specific tools by exact name with `select:`:

```
ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message,mcp__claude_ai_Slack__slack_read_channel" })
```

Load only the tools needed for the current task. Each `ToolSearch` call can load multiple tools at once.

## Available Connectors

### Slack (`mcp__claude_ai_Slack__`)

| Tool | Purpose |
|------|---------|
| `slack_search_public` | Search messages in public channels. |
| `slack_search_public_and_private` | Search messages across public and private channels. |
| `slack_search_channels` | Search for channels by name or topic. |
| `slack_search_users` | Search for users by name or email. |
| `slack_read_channel` | Read recent messages from a channel. |
| `slack_read_thread` | Read all replies in a message thread. |
| `slack_read_user_profile` | Get detailed profile for a specific user. |
| `slack_send_message` | Send a message to a channel or thread. |
| `slack_send_message_draft` | Draft and format a message before sending. |
| `slack_schedule_message` | Schedule a message for later delivery. |
| `slack_create_canvas` | Create a new Slack canvas document. |
| `slack_read_canvas` | Read an existing canvas. |
| `slack_update_canvas` | Update an existing canvas. |

### Notion (`mcp__claude_ai_Notion__`)

| Tool | Purpose |
|------|---------|
| `notion-search` | Find pages by query. |
| `notion-fetch` | Retrieve page content by URL or ID. |
| `notion-update-page` | Modify page properties and content. |
| `notion-create-pages` | Create new pages. |
| `notion-create-comment` | Add comments to pages. |
| `notion-get-comments` | Read comments on a page. |
| `notion-get-users` | List workspace users. |
| `notion-get-teams` | List workspace teams. |
| `notion-create-database` | Create a new database. |
| `notion-create-view` | Create a database view. |
| `notion-update-view` | Update a database view. |
| `notion-update-data-source` | Update a data source. |
| `notion-duplicate-page` | Duplicate an existing page. |
| `notion-move-pages` | Move pages to a different parent. |

## Availability

- **Direct Claude Code CLI sessions:** Available when logged in with OAuth and the connector is authorized on claude.ai/settings/connectors.
- **Sessions routed through an MCP hub (mcphub/ACP):** NOT available. Hub-routed sessions only have access to MCP servers passed via the `mcpServers` session parameter. claude.ai connectors do not sync through.

## Key Rules

- **Always load before use.** Calling a deferred tool without loading it first will fail with `InputValidationError`.
- **Load per task.** Load only what you need — do not bulk-load all tools from a connector.
- **No reactions for Slack.** The claude.ai Slack connector does not have `slack_add_reaction`.
- **Tool names vary.** claude.ai connector tool names differ from server-direct equivalents (e.g., `mcp__claude_ai_Notion__notion-fetch` vs `notion-laravel__notion-fetch`, `mcp__claude_ai_Slack__slack_read_channel` vs `slack-kilic__slack_get_channel_history`).
