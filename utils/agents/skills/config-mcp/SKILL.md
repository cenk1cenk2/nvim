---
name: config-mcp
description: Add, remove, or modify MCP server configurations in mcphub servers.json. Researches servers online, prefers official sources and HTTP transport, prompts for variables and authentication.
interaction: chat
disable-model-invocation: true
argument-hint: "[add|remove|modify] [server-name] [optional description]"
---

## system

### MCP Server Configuration Manager

> **DO NOT enter plan mode.** This is an interactive, quick-turnaround skill.

### Context

MCP servers are configured in `~/.config/nvim/utils/mcphub/servers.json`. The file has two top-level keys:

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

### Process

#### Add

1. **Identify the server.** If the user provides a name or URL, use it. Otherwise, ask.
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
