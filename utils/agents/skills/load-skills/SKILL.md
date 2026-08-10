---
name: load-skills
description: 'load-skills Background knowledge on resolving skill dependencies and chaining or auto-invoking prerequisite skills - read when a skill declares prerequisites or multiple skills are active together. Load it to resolve a dependency, never as the task itself.'
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

Two Linear workspaces exist. The `linear-prerequisite` reference owns the deduction table — read it to pick the workspace skill.

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

Discovery and loading are defined in `AGENTS.md` §III Hyprpilot.

**Recursive prerequisites:** if a loaded skill declares its own prerequisites, resolve them by re-entering this procedure for each.

**Graceful degradation:** skills must work even when references fail to load — they contain enough inline context to function.

**A skill's declared references arrive with it.** `read_skill` appends them by default. Pass `references: false` when the bundle would be waste — you are editing the skill rather than following it, or you already hold its references from a skill loaded earlier this session — then `Read` only the files you lack. Only a path-read reference, one the body names with an explicit absolute path, waits for its branch.

## Reference Files

Skills may declare references to additional files for shared conventions and detailed context. References are declared in YAML frontmatter as a YAML array of relative paths:

```yaml
references:
  - ../references/linear-prerequisite.md
  - ../references/output-diff.md
```

**Reference locations:**

| Path pattern              | Scope                 | Filesystem resolution                                                              |
| ------------------------- | --------------------- | ---------------------------------------------------------------------------------- |
| `../references/<file>.md` | Shared across skills  | `~/.config/nvim/utils/agents/skills/references/<file>.md`                          |
| `./references/<file>.md`  | Specific to one skill | `~/.config/nvim/utils/agents/skills/<skill>/references/<file>.md`                  |

Declared references arrive with the skill. `mcp__hyprpilot_skills__load_skill_references { slug }` fetches them without the body, for when the body is already in context.

`hyprpilot://references/<slug>` is the resource form of the same bundle. Outside a skill load, `Read` the file directly.

## Dismissing Skills

When the user explicitly asks to unload a skill (e.g., "unload the obsidian skill", "dismiss the linear skill", "drop the slack skill"):

1. **Acknowledge** — confirm which skill is being unloaded.
2. **Mark as obsolete** — treat the skill's instructions in context as obsolete. They can be cleaned up during context compaction.
3. **Drop orphaned prerequisites** — if the dismissed skill was the only reason a prerequisite was loaded, mark the prerequisite as obsolete too. Ask if unclear.
4. **Re-invocation is allowed** — if context later matches the dismissed skill, it can be auto-invoked again normally. Dismissal is not permanent.

## Key Rules

- **Auto-invoke when unambiguous.** If context clearly identifies the prerequisite, load it without asking.
- **Ask when ambiguous.** If multiple skills could apply and context doesn't disambiguate, ask the user.
- **Never skip prerequisites.** A skill that declares a prerequisite MUST have it satisfied — there are no optional prerequisites.
- **Recursive resolution.** If a loaded prerequisite has its own prerequisites, resolve those too.
- **One workspace per session.** Once a Linear workspace skill is loaded, use it for the entire session unless the user explicitly switches.
