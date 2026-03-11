---
name: load-skills
description: Cross-load and chain skills automatically based on context. Reference this skill to understand how to resolve skill dependencies and auto-invoke prerequisite skills.
interaction: chat
---

## system

### Skill Cross-Loading

> **DO NOT enter plan mode.** This is a reference skill — it defines how skill dependencies are resolved.

### Purpose

Skills in `~/.config/nvim/utils/agents/skills/` form an interconnected ecosystem. Many skills depend on others being active first (e.g., Linear issue skills need a workspace skill). This skill defines how to **automatically resolve and load dependencies** without requiring the user to manually invoke each prerequisite.

### How It Works

When a skill has a **PREREQUISITE** block, the agent MUST ensure that prerequisite is satisfied before proceeding. If the prerequisite skill has not been invoked in the current session:

1. **Deduce which skill to load** from the available context.
2. **Load and execute the prerequisite skill** before continuing with the requested skill.
3. **If ambiguous, ask the user** — never guess when multiple options are equally valid.

### Deduction Rules

#### Linear Workspace Detection

Two Linear workspaces exist. Deduce which one from context:

| Signal | Workspace | Skill to load |
|---|---|---|
| Issue ID prefix `K-xxx` | kilic-dev | `~/.config/nvim/utils/agents/skills/linear-kilic/SKILL.md` |
| Issue ID prefix `CLOUD-xxx` | Laravel | `~/.config/nvim/utils/agents/skills/linear-work/SKILL.md` |
| Linear URL containing `kilic-dev` | kilic-dev | `~/.config/nvim/utils/agents/skills/linear-kilic/SKILL.md` |
| Linear URL containing `laravel` | Laravel | `~/.config/nvim/utils/agents/skills/linear-work/SKILL.md` |
| GitLab repository (`gitlab.kilic.dev`) | kilic-dev | `~/.config/nvim/utils/agents/skills/linear-kilic/SKILL.md` |
| GitHub repository (Laravel org) | Laravel | `~/.config/nvim/utils/agents/skills/linear-work/SKILL.md` |
| User says "work" or "laravel" | Laravel | `~/.config/nvim/utils/agents/skills/linear-work/SKILL.md` |
| User says "personal" or "kilic" | kilic-dev | `~/.config/nvim/utils/agents/skills/linear-kilic/SKILL.md` |
| No signal available | — | Ask the user |

#### Skill Chaining

Some skills reference other skills as follow-up actions. When a skill recommends invoking another skill, load it by path:

| Context | Skill to load |
|---|---|
| Need to create Linear issues | `~/.config/nvim/utils/agents/skills/linear-issue-create/SKILL.md` |
| Need to create a Linear project | `~/.config/nvim/utils/agents/skills/linear-project-create/SKILL.md` |
| Need to update/refine an issue description | `~/.config/nvim/utils/agents/skills/linear-issue-update/SKILL.md` |
| Need to create a Linear initiative | `~/.config/nvim/utils/agents/skills/linear-initiative-create/SKILL.md` |
| Need to update a Linear initiative | `~/.config/nvim/utils/agents/skills/linear-initiative-update/SKILL.md` |
| Need to organize a todo note into the vault | `~/.config/nvim/utils/agents/skills/obsidian-note/SKILL.md` |

#### Multiple Instances

When a skill exists in multiple variants (e.g., `linear-kilic-project-argocd-system` and `linear-kilic-project-argocd-workload`), deduce from context:

- **System components** (operators, controllers, CRDs deployed to `cluster-system` or `*-system` namespaces) → `linear-kilic-project-argocd-system`
- **Application workloads** (apps, services, CRD instances deployed to target clusters) → `linear-kilic-project-argocd-workload`
- If unclear, ask the user.

### Loading Skills Without a Skill Mechanism

For LLMs or environments that do not have a native skill invocation system (no `/slash-commands`), skills can be loaded by reading the `SKILL.md` file directly:

1. Read the file at the path specified (e.g., `~/.config/nvim/utils/agents/skills/linear-kilic/SKILL.md`).
2. Follow the instructions in the file as if they were system instructions for the current task.
3. If the loaded skill has its own prerequisites, resolve them recursively.

### Reference Files

Skills may declare references to additional files for shared conventions and detailed context. References are declared in YAML frontmatter as comma-separated relative paths:

```yaml
references: ../references/linear-prerequisite.md, ../references/plan-mode.md
```

**How references work:**

1. When a skill is invoked, its declared references are resolved and listed in the XML `<References>` block.
2. The SKILL.md body tells you which references to read and when (e.g., "Read the `linear-prerequisite` reference for workspace detection rules.").
3. Read reference files using `neovim__read_file` or `filesystem__read_file`.
4. If a reference file fails to load via relative path, resolve from the skills root: `~/.config/nvim/utils/agents/skills/`.
5. Skills must work even without references (graceful degradation) — they contain enough inline context to function.

**Reference locations:**

| Path pattern | Scope | Example |
|---|---|---|
| `../references/<file>.md` | Shared across skills | `../references/linear-prerequisite.md` |
| `./references/<file>.md` | Specific to one skill | `./references/research-workflow.md` |

**Do NOT auto-load references.** Only read them when the skill's instructions tell you to.

### Key Rules

- **Auto-invoke when unambiguous.** If context clearly identifies the prerequisite, load it without asking.
- **Ask when ambiguous.** If multiple skills could apply and context doesn't disambiguate, ask the user.
- **Never skip prerequisites.** A skill that declares a prerequisite MUST have it satisfied — there are no optional prerequisites.
- **Recursive resolution.** If a loaded prerequisite has its own prerequisites, resolve those too.
- **One workspace per session.** Once a Linear workspace skill is loaded, use it for the entire session unless the user explicitly switches.
