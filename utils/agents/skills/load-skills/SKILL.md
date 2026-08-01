---
name: load-skills
description: 'load-skills Background knowledge on resolving skill dependencies and chaining or auto-invoking prerequisite skills - read when a skill declares prerequisites or multiple skills are active together. Not a user action; do NOT invoke to perform a task.'
---

## Skill Cross-Loading

## Purpose

Skills in `~/.config/nvim/utils/agents/skills/` form an interconnected ecosystem. Many skills depend on others being active first (e.g., Linear issue skills need a workspace skill). This skill defines how to **automatically resolve and load dependencies** without requiring the user to manually invoke each prerequisite.

## How It Works

When a skill has a **PREREQUISITE** block, the agent MUST ensure that prerequisite is satisfied before proceeding. If the prerequisite skill has not been invoked in the current session:

1. **Deduce which skill to load** from the available context.
2. **Load and execute the prerequisite skill** before continuing with the requested skill.
3. **If ambiguous, ask the user** — never guess when multiple options are equally valid.

## Deduction Rules

### Linear Workspace Detection

Two Linear workspaces exist. Deduce which one from context:

| Signal                                 | Workspace | Skill                |
| -------------------------------------- | --------- | -------------------- |
| Issue ID prefix `K-xxx`                | kilic-dev | `linear-kilic`       |
| Issue ID prefix `CLOUD-xxx`            | Laravel   | `linear-laravel`        |
| Linear URL containing `kilic-dev`      | kilic-dev | `linear-kilic`       |
| Linear URL containing `laravel`        | Laravel   | `linear-laravel`        |
| GitLab repository (`gitlab.kilic.dev`) | kilic-dev | `linear-kilic`       |
| GitHub repository (Laravel org)        | Laravel   | `linear-laravel`        |
| User says "work" or "laravel"          | Laravel   | `linear-laravel`        |
| User says "personal" or "kilic"        | kilic-dev | `linear-kilic`       |
| No signal available                    | —         | Ask the user         |

### Skill Chaining

Some skills reference other skills as follow-up actions. When a skill recommends invoking another skill, read its `SKILL.md`:

| Context                                     | Skill                       |
| ------------------------------------------- | --------------------------- |
| Need to create Linear issues                | `linear-issue-create`       |
| Need to create a Linear project             | `linear-project-create`     |
| Need to update/refine an issue description  | `linear-issue-update`       |
| Need to create a Linear initiative          | `linear-initiative-create`  |
| Need to update a Linear initiative          | `linear-initiative-update`  |
| Need to organize a todo note into the vault | `obsidian-note`             |

### Multiple Instances

When a skill exists in multiple variants (e.g., `linear-kilic-project-argocd-system` and `linear-kilic-project-argocd-workload`), deduce from context:

- **System components** (operators, controllers, CRDs deployed to `cluster-system` or `*-system` namespaces) → `linear-kilic-project-argocd-system`
- **Application workloads** (apps, services, CRD instances deployed to target clusters) → `linear-kilic-project-argocd-workload`
- If unclear, ask the user.

## Loading Skills

Skills live as plain Markdown files at `~/.config/nvim/utils/agents/skills/<name>/SKILL.md`. The hyprpilot harness usually attaches them for you; when it doesn't, read them directly from disk.

**Discovery** — read the `hyprpilot://skills` resource: the whole catalogue as one markdown index, with every slug and description, and a header explaining how to load them. One read instead of a directory listing plus ~100 frontmatter reads. Fall back to listing `~/.config/nvim/utils/agents/skills/` and reading each `SKILL.md`'s frontmatter only when the resource is unavailable. Skills with `disableModelInvocation: true` are manual-only — only load on explicit user request.

**Three ways a skill becomes loaded:**

1. **Harness attachment.** The captain pastes `#{hyprpilot://skills/<name>}`, picks the skill from the palette, or hyprpilot auto-attaches it for the turn. The skill body lands in context as a markdown attachment with the bundle path. Treat it as loaded — follow the instructions in the attachment.

2. **Filesystem `Read`.** The skill isn't in context but you need it (recursive prerequisite resolution, cross-loading, etc.). Use the built-in `Read` tool against `~/.config/nvim/utils/agents/skills/<name>/SKILL.md`. For multiple skills, read in parallel.

3. **MCP tool.** Hyprpilot's in-tree MCP server exposes `mcp__hyprpilot_skills__list_skills` (discovery against the daemon's resolved per-instance catalog) and `mcp__hyprpilot_skills__read_skill { slug }` (body fetch). Use these when you specifically want the daemon's filtered view (per-profile `[[mcp.skills.dirs]]` filtering / `ignore` globs honoured); use plain `Read` otherwise.

**Recursive prerequisites:** if a loaded skill declares its own prerequisites, resolve them by re-entering this procedure for each.

**Graceful degradation:** skills must work even when references fail to load — they contain enough inline context to function.

**Do NOT auto-load references.** Only read a reference when the skill's body tells you to.

## Reference Files

Skills may declare references to additional files for shared conventions and detailed context. References are declared in YAML frontmatter as a YAML array of relative paths:

```yaml
references:
  - ../references/linear-prerequisite.md
  - ../references/present-first.md
```

**Reference locations:**

| Path pattern              | Scope                 | Filesystem resolution                                                              |
| ------------------------- | --------------------- | ---------------------------------------------------------------------------------- |
| `../references/<file>.md` | Shared across skills  | `~/.config/nvim/utils/agents/skills/references/<file>.md`                          |
| `./references/<file>.md`  | Specific to one skill | `~/.config/nvim/utils/agents/skills/<skill>/references/<file>.md`                  |

References are read via the built-in `Read` tool. Hyprpilot's `mcp__hyprpilot_skills__load_skill_references { slug }` bundles every reference a skill declares into one response (concatenated with `--- <basename> ---` delimiters) — useful when you want the daemon to walk the frontmatter for you instead of reading paths one at a time.

There is no standalone-reference URI; shared references are accessed through the skill that declares them, or by `Read`ing the file directly when you need it outside a skill load.

## Dismissing Skills

When the user explicitly asks to unload a skill (e.g., "unload the obsidian skill", "dismiss the linear skill", "drop the slack skill"):

1. **Acknowledge** — confirm which skill is being unloaded.
2. **Mark as obsolete** — treat the skill's instructions in context as obsolete. They can be cleaned up during context compaction.
3. **Drop orphaned prerequisites** — if the dismissed skill was the only reason a prerequisite was loaded, mark the prerequisite as obsolete too. Ask if unclear.
4. **Re-invocation is allowed** — if context later matches the dismissed skill, it can be auto-invoked again normally. Dismissal is not permanent.

## Key Rules

- **Announce loaded skills.** When a skill is loaded, give a one-line summary: `Using <skill-name> — <what it does>.` (e.g., `Using config-agents — updates the AGENTS.md guidelines file.`).
- **Auto-invoke when unambiguous.** If context clearly identifies the prerequisite, load it without asking.
- **Ask when ambiguous.** If multiple skills could apply and context doesn't disambiguate, ask the user.
- **Never skip prerequisites.** A skill that declares a prerequisite MUST have it satisfied — there are no optional prerequisites.
- **Recursive resolution.** If a loaded prerequisite has its own prerequisites, resolve those too.
- **One workspace per session.** Once a Linear workspace skill is loaded, use it for the entire session unless the user explicitly switches.
