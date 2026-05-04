---
name: config-mcp
description: Add, remove, or modify MCP server configurations in mcphub servers.json. Researches servers online, prefers official sources and HTTP transport, prompts for variables and authentication. Always manually invoked. Do NOT use for skills (/config-skills) or agent guidelines (/config-agents).
interaction: chat
disable-model-invocation: true
references:
  - ../references/output-diff.md
argument-hint: "[add|remove|modify] [server-name] [optional description]"
---

## system

### MCP Server Configuration Manager

> **DO NOT enter plan mode.** This is an interactive, quick-turnaround skill.

> Read the `output-diff` reference for chunked change presentation — show reasoning + content blocks for each configuration change before applying.

### Context

> **This skill is specific to the [mcphub.nvim](https://github.com/ravitemer/mcphub.nvim) plugin.** It edits the mcphub `servers.json` file. If the user is using a different MCP client config (e.g., Claude Code's `~/.claude.json`, OpenCode's `opencode.json`), adjust the file path and JSON shape to that client's schema instead.

MCP servers are configured in `~/.config/nvim/utils/mcphub/servers.json` (mcphub's config file). The file has two top-level keys:

- `mcpServers` — external MCP servers (stdio or HTTP).
- `nativeMCPServers` — built-in mcphub servers (do not modify unless explicitly asked).

Each server entry follows one of two transport patterns:

**HTTP (preferred):**

```json
{
  "url": "https://example.com/mcp",
  "headers": {
    "Authorization": "Bearer ${ENV_VAR}"
  },
  "autoApprove": [],
  "disabled_tools": []
}
```

**Stdio:**

```json
{
  "command": "bunx",
  "args": ["-y", "package-name@latest"],
  "env": {
    "API_KEY": "${ENV_VAR}"
  },
  "autoApprove": [],
  "disabled_tools": []
}
```

**Environment variables** use `${VAR_NAME}` syntax and are resolved at runtime. Secrets MUST use env var references, never hardcoded values. The convention for env var names is `NVIM_<SERVICE>` (e.g., `NVIM_GITHUB`, `NVIM_GITLAB`).

> **Cross-client env-var-syntax compatibility (no single common syntax exists):**
>
> | Client | `${VAR}` | `${env:VAR}` | `{env:VAR}` |
> |---|---|---|---|
> | mcphub.nvim | yes | yes (VS Code-style) | no |
> | Claude Code (`.mcp.json`) | yes | no | no |
> | OpenCode (`opencode.json`) | partial (headers only) | no | yes |
>
> This config uses **`${VAR}`** because it works in mcphub + Claude Code (the two clients used here). If the user wants to consume this config from OpenCode, run a one-shot conversion: `sed 's/${\([A-Z_][A-Z0-9_]*\)}/{env:\1}/g' servers.json`. Do NOT mix syntaxes inside a single file. Sources: <https://code.claude.com/docs/en/mcp>, <https://opencode.ai/docs/config/>, <https://ravitemer.github.io/mcphub.nvim/mcp/servers_json.html>.

### Server Naming

**Server keys MUST use kebab-case with `-` only.** Do NOT use `/` (does not parse correctly through some MCP hubs — gets flattened inconsistently in the tool prefix) and avoid `_` for word separation inside keys. For multi-workspace services, follow the `<service>-<workspace>` convention:

- `linear-kilic-dev`, `linear-laravel`
- `grafana-kilic`, `grafana-laravel`
- `argocd-kilic`, `slack-kilic`, `spacelift-laravel`

A clean kebab-case server key produces a clean, addressable tool prefix downstream regardless of whether tools are routed through a hub.

### How `disabled_tools` Behaves Downstream

`disabled_tools` is a property of the server entry, not of the downstream agent. When the MCP layer (mcphub, or another hub/proxy) honors it, disabled tools are **filtered at the source** — they never appear in the tool list exposed to the downstream agent. This means:

- **Claude Code** (using mcphub or another MCP layer that filters): never sees a tool listed in `disabled_tools`. There is nothing additional to configure on the Claude Code side. (For agent-side denial — e.g., a tool that the MCP layer exposes but the user wants Claude Code to refuse — Claude Code's `permissions.deny` in `~/.claude/settings.json` accepts `mcp__<server>__<tool>` and `mcp__<server>__*` patterns. Priority is `deny > ask > allow`. Source: <https://code.claude.com/docs/en/permissions>.)
- **OpenCode** (using mcphub or another filtering layer): receives the filtered tool list from the MCP layer. OpenCode's own `permission` field in `opencode.json` has a documented bug where MCP-tool permissions sometimes do not apply after the legacy `tools` config was merged into `permissions` — relying on the upstream `disabled_tools` is the more reliable layer. Source: <https://opencode.ai/docs/config/>.
- **Direct client integration without a hub:** if the user wires the MCP server directly into Claude Code or OpenCode without going through a filtering hub, `disabled_tools` in the hub config has no effect — denial must be done at the client layer (`permissions.deny` or equivalent).

**Conclusion:** when going through a hub, `disabled_tools` is the single source of truth for both downstream agents. When going direct, the client's own deny mechanism must mirror what would have been disabled.

### Special Tool Categories

- **Tmux MCP write tools.** `execute-command`, `create-window`, `split-pane`, `kill-window`, `kill-session`, `kill-pane`, `create-session` are disabled by policy — these grant the agent the ability to mutate the user's terminal layout and run arbitrary commands invisibly. Command execution belongs in the agent's built-in `Bash` tool, where it is visible and permission-prompted. When adding or modifying the tmux entry, keep these in `disabled_tools`.
- **Removed servers.** The `git` MCP and `kubernetes` MCP have been removed from this config. Use `git` CLI and `kubectl` CLI via `Bash` for those operations. If a user asks to re-add either, raise the trade-off (extra surface area; commands are already accessible via Bash) before doing so.

### Process

#### Add

1. **Identify the server.** If the user provides a name or URL, use it. Otherwise, ask. Pick a kebab-case server key (no `/`, prefer `-` over `_` inside the key) — see "Server Naming" above.
2. **Research the server.**
   - Search the web for the official MCP server (prefer servers published by the service provider themselves, e.g., `mcp.linear.app`, `api.githubcopilot.com/mcp`).
   - Check the official MCP server registry and the service's own documentation.
   - Determine available transports (HTTP/SSE vs stdio).
   - Identify required environment variables, authentication methods, and configuration options.
3. **Choose transport.**
   - **HTTP is preferred** when the server offers a remote HTTP/SSE endpoint.
   - Only use stdio (command + args) when no HTTP endpoint exists.
   - If both are available, present the choice but recommend HTTP.
4. **Prompt for authentication.**
   - If the server supports multiple auth methods (token, OAuth, API key), present the options and let the user choose.
   - For token auth: ask for the env var name to use (suggest `NVIM_<SERVICE>` convention).
   - For OAuth: mcphub handles OAuth automatically via PKCE flow with `.well-known/oauth-authorization-server` discovery. No `client_id`, `client_secret`, or env vars are needed in `servers.json` — just the `url`. Tokens are stored in `~/.mcp-hub/oauth-storage.json` with automatic refresh. Inform the user they will need to press `l` on the server in mcphub UI to trigger the browser-based authorization on first use.
   - If no auth is needed, skip this step.
5. **Prompt for variables.**
   - List all required and optional environment variables.
   - For each required variable, ask the user for the env var name (not the value — values are set outside this config).
   - For optional variables, explain what they do and ask if the user wants to set them.
6. **Prompt for tool approvals and disabled tools.**
   - Research available tools the server exposes.
   - Present the full tool list to the user, categorized as read-only vs write/destructive.
   - **Always ask the user explicitly** which tools to `autoApprove` (if any) and which to `disabled_tools` (if any).
   - Suggest read-only / safe tools as candidates for `autoApprove`.
   - Suggest write / destructive tools as candidates for `disabled_tools`.
   - Do not assume defaults — the user decides both lists.
7. **Present the configuration.**
   - Show the complete JSON entry in chat.
   - Explain each field briefly.
   - Wait for user approval.
8. **Apply the configuration.**
   - Read `servers.json`, add the new entry under `mcpServers`, and write the file.
   - Validate that the resulting JSON is well-formed.

#### Remove

1. Read `servers.json` and list available servers if no specific server is named.
2. Confirm with the user which server to remove.
3. Remove the entry and write the file.

#### Modify

1. Read `servers.json` and show the current configuration for the target server.
2. Ask the user what they want to change (or apply the change they described).
3. If the change involves new variables or auth, follow the prompting steps from the Add flow.
4. If the user asks to change `autoApprove` or `disabled_tools`, prompt for those specifically. Otherwise, do not re-prompt for tool approvals unless relevant to the modification.
5. Present the updated entry and wait for approval.
6. Apply and write the file.

### Key Principles

- **Never hardcode secrets.** Always use `${ENV_VAR}` references.
- **Prefer official servers.** First-party MCP servers from service providers are more reliable and feature-complete.
- **Prefer HTTP transport.** Remote HTTP endpoints avoid local dependency management.
- **Prefer `bunx` for stdio.** When stdio is needed, use `bunx -y package@latest` as the command pattern (matching existing entries). Fall back to `npx -y` or `uvx` based on the package ecosystem.
- **Validate JSON.** Always ensure `servers.json` remains valid after edits.
- **Preserve existing structure.** Do not reformat or reorder unrelated entries when adding/modifying a server.
- **Ask, don't assume.** When multiple options exist (auth method, transport, tool approvals), present them to the user.
