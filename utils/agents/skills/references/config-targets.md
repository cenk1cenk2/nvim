# Config Targets

Every `config-*` skill edits something other than itself. This is the map of what each one targets,
and the rule for a gap in the skill file itself.

## The target is the file the lesson acts on

A `config-*` skill is the procedure for editing a target. A durable lesson belongs in the target,
because the target is what an agent reads at the moment it needs the rule.

| Skill | Target |
|---|---|
| `config-skills` | the skill file(s) whose description already covers the behaviour — `skills/<name>/SKILL.md`, and every sibling that shares it |
| `config-references` | the reference file whose topic covers the convention; a new reference when none fits |
| `config-repository` | `CLAUDE.md` / `AGENTS.md` in the repository being worked on |
| `config-agents` | `~/.config/nvim/utils/agents/AGENTS.md` |
| `config-mcp` | the MCP catalog at `~/.config/nvim/utils/agents/mcp/servers.json` |
| `config-hyprpilot` | the launcher config at `~/.dotfiles/hyprpilot/.config/hyprpilot/config.yaml` |

**Resolving the target is a search.** For `config-skills` and `config-references` the target is
whichever file's own description or topic already claims the behaviour — read the candidates and
match. There is usually more than one, and a rule present in one sibling but absent from the others
fails when a different entry point is used.

## A gap in the `config-*` file itself — propose it

Sometimes the lesson is about the procedure: a missing authoring convention, a validation step
nobody runs, a target the skill never names. That is worth raising, and the captain decides whether
it lands.

- **Finish the real work first.** The target edit is the deliverable.
- **Then propose.** One short block: what is missing, where it would go, why this session hit it.

**When the captain asks for the skill directly** — "update `config-skills`", "fix
`config-repository`", or a `/config-*` invocation aimed at the skill — that file is the target, and
the normal present-first flow applies.

**`config-hyprpilot` carries one carve-out.** It documents an external binary's schema, so drift
between its own tables and the installed hyprpilot is a factual correction it makes in place. That
covers the schema digest; a gap in its procedure is proposed like any other.
