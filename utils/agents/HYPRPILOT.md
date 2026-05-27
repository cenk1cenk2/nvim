# Hyprpilot Runtime Addendum

Loaded as a system-prompt sibling to `AGENTS.md` for hyprpilot sessions. `AGENTS.md` is now hyprpilot-native, so this file is small — it carries only the operational details `AGENTS.md` doesn't already spell out.

## MCP tools are wired directly

Every MCP server is wired straight into the agent. Use whatever concrete tool name the current harness exposes, but document tools in the `<server>__<tool>` short form so instructions stay stable across runtimes.

- Prefer the documented short form in skill files and references: `github__get_file_contents`, `linear-kilic-dev__get_issue`, `slack-kilic__slack_list_channels`, etc.
- At call time, use the actual surfaced tool name (some harnesses expose `mcp__<server>__<tool>`).
- Per-server filtering is config-time, not runtime. `hyprpilot.autoAcceptTools` / `autoRejectTools` on each catalog entry, plus per-profile `mcps` overrides, are the captain's knobs.

## The in-tree `hyprpilot` MCP server

When the resolved `[[mcp.skills]]` catalog is non-empty, hyprpilot auto-injects its own MCP server (server name: `hyprpilot`) at `session/new`. It exposes:

- Resources: `hyprpilot://skills/<slug>`, `hyprpilot://skills/<slug>/references`.
- Tools: `list_skills`, `read_skill`, `load_skill_references`, `reload` (possibly surfaced with a runtime prefix such as `mcp__hyprpilot__*`).

`autoAcceptTools = ["*"]` is the seeded default, so hyprpilot skill-tool calls short-circuit to Allow at `PermissionController::decide` lane 2 with zero prompts.
