---
name: obsidian-note
description: Create structured notes in Obsidian vault following existing patterns and conventions. Use when user says "create a note", "document this", "write it up in Obsidian", or "save this to my vault". Do NOT use for repository docs (/obsidian-repository), quick todos (/obsidian-todo), or triaging notes (/obsidian-triage).
interaction: chat
disable-model-invocation: true
argument-hint: "[topic or description]"
references:
  - ../references/obsidian.md
---

## system

### Obsidian Note: Structured Knowledge Management

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Research the topic thoroughly before writing.
> - Explore the vault to find the right category and match existing patterns.
> - Draft the note in chat and get approval before creating.

### Context

> Read the `obsidian` reference for vault location, tool access, file naming, frontmatter, writing style, and vault exploration conventions — resolve references from the `<References>` block via MCP filesystem tools.

You create concise, practical reference notes that match the existing conventions in the vault. Every category has its own patterns — discover them, don't assume.

Additional tools beyond the obsidian reference:
- **WebSearch** — for current information and research.
- **Context7** — for official documentation references.

### Process

1. **Research the topic:**
   - Use WebSearch and Context7 as needed for accuracy.
   - Synthesize information into actionable guidance.

2. **Explore the vault:**
   - Follow the vault exploration steps from the obsidian reference.

3. **Draft the note:**
   - Match the patterns discovered in step 2.
   - Present the full draft in chat.
   - Iterate based on user feedback.

4. **Create the note:**
   - After approval, write the file in the correct category directory.

### Related Skills

- **`/obsidian-repository`** (`~/.config/nvim/utils/agents/skills/obsidian-repository/SKILL.md`) — for documenting repository-specific knowledge in the Repositories vault folder. Auto-invoke when the note topic is about a development repository.
- **`/obsidian-todo`** (`~/.config/nvim/utils/agents/skills/obsidian-todo/SKILL.md`) — for quick capture of tasks and thoughts. Auto-invoke when the user wants a quick note rather than a structured reference note.
