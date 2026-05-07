# Hyprpilot Runtime Overlay

This file is loaded as a system-prompt overlay alongside `AGENTS.md` when the agent is running under **Hyprpilot**. It overrides the runtime-detection sections of `AGENTS.md` (Section I.4 "Discover Available Skills" and the Skills Architecture in Section II) with the concrete Hyprpilot wiring.

> **Precedence:** when this file contradicts `AGENTS.md`, this file wins. `AGENTS.md` describes a generic runtime; Hyprpilot is one specific runtime — the one currently in use.

## Skills are attached, not loaded

- Skills are attached into context **by the harness** when the session starts, or on demand when the user invokes a skill. Treat every attached skill as already loaded — follow its instructions directly.
- **Do NOT attempt runtime discovery.** Path A (mcphub) does not exist in this runtime. There is no `mcphub` server, no `ListMcpResourcesTool`, no `ReadMcpResourceTool`, no `Skill` tool. Any reference to those in `AGENTS.md` or in a skill body should be read as "use the equivalent direct-filesystem path described below."
- **Do NOT call mcphub-style URIs** like `skills://skill/<name>` or `skills://reference/<name>`. They will not resolve.

If a skill the user references has not been attached and you genuinely need it:

- Read it directly from disk with the built-in `Read` tool. The base path is `~/.config/nvim/utils/agents/skills/<name>/SKILL.md`.

## Reference resolution

References declared in a skill's `references:` frontmatter are NOT auto-attached. When the skill body says "read the X reference", resolve relative to the skill's directory:

| Path in skill frontmatter | Resolves to |
|---|---|
| `../references/<file>.md` | `~/.config/nvim/utils/agents/skills/references/<file>.md` |
| `./references/<file>.md` | `~/.config/nvim/utils/agents/skills/<skill>/references/<file>.md` |

The skills root is always `~/.config/nvim/utils/agents/skills/`. Read references via the built-in `Read` tool.

## MCP tools are wired directly

Every MCP server is wired directly to the agent in this runtime — there is no aggregator hub.

- Tool prefix is the **bare server name**, not routed through any hub: `github__get_file_contents`, `linear-kilic-dev__get_issue`, `slack-kilic__slack_list_channels`, etc.
- Do NOT prepend `mcp__mcphub__` or any other hub prefix. The harness does not surface tools that way here.
- The MCP Tool Name Convention in `AGENTS.md` Section III still applies for the `<server>__<tool>` short-form — just skip the hub-prefix-resolution step.
- `disabled_tools` filtering happens at the agent boundary directly; there is no upstream hub to filter through.

## What still applies from AGENTS.md

Everything else from `AGENTS.md` applies unchanged: Tool Selection Priority, File Operations, Code Style, User Interaction Patterns, Session Maintenance, Plan File Location, Memory Updates, Knowledge Base Updates, and the Rule Priority list. This file only reshapes the loading mechanics — not the behavior.
