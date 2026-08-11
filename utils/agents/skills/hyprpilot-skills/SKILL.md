---
name: hyprpilot-skills
description: hyprpilot-skills Auto-invoked at session start when the hyprpilot_skills server is present. The skills system itself - the servers hyprpilot injects, how a skill and its references reach you, when to skip the reference bundle, and where skill source lives. Not for authoring or editing a skill, and not for driving a separate agent session.
---

## The Hyprpilot Skills System

Mechanics of how skills reach you. Whether to route a task through a skill at all is `AGENTS.md` §II — that rule stands on its own and does not depend on this skill loading.

## Injected Servers

| Server | Carries | Its manual |
|---|---|---|
| `hyprpilot_skills` | `list_skills`, `read_skill`, `load_skill_references`, `reload` | this skill |
| `hyprpilot` | general tools — `open` (URL, file, or directory in the OS default handler) | none yet |
| `hyprpilot_nvim` | the captain's live Neovim — buffers, LSP, diagnostics | `hyprpilot-nvim`, eager at startup |
| `hyprpilot_harness` | `spawn` / `session_*` for separate agent sessions, where enabled | `hyprpilot-delegate`, loaded only on the captain's explicit ask |

Every `hyprpilot_skills` tool is auto-accepted and never prompts.

## Loading a Skill

Skills are exposed as `hyprpilot://skills/<slug>` resources.

- `list_skills` — the catalog. Descriptions and metadata for every skill, no bodies.
- `read_skill { slug }` — one body, with its declared references appended.
- `load_skill_references { slug }` — that skill's references alone, no body.
- `reload` — after skill source changes on disk. Flow per `hyprpilot-reload`.

A skill the harness already attached is loaded — an `#{hyprpilot://skills/<slug>}` mention, a palette pick, or auto-injection. Do not re-read it.

**Never use the runtime's own built-in skill tool for these.** That tool serves the harness's own skills, not the hyprpilot catalog.

## The Catalog Is Profile-Filtered

The active hyprpilot profile drops some skills, so `list_skills` — not the filesystem — is the source of truth for what exists this session. Reading a `SKILL.md` by path can pull in a skill the profile deliberately dropped. Use filesystem paths only when editing source.

## References Arrive With Their Skill

`read_skill` appends a skill's declared references under a `skill_references:` banner, one `reference:` block per file. That is why a skill body names its references inline (`per \`output-diff\``) rather than telling you to fetch them.

**Pass `references: false` when the bundle would be waste.** Two cases:

1. You are reading the skill to **edit** it rather than follow it.
2. **Its references are already in context** from a skill loaded earlier this session.

Shared references repeat heavily — `output-diff` is declared by 48 skills, `scm-detect` by 19. Loading `git-commit` then `git-push` repeats ~1.9k tokens; `agent-delegate` is 3.4k on its own.

**Then top up only what is missing.** The metadata lists every declared path, so compare against what you hold: `Read` the one or two files you lack, or call `load_skill_references { slug }` for the whole bundle. Re-reading a skill you already loaded is always `references: false`.

**The one exception is a path-read reference** — one a body names with an explicit absolute path, because it applies only on a branch most runs never take (per-harness runtime mechanics). Those are not declared and not bundled; `Read` that file only when you reach that branch.

## Skill Source

Lives under `~/.config/nvim/utils/agents/skills/`, shared references in `references/` at that root. Authoring conventions — frontmatter, description shape, reference tiering — belong to `config-skills`; suggest it rather than editing a `SKILL.md` freehand.
