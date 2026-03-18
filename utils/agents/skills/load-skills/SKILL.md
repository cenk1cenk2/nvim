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

| Signal                                 | Workspace | Skill resource                |
| -------------------------------------- | --------- | ----------------------------- |
| Issue ID prefix `K-xxx`                | kilic-dev | `skills://skill/linear-kilic` |
| Issue ID prefix `CLOUD-xxx`            | Laravel   | `skills://skill/linear-work`  |
| Linear URL containing `kilic-dev`      | kilic-dev | `skills://skill/linear-kilic` |
| Linear URL containing `laravel`        | Laravel   | `skills://skill/linear-work`  |
| GitLab repository (`gitlab.kilic.dev`) | kilic-dev | `skills://skill/linear-kilic` |
| GitHub repository (Laravel org)        | Laravel   | `skills://skill/linear-work`  |
| User says "work" or "laravel"          | Laravel   | `skills://skill/linear-work`  |
| User says "personal" or "kilic"        | kilic-dev | `skills://skill/linear-kilic` |
| No signal available                    | —         | Ask the user                  |

#### Skill Chaining

Some skills reference other skills as follow-up actions. When a skill recommends invoking another skill, load it via `ReadMcpResourceTool`:

| Context                                     | Skill resource                            |
| ------------------------------------------- | ----------------------------------------- |
| Need to create Linear issues                | `skills://skill/linear-issue-create`      |
| Need to create a Linear project             | `skills://skill/linear-project-create`    |
| Need to update/refine an issue description  | `skills://skill/linear-issue-update`      |
| Need to create a Linear initiative          | `skills://skill/linear-initiative-create` |
| Need to update a Linear initiative          | `skills://skill/linear-initiative-update` |
| Need to organize a todo note into the vault | `skills://skill/obsidian-note`            |

#### Multiple Instances

When a skill exists in multiple variants (e.g., `linear-kilic-project-argocd-system` and `linear-kilic-project-argocd-workload`), deduce from context:

- **System components** (operators, controllers, CRDs deployed to `cluster-system` or `*-system` namespaces) → `linear-kilic-project-argocd-system`
- **Application workloads** (apps, services, CRD instances deployed to target clusters) → `linear-kilic-project-argocd-workload`
- If unclear, ask the user.

### Loading Skills Without a Skill Mechanism

For LLMs or environments that do not have a native skill invocation system (no `/slash-commands`), skills can be loaded using the **skills MCP resources** on the `mcphub` server:

1. Use `ListMcpResourcesTool({ server: "mcphub" })` to discover available skills. Each skill resource is tagged `[auto]` (model can auto-invoke) or `[manual]` (explicit user request only).
2. Read `ReadMcpResourceTool({ server: "mcphub", uri: "skills://skill/{name}" })` to read a skill. For multiple skills, make parallel calls.
3. Follow the instructions in the file as if they were system instructions for the current task.
4. If the loaded skill has its own prerequisites, resolve them recursively.

**Fallback:** If skills MCP resources are unavailable, read the file directly at `~/.config/nvim/utils/agents/skills/<skill-name>/SKILL.md` using filesystem tools.

### Reference Files

Skills may declare references to additional files for shared conventions and detailed context. References are declared in YAML frontmatter as comma-separated relative paths:

```yaml
references:
  - ../references/linear-prerequisite.md
  - ../references/plan-mode.md
```

**How references work:**

1. When a skill is invoked, its declared references are resolved and listed in the XML `<References>` block.
2. The SKILL.md body tells you which references to read and when (e.g., "Read the `slack` reference for available tools and conventions.").
3. **Read reference files using `ReadMcpResourceTool`** from the `mcphub` server — read all references for a skill: `skills://skill/{name}/references`. For shared references outside a skill context: `skills://reference/{name}`.
   - References resolve automatically — shared references and skill-local ones are both handled.
4. Skills must work even without references (graceful degradation) — they contain enough inline context to function.

**Fallback:** If skills MCP tools are unavailable, read reference files using `filesystem__read_file` or `neovim__read_file` at `~/.config/nvim/utils/agents/skills/references/<filename>`.

**Reference locations:**

| Path pattern              | Scope                 | Example                                |
| ------------------------- | --------------------- | -------------------------------------- |
| `../references/<file>.md` | Shared across skills  | `../references/linear-prerequisite.md` |
| `./references/<file>.md`  | Specific to one skill | `./references/research-workflow.md`    |

**Do NOT auto-load references.** Only read them when the skill's instructions tell you to.

### Dismissing Skills

When the user explicitly asks to unload a skill (e.g., "unload the obsidian skill", "dismiss the linear skill", "drop the slack skill"):

1. **Acknowledge** — confirm which skill is being unloaded.
2. **Mark as obsolete** — treat the skill's instructions in context as obsolete. They can be cleaned up during context compaction.
3. **Drop orphaned prerequisites** — if the dismissed skill was the only reason a prerequisite was loaded, mark the prerequisite as obsolete too. Ask if unclear.
4. **Re-invocation is allowed** — if context later matches the dismissed skill, it can be auto-invoked again normally. Dismissal is not permanent.

### Key Rules

- **Announce loaded skills.** When a skill is loaded, give a one-line summary: `Using <skill-name> — <what it does>.` (e.g., `Using config-agents — updates the AGENTS.md guidelines file.`).
- **Auto-invoke when unambiguous.** If context clearly identifies the prerequisite, load it without asking.
- **Ask when ambiguous.** If multiple skills could apply and context doesn't disambiguate, ask the user.
- **Never skip prerequisites.** A skill that declares a prerequisite MUST have it satisfied — there are no optional prerequisites.
- **Recursive resolution.** If a loaded prerequisite has its own prerequisites, resolve those too.
- **One workspace per session.** Once a Linear workspace skill is loaded, use it for the entire session unless the user explicitly switches.
