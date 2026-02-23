---
name: note
description: Create structured notes in Obsidian vault following existing patterns and conventions. Use for documentation, reference notes, and knowledge management.
disable-model-invocation: true
argument-hint: "[topic or description]"
---

## Obsidian Note-Taking Mode: Structured Knowledge Management

> **IMPORTANT: ALWAYS enter plan mode when this prompt is invoked.**
>
> - Use `EnterPlanMode` tool immediately
> - Create plan file in `~/.claude/plans/YYYY-MM-DD-<project>-<name>.md`
> - Use plan file to organize research and structure note content
> - Research thoroughly using web search and Context7 for accuracy

### Context

You are working in an Obsidian vault at `~/notes` with established note categories and formatting conventions. Your role is to create concise, practical notes that match the existing patterns in the vault.

### Process

1. **Check for Existing Templates:**
   - First, check the `Templates/` directory for applicable templates
   - Available templates: Daily.md (kanban board), Card.md (timestamped cards)
   - Use existing templates when they match the note type

2. **Understand the Vault Structure:**
   - Main categories: Calendar (Day/Week), Code, Work, Infrastructure, Personal, Todo, Templates
   - Code notes: Organized hierarchically (Database/MySQL, Linux/Archlinux, Gitlab, etc.)
   - Work notes: Project-specific subdirectories (Laravel/, etc.)
   - Calendar notes: Day/ and Week/ subdirectories with different formats
   - Infrastructure: Deep hierarchy by provider/technology

3. **Analyze Existing Notes in Target Category:**
   - Read 2-3 representative notes from the category where the new note will go
   - Observe frontmatter fields used (aliases, tags, bookmarks, timestamp)
   - Note heading structure (## vs # usage)
   - Check for code blocks, checklists, or special formatting
   - Identify the level of detail and conciseness

4. **Determine Note Category and Placement:**
   - Code/: Technical how-tos, quick references, command guides
   - Work/: Project tracking, environment URLs, rollout checklists
   - Calendar/Day/: Kanban boards for daily task management
   - Calendar/Week/: Research notes and weekly summaries
   - Infrastructure/: Technical documentation and configuration guides
   - Todo/: Checkbox-based tracking lists

5. **Create the Note Following Vault Conventions:**
   - Use concise, action-oriented writing (not verbose explanations)
   - Match frontmatter structure from similar notes
   - Follow category-specific formatting patterns
   - Use markdown links `[text](url)` for external references
   - Include code blocks with language identifiers where appropriate
   - Keep it practical and reference-focused

### Frontmatter Patterns

**Standard pattern (most notes):**

```yaml
---
aliases:
  - [Descriptive Title]
---
```

**With optional fields:**

```yaml
---
aliases:
  - [Descriptive Title]
tags:
  - tag1
bookmarks:
  - https://reference-url.com
---
```

**Card template (timestamped):**

```yaml
---
timestamp: "{{date:YYYY-MM-DD}}T{{time:HH:mm}}"
tags:
contacts:
---
```

**Daily kanban board:**

```yaml
---
kanban-plugin: board
---
```

### Category-Specific Patterns

**Code/ notes:**

- Use `aliases:` in frontmatter with descriptive title
- Structure with ## headers for different operations/commands
- Heavy use of code blocks with language identifiers (`bash, `python, etc.)
- Minimal prose - focus on commands and practical steps
- Example structure:

  ````markdown
  ---
  aliases:
    - Quick Reference Name
  tags:
    - category
  ---

  ## To Do Operation X

  ```bash
  command here
  ```
  ````

  ## To Do Operation Y

  ```bash
  another command
  ```

  ```

  ```

**Work/ notes:**

- Project-specific content with URLs and tracking
- Use checklists for rollouts: `- [x]` and `- [ ]`
- Environment URLs grouped by region/environment
- Keep it organized and scannable

**Calendar/Day/ notes:**

- Use Daily.md template (kanban board)
- Structure: ## Open, ## In Progress, ## Verify, ## Done
- Tag support: #support, #bug, #meeting, #issue, #hold

**Calendar/Week/ notes:**

- Use H1 with date-topic format: `# YYYY-WW-topic-name`
- Longer-form research notes with links and explanations
- Include repository links, documentation references
- More prose than Code notes, but still concise

**Infrastructure/ notes:**

- Technical documentation with external links
- Configuration guides and procedures
- Use `bookmarks:` frontmatter for reference URLs
- Include links to consoles, documentation, registries

### File Naming Conventions

- **Code, Work, Infrastructure**: kebab-case descriptive names
  - `wireplumber-source-selection.md`
  - `gitlab-ci-token-configuration.md`
  - `testing-applications.md`

- **Calendar/Day**: YYYY-MM-DD.md or YYYY-MM-DD-topic.md
  - `2026-01-19.md`
  - `2024-10-24-rmq-salt-stack.md`

- **Calendar/Week**: YYYY-WW.md or YYYY-WW-topic.md
  - `2024-38.md`
  - `2024-38-aiven-metrics.md`

### Content Style Guidelines

**DO:**

- Keep it concise and action-oriented
- Use practical examples and commands
- Include code blocks with language identifiers
- Use markdown links `[text](url)` for external references
- Structure with clear ## headers for different sections
- Focus on "how to do X" rather than "explanation of X"
- Use checklists for tracking tasks
- Add `bookmarks:` frontmatter for important reference URLs

**DON'T:**

- Write verbose explanations
- Use wikilinks `[[page]]` - this vault uses markdown links
- Over-emphasize internal linking between notes
- Add unnecessary metadata fields
- Create deeply nested heading hierarchies
- Include theoretical background unless essential

### Research and Accuracy

- Use WebSearch for current information when needed
- Use Context7 for official documentation references
- Verify commands and configurations before including
- Cross-reference with existing notes for consistency
- Synthesize information into actionable guidance

### Tools to Use

- **Obsidian MCP tools** - For reading, creating, and managing notes
- **WebSearch** - For current information and research
- **Context7** - For official documentation references
- **Grep/Glob** - For finding similar notes and patterns in the vault

### Key Principles

- **Concise and practical** - This vault is a reference system, not a knowledge base
- **Match existing patterns** - Consistency over personal preference
- **Action-oriented** - Focus on what to do, not explanations
- **External-focused** - Links to docs, repos, tools; light internal linking
- **Template-aware** - Check Templates/ directory first
- **Category-specific** - Different categories have different conventions
