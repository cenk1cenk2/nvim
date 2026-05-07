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

#### Skill Chaining

Some skills reference other skills as follow-up actions. When a skill recommends invoking another skill, read its `SKILL.md`:

| Context                                     | Skill                       |
| ------------------------------------------- | --------------------------- |
| Need to create Linear issues                | `linear-issue-create`       |
| Need to create a Linear project             | `linear-project-create`     |
| Need to update/refine an issue description  | `linear-issue-update`       |
| Need to create a Linear initiative          | `linear-initiative-create`  |
| Need to update a Linear initiative          | `linear-initiative-update`  |
| Need to organize a todo note into the vault | `obsidian-note`             |

#### Multiple Instances

When a skill exists in multiple variants (e.g., `linear-project-argocd-system-kilic` and `linear-project-argocd-workload-kilic`), deduce from context:

- **System components** (operators, controllers, CRDs deployed to `cluster-system` or `*-system` namespaces) → `linear-project-argocd-system-kilic`
- **Application workloads** (apps, services, CRD instances deployed to target clusters) → `linear-project-argocd-workload-kilic`
- If unclear, ask the user.

### Loading Skills

Skills live as plain Markdown files at `~/.config/nvim/utils/agents/skills/<name>/SKILL.md`. The agent has two paths to access them. **Pick the path that matches the runtime, then stick with it for the whole session.**

#### Path A — mcphub is loaded

Detection: `mcphub__*` tools are in your toolset, and `ListMcpResourcesTool` / `ReadMcpResourceTool` are available.

When this path is active, **prefer the MCP resource interface** — it surfaces the `[auto]` / `[manual]` invocation tags and resolves a skill's references in a single call.

1. **Discover:** `ListMcpResourcesTool({ server: "mcphub" })`. Skills appear at `skills://skill/<name>` (with their `description` and `[auto]` / `[manual]` flag); shared references appear at `skills://reference/<name>`.
2. **Load a skill:** `ReadMcpResourceTool({ server: "mcphub", uri: "skills://skill/<name>" })`. For multiple skills, parallel calls.
3. **Load all references for a skill:** `ReadMcpResourceTool({ server: "mcphub", uri: "skills://skill/<name>/references" })` — returns every file declared in the skill's `references:` frontmatter, regardless of whether the path is shared (`../references/...`) or skill-local (`./references/...`).
4. **Load a shared reference standalone** (outside a skill load): `ReadMcpResourceTool({ server: "mcphub", uri: "skills://reference/<name>" })`.

#### Path B — direct integration (no mcphub)

Detection: no `mcphub__*` tools. The host is loading skills another way — Claude Code with a plugin/skills folder, OpenCode loading the directory, a generic MCP client without the mcphub bridge, or a plain shell session.

There are two sub-cases:

**B1. Skills are attached automatically** (Claude Code plugin, OpenCode skill folder, etc.). The host injects the relevant `SKILL.md` content into context as part of session setup or via an attachment when the user invokes the skill. Treat them as already loaded — follow the in-context instructions. No filesystem listing needed.

**B2. Skills are not attached.** Read the file directly from the filesystem:

1. **Discover:** list `~/.config/nvim/utils/agents/skills/` to enumerate skill directories. Read the frontmatter (first ~10 lines of each `SKILL.md`) for the `description` field. Skills with `disable-model-invocation: true` are the equivalent of `[manual]` — only load on explicit user request.
2. **Load a skill:** read `~/.config/nvim/utils/agents/skills/<name>/SKILL.md` directly. For multiple skills, read in parallel.
3. **Load references:** the skill declares its references in frontmatter — resolve each path **relative to the skill's directory** (`../references/<file>.md` → `~/.config/nvim/utils/agents/skills/references/<file>.md`; `./references/<file>.md` → `~/.config/nvim/utils/agents/skills/<name>/references/<file>.md`).

#### Both paths — common rules

1. Follow the instructions in the loaded `SKILL.md` as if they were system instructions for the current task.
2. If the loaded skill has its own prerequisites, resolve them recursively (re-enter the load procedure for each).
3. **Do NOT auto-load references.** Only read a reference when the skill's body tells you to.
4. Skills must work even when references fail to load (graceful degradation) — they contain enough inline context to function.

### Reference Files

Skills may declare references to additional files for shared conventions and detailed context. References are declared in YAML frontmatter as a YAML array of relative paths:

```yaml
references:
  - ../references/linear-prerequisite.md
  - ../references/plan-mode.md
```

**Reference locations:**

| Path pattern              | Scope                 | Example                                |
| ------------------------- | --------------------- | -------------------------------------- |
| `../references/<file>.md` | Shared across skills  | `../references/linear-prerequisite.md` |
| `./references/<file>.md`  | Specific to one skill | `./references/research-workflow.md`    |

**Resolution** depends on the runtime path (see "Loading Skills" above). On Path A, use `skills://skill/<name>/references` or `skills://reference/<name>`. On Path B, the absolute filesystem paths above apply.

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
