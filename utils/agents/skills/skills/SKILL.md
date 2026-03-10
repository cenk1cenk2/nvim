---
name: skills
description: Create, update, or review skills in the skills directory. Use when the user wants to add a new skill, modify an existing one, or understand the skill conventions.
interaction: chat
argument-hint: "[create|update|review] [skill-name] [description of what the skill should do]"
---

## system

### Skill Management

> **ALWAYS enter plan mode for this prompt.**
>
> - Present findings, drafts, or proposed changes to the user.
> - Iterate based on feedback.
> - Do NOT write files until the user explicitly approves the plan.

### Skills Directory

All skills live in `~/.config/nvim/utils/agents/skills/`. Each skill is a directory containing a `SKILL.md` file.

```
~/.config/nvim/utils/agents/skills/
├── skill-name/
│   └── SKILL.md
├── another-skill/
│   └── SKILL.md
```

### Process

#### Create

1. Determine what the skill should do. Ask the user if not clear from context.
2. Read 2-3 existing skills to understand patterns, tone, and structure.
3. Draft the full `SKILL.md` and present it in chat.
4. Iterate based on user feedback.
5. After approval, create the directory and write the file.

#### Update

1. Read the existing `SKILL.md` for the target skill.
2. Review the preceding conversation for key learnings, corrections, or deviations from the current skill content.
3. Identify what needs to change and present proposed changes to the user.
4. Iterate based on feedback.
5. After approval, apply the changes.

#### Review

1. Read the existing `SKILL.md` for the target skill.
2. List ambiguities, inconsistencies, or areas that could be improved.
3. Ask clarifying questions to understand user intent.
4. Propose specific improvements based on answers.
5. After approval, apply the changes (or leave as-is if no changes needed).

### SKILL.md Format

Every `SKILL.md` starts with YAML frontmatter followed by markdown instructions.

**Required frontmatter fields:**

```yaml
---
name: skill-name # kebab-case, matches directory name
description: One-line description of what the skill does and when to use it.
interaction: chat
---
```

**Optional frontmatter fields:**

```yaml
disable-model-invocation: true # Prevents the model from auto-invoking this skill.
argument-hint: "[args]" # Shown to user as usage hint.
```

**Body structure:**

```markdown
## system

> **Plan mode directive** (choose one per skill)
>
> - "ALWAYS enter plan mode" — for skills that require research and planning before action.
> - "DO NOT enter plan mode" — for interactive or quick-action skills.

### Context (optional)

Background information the agent needs to do its job.

### Process

Numbered steps describing the workflow.

### Format / Conventions (optional)

Templates, patterns, or formatting rules.

### Key Principles (optional)

Guiding rules for the skill's behavior.
```

### Conventions

- **Directory name** must match the `name` field in frontmatter, both in kebab-case.
- **Description** should answer two questions: what does it do, and when should it be used.
- **Plan mode** — use it for skills that need research or multi-step planning. Skip it for interactive or quick-turnaround skills.
- **`disable-model-invocation: true`** — use when the skill should only be triggered by explicit user request, not auto-detected.
- **MCP tools** — reference specific tool names (e.g., `mcp__mcphub__github__*`) when the skill depends on them.
- **Be concise** — skills are instructions for an agent, not documentation for humans. Keep it actionable.
- **End list items with `.`** — consistent punctuation across all skills.
