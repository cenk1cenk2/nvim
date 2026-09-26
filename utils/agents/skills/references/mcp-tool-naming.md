# MCP Tool Naming

How skills, references, and catalog entries name MCP servers and their tools.

## Short Form

Write every tool as **`<server>__<tool>`** — the server name is the identifying factor: `github__get_file_contents`, `gitlab__get_merge_request`, `sourcebot-kilic__grep`, `linear-kilic__get_issue`, `grafana-kilic__query_prometheus`, `obsidian__vault_read`.

Never bake in a transport prefix (`mcp__<server>__…`, `mcp__<hub>__<server>__…`). Every server is wired directly into the agent, with no hub, and the runtime resolves the prefix at call time.

## Server Names

- **Kebab-case, `-` only.** Never `/` in a server key (some MCP hubs flatten it inconsistently into the tool prefix), and no `_` as a word separator inside one.
- **Workspace-suffixed servers are `<service>-<workspace>`**: `linear-kilic`, `linear-laravel`, `grafana-kilic`, `grafana-laravel`, `argocd-kilic`, `slack-kilic`, `spacelift-laravel`.
- **Hyprpilot's own servers follow the same rule**, each spelled exactly like its same-named skill: `hyprpilot`, `hyprpilot-skills`, `hyprpilot-nvim`, `hyprpilot-harness`.

## Which Server a Name Means

**A server name identifies the service and workspace, never which transport wins.** Where the running harness supplies an integration for that service, it is the one used and the standalone server is the stated fallback, per `harness-connectors`. A skill or reference naming such a server says so and points at `harness-connectors`; a table listing only the standalone server's tools pairs with that mapping.

## Name Only What a Server Registers

Several servers expose less than their vendor documents — a read-only flag, disabled write tools, a capability the catalog entry withholds. Load the server's same-named skill before writing steps or tables against it, and name only the surface it registers; a step routed through an unregistered tool reads as ordinary and fails only when run.

Where no server covers the job, name the CLI — local git is always raw `git`, so a `git__*` tool never appears. A server's own conventions (read/write splits, approval gates, per-tool traps) live in its manual; name that skill or reference rather than restating them.
