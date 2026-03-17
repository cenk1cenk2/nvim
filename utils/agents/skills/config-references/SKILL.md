---
name: config-references
description: Create, update, or review reference files in the skills directory. Use when user says "create a reference", "add a reference", "update reference X", "review references", or "extract this to a reference". Do NOT use for skills themselves (use /config-skills) or loading skills (use /load-skills).
interaction: chat
references:
  - ../references/output-diff.md
argument-hint: "[create|update|review] [reference-name] [description or context]"
---

## system

### Reference Management

> **ALWAYS enter plan mode for this prompt.**
>
> - Present findings, drafts, or proposed changes to the user.
> - Iterate based on feedback.
> - Do NOT write files until the user explicitly approves the plan.

> Read the `output-diff` reference for chunked change presentation — show reasoning + content blocks for each proposed reference change before writing.

### Reference Directory Structure

References live in two locations under `~/.config/nvim/utils/agents/skills/`:

- `references/` — shared references consumed by multiple skills.
- `<skill-name>/references/` — skill-specific references consumed only by that skill.

### Reference Format

Reference files are plain markdown. They do NOT have YAML frontmatter — only skills have frontmatter. Start with a `# Title` heading, then sections as needed.

**Structure:**

```
# <Reference Name>

<1-2 sentence description of what this reference covers and when to read it.>

## <Section>

<Content — conventions, rules, patterns, examples.>
```

### Process

#### Create

1. Determine the scope — **shared** or **skill-specific**.
   - Shared: the content applies to 2+ skills or is a general convention.
   - Skill-specific: the content supports only one skill and would clutter its SKILL.md.
2. If shared, check existing references via `skills__list_references` to avoid duplication.
3. If skill-specific, read the parent skill via `skills__read_skill` to understand context.
4. Name the file:
   - Shared: `<family>-<topic>.md` (e.g., `linear-prerequisite.md`, `scm-detect.md`).
   - Skill-specific: `<topic>.md` inside `<skill-name>/references/`.
5. Draft the reference content following the format above.
6. Identify which skills should declare this reference in their frontmatter.
7. Present the draft and the list of skills to update.
8. After approval, write the file and update skill frontmatter as needed.

#### Update

1. Read the existing reference via `skills__read_reference`.
2. Read skills that declare it — search for the filename in skill frontmatter to understand consumers.
3. Identify what needs to change based on conversation context.
4. Present proposed changes using diff format.
5. After approval, apply changes.
6. If the update changes the reference's scope or contract, notify about affected skills.

#### Review

1. List all references via `skills__list_references`.
2. For each reference (or a specific one if requested):
   - Read its content.
   - Check which skills declare it in their frontmatter.
   - Identify orphaned references (declared by no skill).
   - Identify stale content (conventions that no longer apply).
   - Check for duplication across references.
3. Present findings and propose improvements.

### Naming Conventions

| Type | Pattern | Examples |
|------|---------|----------|
| Family shared | `<family>-<topic>.md` | `linear-prerequisite.md`, `scm-github.md` |
| Cross-family shared | `<topic>.md` | `output-diff.md`, `plan-mode.md` |
| Skill-specific | `<topic>.md` in `<skill>/references/` | `./references/template.md` |

### Key Principles

- References are **progressive disclosure** — keep them focused on one topic.
- A reference should be **self-contained** — readable without loading other references.
- **No frontmatter** — only skills have YAML frontmatter.
- **No workflow steps** — references contain conventions and patterns, not process instructions.
- After creating or updating a shared reference, always check if skills need their `references:` frontmatter updated.
