---
name: config-mcp
description: 'config-mcp Add, remove, or modify MCP server entries in the hyprpilot MCP catalog; researches servers, prefers official/HTTP sources, prompts for vars and auth. Always manually invoked. Do NOT use for skills (config-skills), agent guidelines (config-agents), or repo configs (config-repository; edit ~/.config/hyprpilot/config.yaml directly for daemon settings).'
disableModelInvocation: true
references:
  - ../references/present-first.md
  - ../references/output-diff.md
  - ../references/redact-private-data.md
argumentHint: "[add|remove|modify] [server-name] [optional description]"
---

## MCP Server Configuration Manager

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `output-diff` reference for chunked change presentation — show reasoning + content blocks for each configuration change before applying.

> **No private specifics.** Read the `redact-private-data` reference — beyond the never-hardcode-secrets rule below, never write real private/sensitive specifics (account IDs, internal hostnames, tokens) into the config or its examples unless the user explicitly allows it; use `${ENV_VAR}` references and placeholders instead.

## Context

The captain runs **hyprpilot** as the agent host. Hyprpilot loads MCP servers via the `[[mcps]]` array in `~/.config/hyprpilot/config.yaml` — each entry either points at a catalog file (`{ file = "..." }`) or declares inline `mcp_servers = { ... }`. The active catalog file today is `~/.config/nvim/utils/mcphub/servers.json` (the path is historical — the file is now consumed by hyprpilot, not mcphub.nvim). Per-profile `mcps` arrays wholesale-replace the global default.

This skill edits the catalog file `~/.config/nvim/utils/mcphub/servers.json`. Its top-level key is `mcpServers` — the standard shape Claude Code / Codex / every MCP client uses. Each server entry follows one of two transport patterns:

**HTTP (preferred):**

```json
{
  "url": "https://example.com/mcp",
  "headers": {
    "Authorization": "Bearer ${ENV_VAR}"
  },
  "hyprpilot": {
    "autoAcceptTools": [],
    "autoRejectTools": []
  }
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
  "hyprpilot": {
    "autoAcceptTools": [],
    "autoRejectTools": []
  }
}
```

**Environment variables** use `${VAR_NAME}` syntax and are resolved at runtime. Secrets MUST use env var references, never hardcoded values. The convention for env var names is `NVIM_<SERVICE>` (e.g., `NVIM_GITHUB`, `NVIM_GITLAB`).

> **The catalog file is shared with other clients.** `~/.config/nvim/utils/mcphub/servers.json` is consumed by hyprpilot and may be referenced from other MCP clients too. `${VAR}` syntax works in hyprpilot, Claude Code, and Codex; for OpenCode (`{env:VAR}` style), keep a one-shot conversion at hand: `sed 's/${\([A-Z_][A-Z0-9_]*\)}/{env:\1}/g' servers.json`. Do NOT mix syntaxes inside a single file.

## Server Naming

**Server keys MUST use kebab-case with `-` only.** Do NOT use `/` (does not parse correctly through some MCP hubs — gets flattened inconsistently in the tool prefix) and avoid `_` for word separation inside keys. For multi-workspace services, follow the `<service>-<workspace>` convention:

- `linear-kilic`, `linear-laravel`
- `grafana-kilic`, `grafana-laravel`
- `argocd-kilic`, `slack-kilic`, `spacelift-laravel`

A clean kebab-case server key produces a clean, addressable tool prefix downstream (`mcp__<server>__<tool>`).

## Hyprpilot Permission Extension

The `hyprpilot` namespace key on each server entry is hyprpilot's typed extension over the standard `mcpServers` shape. It carries two glob arrays:

- `autoAcceptTools` — globs matching tool names that auto-resolve as "allow" through `PermissionController::decide` lane 2. Reject beats accept inside the lane.
- `autoRejectTools` — globs matching tool names that auto-resolve as "deny". Short-circuits before accept.

The globs are **server-relative** — write `read_*` / `delete_*`, not `mcp__<server>__read_*`. The `mcp__<server>__` prefix is implicit. Vendor-native tools (Bash, Read, …) skip this lane entirely.

## Special Tool Categories

- **Tmux MCP write tools.** `execute-command`, `create-window`, `split-pane`, `kill-window`, `kill-session`, `kill-pane`, `create-session` are disabled by policy — these grant the agent the ability to mutate the user's terminal layout and run arbitrary commands invisibly. Command execution belongs in the agent's built-in `Bash` tool, where it is visible and permission-prompted. Keep these in `autoRejectTools` (server-relative globs).
- **Removed servers.** The `git` MCP and `kubernetes` MCP have been removed from this config. Use `git` CLI and `kubectl` CLI via `Bash` for those operations. If a user asks to re-add either, raise the trade-off (extra surface area; commands are already accessible via Bash) before doing so.
- **In-tree hyprpilot server.** Do NOT add a `hyprpilot` entry here. Hyprpilot auto-injects its own MCP server (named `hyprpilot`) at session/new time when the resolved `[[mcp.skills]]` catalog is non-empty — see `~/.config/hyprpilot/config.yaml` `[mcp]` block. The auto-injected server exposes skills as `hyprpilot://skills/<slug>` resources + `mcp__hyprpilot__list_skills` / `read_skill` / `load_skill_references` / `reload` tools.

## Process

### Add

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
   - For token / API key auth: ask for the env var name (suggest `NVIM_<SERVICE>` convention) — the value lives outside this config.
   - For OAuth-only servers: warn the captain that hyprpilot does not own an OAuth flow today. Either skip the server, or provide the access token via a static `${VAR}` env / header reference the captain refreshes manually.
5. **Prompt for variables.**
   - List all required and optional environment variables.
   - For each required variable, ask the user for the env var name (not the value — values are set outside this config).
   - For optional variables, explain what they do and ask if the user wants to set them.
6. **Prompt for permission globs.**
   - Research available tools the server exposes.
   - Present the full tool list to the user, categorized as read-only vs write/destructive.
   - Ask explicitly which tool patterns belong in `hyprpilot.autoAcceptTools` (allow without prompting) and `hyprpilot.autoRejectTools` (deny outright). Reject beats accept.
   - Suggest read-only / safe tools as candidates for `autoAcceptTools`.
   - Suggest write / destructive tools as candidates for `autoRejectTools`.
   - Do not assume defaults — the captain decides both lists.
7. **Present the configuration.**
   - Show the complete JSON entry in chat.
   - Explain each field briefly.
   - Wait for user approval.
8. **Apply the configuration.**
   - Read `servers.json`, add the new entry under `mcpServers`, and write the file.
   - Validate that the resulting JSON is well-formed.
   - Remind the captain that hyprpilot's MCP catalog is static after daemon boot — they'll need to restart the daemon (`hyprpilot ctl daemon reload` reloads config; spawn-time MCP entries require a fresh `session/new`).

### Remove

1. Read `servers.json` and list available servers if no specific server is named.
2. Confirm with the user which server to remove.
3. Remove the entry and write the file.
4. Remind about the daemon-restart requirement.

### Modify

1. Read `servers.json` and show the current configuration for the target server.
2. Ask the user what they want to change (or apply the change they described).
3. If the change involves new variables or auth, follow the prompting steps from the Add flow.
4. If the user asks to change `hyprpilot.autoAcceptTools` or `autoRejectTools`, prompt for those specifically. Otherwise, do not re-prompt for tool approvals unless relevant to the modification.
5. Present the updated entry and wait for approval.
6. Apply and write the file.

## Key Principles

- **Never hardcode secrets.** Always use `${ENV_VAR}` references.
- **Prefer official servers.** First-party MCP servers from service providers are more reliable and feature-complete.
- **Prefer HTTP transport.** Remote HTTP endpoints avoid local dependency management.
- **Prefer `bunx` for stdio.** When stdio is needed, use `bunx -y package@latest` as the command pattern (matching existing entries). Fall back to `npx -y` or `uvx` based on the package ecosystem.
- **Validate JSON.** Always ensure `servers.json` remains valid after edits.
- **Preserve existing structure.** Do not reformat or reorder unrelated entries when adding/modifying a server.
- **Ask, don't assume.** When multiple options exist (auth method, transport, permission globs), present them to the user.
- **Hyprpilot is restart-to-reconfigure.** No runtime toggle — captain restarts the daemon after edits.
