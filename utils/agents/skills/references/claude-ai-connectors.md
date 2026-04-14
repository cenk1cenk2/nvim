# claude.ai Connector Tools

Claude.ai connectors provide MCP tools for services authorized through claude.ai (e.g., Slack, Notion, Linear). These tools are **deferred** — their schemas are not loaded at startup and must be fetched before use.

## Loading Tools

Use `ToolSearch` with `select:` prefix to load specific tools by name:

```
ToolSearch({ query: "select:notion-search,notion-fetch,notion-update-page" })
```

Load only the tools needed for the current task. Each `ToolSearch` call can load multiple tools at once using comma-separated names.

## Available Connectors

| Connector | Tool prefix | Example tools |
|-----------|-------------|---------------|
| Slack | `slack_*` | `slack_send_message`, `slack_read_channel`, `slack_search_public` |
| Notion | `notion-*` | `notion-search`, `notion-fetch`, `notion-update-page` |
| Linear | `Linear__*` | `Linear__get_issue`, `Linear__save_issue` |

## Availability

- **Direct Claude Code CLI sessions:** Available when logged in with OAuth and the connector is authorized on claude.ai/settings/connectors.
- **mcphub/ACP sessions (Neovim):** NOT available. ACP sessions only have access to MCP servers passed via the `mcpServers` session parameter. claude.ai connectors do not sync to ACP.

## Key Rules

- **Always load before use.** Calling a deferred tool without loading it first will fail with `InputValidationError`.
- **Load per task.** Load only what you need — do not bulk-load all tools from a connector.
- **No reactions for Slack.** The claude.ai Slack connector does not have `slack_add_reaction`.
- **Tool names vary.** claude.ai connector tool names differ from mcphub equivalents (e.g., `notion-fetch` vs `notion_laravel__notion-fetch`, `slack_read_channel` vs `slack_kilic__slack_get_channel_history`).
