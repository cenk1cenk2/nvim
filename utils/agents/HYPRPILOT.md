# Hyprpilot Runtime Addendum

Loaded as a system-prompt sibling to `AGENTS.md` for hyprpilot sessions. `AGENTS.md` is now hyprpilot-native, so this file is small — it carries only the operational details `AGENTS.md` doesn't already spell out.

## MCP tools are wired directly — no aggregator hub

Every MCP server is wired straight into the agent — there is no upstream hub aggregating them.

- **Tool prefix is the bare server name.** `github__get_file_contents`, `linear-kilic-dev__get_issue`, `slack-kilic__slack_list_channels`, etc. Do NOT prepend `mcp__<hub>__` of any flavour; the harness does not surface tools that way here.
- **`AGENTS.md` Section III convention applies** for the `<server>__<tool>` short-form — just skip the hub-prefix-resolution step.
- **Per-server filtering is config-time, not runtime.** `hyprpilot.autoAcceptTools` / `autoRejectTools` on each catalog entry, plus per-profile `mcps` overrides, are the captain's knobs. There is no runtime toggle (see `AGENTS.md` "Missing MCP Servers").

## The in-tree `hyprpilot` MCP server

When the resolved `[[mcp.skills]]` catalog is non-empty, hyprpilot auto-injects its own MCP server (server name: `hyprpilot`) at `session/new`. It exposes:

- Resources: `hyprpilot://skills/<slug>`, `hyprpilot://skills/<slug>/references`.
- Tools: `mcp__hyprpilot__list_skills`, `read_skill`, `load_skill_references`, `reload`.

`autoAcceptTools = ["*"]` is the seeded default, so `mcp__hyprpilot__*` calls short-circuit to Allow at `PermissionController::decide` lane 2 with zero prompts.
