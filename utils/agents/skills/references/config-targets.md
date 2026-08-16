# Config Targets

Every `config-*` skill edits something other than itself. This is the discovery that finds that
something, the map of what each skill targets, and the rule for a gap in the skill file itself.

## ABSOLUTE — Discover the Target Before Drafting Anything

**A `config-*` skill is a procedure for editing something else. Step one of every run is finding out
what that something is.** Not this file. Not the skill you are reading. Search.

1. **Take what the request points at** — the skills, references, servers, files, or behaviour it
   names, plus what it implies. A request naming a `config-*` skill is usually naming the
   *procedure to run*, not the file to edit.
2. **Search for every file that owns the behaviour.** List the candidates and read them. There is
   almost always more than one, and a rule landing in one sibling while the others keep the old
   shape fails exactly when a different entry point is used.
3. **Name the targets back before drafting.** One line: the files you will edit and why each owns
   its part. A run that opens with a draft has skipped this step.

**Writing the lesson into the `config-*` file is the failure this rule exists to stop.** It reads as
diligence and produces nothing: the file is authoring guidance, nothing loads it at the moment the
behaviour is needed, and the files that *are* loaded then stay wrong. "I recorded it in the config
skill so future authors know" is the exact shape of the mistake.

## The target is the file the lesson acts on

A durable lesson belongs in the target, because the target is what an agent reads at the moment it
needs the rule.

| Skill | Target |
|---|---|
| `config-skills` | the skill file(s) whose description already covers the behaviour — `skills/<name>/SKILL.md`, and every sibling that shares it |
| `config-references` | the reference file whose topic covers the convention; a new reference when none fits |
| `config-repository` | `CLAUDE.md` / `AGENTS.md` in the repository being worked on |
| `config-agents` | `~/.config/nvim/utils/agents/AGENTS.md` |
| `config-mcp` | the MCP catalog at `~/.config/nvim/utils/agents/mcp/servers.json` |
| `config-hyprpilot` | the launcher config at `~/.dotfiles/hyprpilot/.config/hyprpilot/config.yaml` |

For `config-skills` and `config-references` the target is whichever file's own description or topic
already claims the behaviour — read the candidates and match.

**A fact about one server, service, or runtime belongs to that thing's own manual**, never to the
`config-*` procedure. The procedure carries the rule for deciding; the manual carries what is true
of that one thing. A per-server detail written into a `config-*` file is a second copy to keep in
sync, and the copy nobody reads while acting.

## A gap in the `config-*` file itself — propose it

Sometimes the lesson is about the procedure: a missing authoring convention, a validation step
nobody runs, a target the skill never names. That is worth raising, and the captain decides whether
it lands.

- **Finish the real work first.** The target edit is the deliverable.
- **Then propose.** One short block: what is missing, where it would go, why this run hit it.
- **Stop there.** Do not write it, even when the lesson is unmistakably about authoring.

**Two things must both hold before a `config-*` file is edited:**

1. **The captain names it** — "update `config-skills`", "fix `config-repository`", a `/config-*`
   invocation aimed at the file, or a correction pointing at the file's own content.
2. **The captain blesses the change** — the presented edit is approved, per `present-first`.

Naming it without a blessing means present and wait. A blessing for other work never reaches this
file. Once both hold, edit it and commit the result like any other target, per the calling skill's
own commit directive.

**`config-hyprpilot` carries one carve-out.** It documents an external binary's schema, so drift
between its own tables and the installed hyprpilot is a factual correction it makes in place. That
covers the schema digest; a gap in its procedure is proposed like any other.
