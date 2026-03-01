---
name: manage-skills
description: Create, update, or review skills in the skills directory. Use when the user wants to add a new skill, modify an existing one, or understand the skill conventions.
argument-hint: "[create|update] [skill-name] [description of what the skill should do]"
---

## Skill Management

> **DO NOT enter plan mode for this prompt.**
>
> - This is an interactive workflow
> - Present drafts to the user and iterate based on feedback
> - Do NOT write files until the user explicitly approves

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

1. **Understand the Request:**
   - Determine if this is a create, update, or review operation.
   - For updates, read the existing `SKILL.md` first.
   - For creates, ask what the skill should do if not clear from context.

2. **Research Existing Conventions:**
   - Read 2-3 existing skills from the directory to understand patterns.
   - Match the tone, structure, and level of detail of existing skills.
   - Pay attention to which skills use `disable-model-invocation`, `argument-hint`, plan mode, etc.

3. **Draft the Skill:**
   - Follow the SKILL.md format below.
   - Present the full draft to the user in chat.
   - Iterate based on feedback.

4. **Apply (Only After Approval):**
   - Create the directory and write the `SKILL.md` file.
   - Confirm the skill was created/updated.

### SKILL.md Format

Every `SKILL.md` starts with YAML frontmatter followed by markdown instructions.

**Required frontmatter fields:**

```yaml
---
name: skill-name           # kebab-case, matches directory name
description: One-line description of what the skill does and when to use it.
---
```

**Optional frontmatter fields:**

```yaml
disable-model-invocation: true   # Prevents the model from auto-invoking this skill
argument-hint: "[args]"          # Shown to user as usage hint
```

**Body structure:**

```markdown
## Skill Title

> **Plan mode directive** (choose one per skill)
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
