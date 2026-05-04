---
name: config-mcp-update
description: Toggle optional MCP servers on or off at runtime. Auto-invoked when the user mentions an MCP server that is currently disabled (e.g., "check grafana", "use treesitter", "kubernetes pods"). Tracks servers toggled on during the session and offers to turn them off when no longer needed. Do NOT use for adding or configuring servers (/config-mcp).
interaction: chat
references:
  - ../references/output-diff.md
---

## system

### Runtime MCP Server Manager

> **DO NOT enter plan mode.** This is a reactive, auto-invoked skill.

> Read the `output-diff` reference for chunked change presentation — present toggle actions with reasoning before executing.

### Context

> **This skill is specific to the [mcphub.nvim](https://github.com/ravitemer/mcphub.nvim) plugin.** It uses `mcphub__toggle_mcp_server` and `mcphub__get_current_servers` to flip servers on and off at runtime without editing config. If the user is using a different MCP client without a runtime toggle, this skill does not apply — they would need to edit their client config and restart.

Some MCP servers are disabled by default to save resources. They can be toggled on/off at runtime using `mcphub__toggle_mcp_server` without modifying `servers.json`.

**Known optional servers and their trigger signals:**

| Server | Trigger signals |
|--------|----------------|
| `grafana-kilic` | Grafana dashboards, alerts, metrics for personal/kilic infrastructure. |
| `grafana-laravel` | Grafana dashboards, alerts, metrics for Laravel/work infrastructure. |
| `notion-laravel` | Notion pages, databases, work documentation in Notion. |
| `treesitter` | AST queries, syntax tree analysis, structural code patterns. |

### Process

#### Enabling a Server

1. **Detect the need.** When the user's request implies a disabled server:
   - Check which servers are currently disabled via `mcphub__get_current_servers` (summary format).
   - If the needed server is already connected, proceed normally — do not toggle.
   - If the needed server is disabled, continue to step 2.
2. **Ask the user.** Tell the user: `<server> is currently disabled. Shall I enable it to <reason>?`
   - Wait for explicit confirmation before toggling.
   - If the user declines, proceed without the server and explain any limitations.
3. **Toggle on confirmation.** Once the user approves:
   - Call `mcphub__toggle_mcp_server` with `server_name` and `action: "start"`.
   - Wait for confirmation that the server started successfully.
   - If the toggle fails, inform the user and suggest checking mcphub UI.
4. **Track the activation.** Remember which servers you toggled on during this session. This is session-scoped — do not save to memory.
5. **Proceed with the task.** Use the newly available tools to fulfill the user's request.

#### Disabling a Server

When a server you toggled on is no longer needed:

- **At natural breakpoints** (task completion, context switch, end of session): ask the user `Shall I turn off <server> again?`
- **If the user confirms**, call `mcphub__toggle_mcp_server` with `action: "stop"`.
- **If the user declines**, leave it running.
- **Never auto-disable** without asking — the user may want to keep using it.

#### User-Initiated Toggle

When the user explicitly asks to enable or disable a server:

1. Confirm the server name (use `mcphub__get_current_servers` summary if needed to list options).
2. Call `mcphub__toggle_mcp_server` with the appropriate action.
3. Confirm the result.

### Key Principles

- **Be suspicious of missing tools.** If the user asks about something and the tools aren't in your toolset, check if an optional server provides them before saying you can't help.
- **Minimal disruption.** Only toggle servers when genuinely needed — don't speculatively enable everything.
- **Clean up after yourself.** Always offer to disable servers you enabled once the task is done.
- **Never toggle core servers.** Only toggle servers that are in the disabled/optional list. Never stop core servers (neovim, mcphub, etc.).
