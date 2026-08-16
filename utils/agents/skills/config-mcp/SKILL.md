---
name: config-mcp
description: config-mcp Add, remove, or modify MCP server entries in the hyprpilot catalog; researches the server, prefers official HTTP sources, prompts for variables and auth. Use on "add an MCP server", "remove that server". Not for skills, agent guidelines, repo knowledge bases, or launcher settings, which are edited in the hyprpilot config directly.
disableModelInvocation: true
references:
  - ../references/current-state-only.md
  - ../references/present-first.md
  - ../references/config-targets.md
  - ../references/output-diff.md
  - ../references/redact-private-data.md
argumentHint: '[add|remove|modify] [server-name] [optional: description]'
---

## MCP Server Configuration Manager

Posture: `present-first`.

**Target: the MCP catalog at `~/.config/nvim/utils/agents/mcp/servers.json`.** The hyprpilot launcher config that wires this catalog into a launch is `config-hyprpilot`'s.

> **ABSOLUTE — discover the target before drafting, per `config-targets`.** This file is the procedure; the target is the catalog and whatever else the request is actually about. A server's own facts belong to its manual, not here. Editing this file needs the captain naming it **and** blessing the change — otherwise propose and stop.

## Context

The captain runs **hyprpilot** as the agent host. Hyprpilot loads MCP servers via the `[[mcps]]` array in `~/.config/hyprpilot/config.yaml` — each entry either points at a catalog file (`{ file = "..." }`) or declares inline `mcp_servers = { ... }`. The active catalog file is `~/.config/nvim/utils/agents/mcp/servers.json`. Per-profile `mcps` arrays wholesale-replace the global default.

This skill edits the catalog file `~/.config/nvim/utils/agents/mcp/servers.json`. Its top-level key is `mcpServers` — the standard shape Claude Code / Codex / every MCP client uses. Each server entry follows one of two transport patterns:

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

> **The catalog file is shared with other clients.** `~/.config/nvim/utils/agents/mcp/servers.json` is consumed by hyprpilot and may be referenced from other MCP clients too. `${VAR}` syntax works in hyprpilot, Claude Code, and Codex; for OpenCode (`{env:VAR}` style), keep a one-shot conversion at hand: `sed 's/${\([A-Z_][A-Z0-9_]*\)}/{env:\1}/g' servers.json`. Do NOT mix syntaxes inside a single file.

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

- **Glob the surface, not the vendor's docs.** A server may register less than its documentation lists, and a launch flag can cut the surface further. Decide the globs against what it actually registers: a server whose whole surface is reads can auto-accept wholesale, one that mixes reads and writes rejects the write globs explicitly. Load the server's same-named skill when the surface is not obvious from the entry.
- **Command execution belongs in `Bash`.** A server tool that runs arbitrary commands or mutates the captain's environment goes in `autoRejectTools` — `Bash` is where execution is visible and permission-prompted.
- **A tool policy is not an approval gate.** Auto-accepting a server's reads says nothing about whether reaching into what it reads is the captain's call. Where such a gate exists it is behavioural and lives in that server's own skill, which the permission lane cannot enforce.
- **No `git` MCP.** Local git is the raw `git` CLI via `Bash`. If a user asks to add a git server, raise the trade-off (extra surface area; the commands are already reachable through Bash) before doing so.
- **In-tree hyprpilot servers.** Do NOT add `hyprpilot`, `hyprpilot_skills`, or `hyprpilot_harness` entries here — those names are **reserved**, and an entry using one is silently replaced by the injected server. Hyprpilot auto-injects three of its own at launch, gated by the `[mcp]` block in `~/.config/hyprpilot/config.yaml`:
  - `hyprpilot` (`mcp serve`) — general tools (`open`). On by default.
  - `hyprpilot_skills` (`mcp skills`) — skills as `hyprpilot://skills/<slug>` resources plus `mcp__hyprpilot_skills__list_skills` / `read_skill` / `list_skill_references` / `read_skill_references` / `reload`. On by default, and additionally gated on the resolved `[[mcp.skills.dirs]]` catalog being non-empty.
  - `hyprpilot_harness` (`mcp harness`) — `list_profiles` / `spawn` / `session_*` for driving other agent sessions, plus session resources under `hyprpilot://sessions/`. **Off unless `mcp.harness.enabled` says otherwise**, since `spawn` runs a profile's `command` as this user.

  `mcp.enabled: false` is the master gate over all three; each also takes its own `enabled` / `name` / `autoAcceptTools` / `autoRejectTools`. Per-server tool policy **overrides** the `[mcp]`-level globs rather than merging with them — so enabling the harness without its own `autoAcceptTools` inherits `["*"]` and auto-approves `spawn`.

  `mcp.harness` carries four more knobs, all scoping what a spawned agent may reach:

  | Key | Default | Effect |
  |-----|---------|--------|
  | `maxDepth` | `1` | How deep spawning nests. A session at the cap gets **no harness injected** and its `spawn` is refused, so the lead delegates and the delegate works. Raising it reopens the next level with nothing else to change. |
  | `includeProfiles` / `excludeProfiles` | unset | Globs scoping which profiles *this* launcher may delegate to. They AND with each profile's own `[profiles.harness]` opt-in, so a glob can never promote a profile that never opted in. Exclude beats include. |
  | `mcp` | unset | An `[mcp]`-shaped overlay every delegate receives, folded **per leaf** over the delegate's own resolved block — a key you set wins, a key you leave unset inherits. This is what narrows a delegate's MCP reach. |
  | `notifyOnComplete` | `true` | The Claude channel push when a turn ends. Noise control only; an unregistered channel is dropped silently either way. |

  **Write a seeded key the way the seed writes it.** Both casings parse, but patches merge by key string before anything is typed — so writing `maxDepth` / `maxSessions` / `notifyOnComplete` in the other spelling reaches serde as a duplicate field and fails config load.

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
   - Show the complete JSON entry in chat per `output-diff`.
   - Explain each field briefly.
   - Wait for user approval.
8. **Apply the configuration.**
   - Read `servers.json`, add the new entry under `mcpServers`, and write the file.
   - Validate that the resulting JSON is well-formed.
   - Remind the captain that the MCP catalog is read once per launch. There is no daemon and no reload command — hyprpilot resolves the config, projects it onto the vendor CLI, and `exec()`s into it. A catalog edit reaches an agent on the **next** `hyprpilot <profile>`; a session already running keeps the catalog it launched with.

### Remove

1. Read `servers.json` and list available servers if no specific server is named.
2. Confirm with the user which server to remove.
3. Remove the entry and write the file.
4. Remind the captain that the removal applies to the next launched session — a session already running keeps the catalog it launched with.

### Modify

1. Read `servers.json` and show the current configuration for the target server.
2. Ask the user what they want to change (or apply the change they described).
3. If the change involves new variables or auth, follow the prompting steps from the Add flow.
4. If the user asks to change `hyprpilot.autoAcceptTools` or `autoRejectTools`, prompt for those specifically. Otherwise, do not re-prompt for tool approvals unless relevant to the modification.
5. Present the updated entry per `output-diff` and wait for approval.
6. Apply and write the file.

## Validation

Before presenting any edit, run the `current-state-only` check: no compat entries kept "just in case", no note of what a server was called before, no migration history. State the config as it is now.

## Key Principles

- **Never hardcode secrets.** Always use `${ENV_VAR}` references.
- **No private specifics.** Keep real account IDs, internal hostnames, and tokens out of the config and its examples per `redact-private-data` — use `${ENV_VAR}` references and placeholders.
- **Prefer official servers.** First-party MCP servers from service providers are more reliable and feature-complete.
- **Prefer HTTP transport.** Remote HTTP endpoints avoid local dependency management.
- **Prefer `bunx` for stdio.** When stdio is needed, use `bunx -y package@latest` as the command pattern (matching existing entries). Fall back to `npx -y` or `uvx` based on the package ecosystem.
- **Validate JSON.** Always ensure `servers.json` remains valid after edits.
- **Preserve existing structure.** Do not reformat or reorder unrelated entries when adding/modifying a server.
- **Ask, don't assume.** When multiple options exist (auth method, transport, permission globs), present them to the user.
- **Hyprpilot is relaunch-to-reconfigure.** Config is read once at launch and projected onto the vendor CLI; there is no daemon to restart and no runtime toggle. Edits apply to the next launched session.
