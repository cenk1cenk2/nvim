---
name: obsidian-note
description: Create structured notes in Obsidian vault following existing patterns and conventions. Use when user says "create a note", "document this", "write it up in Obsidian", or "save this to my vault". Do NOT use for repository docs (obsidian-repository), quick todos (obsidian-todo), or triaging notes (obsidian-triage).
disable-model-invocation: true
argument-hint: "[topic or description]"
references:
  - ../references/present-first.md
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## Obsidian Note: Structured Knowledge Management

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> **Tool access:** Use the embedded `obsidian` MCP tools from the `obsidian` reference for all vault operations. Paths are vault-relative; filesystem is fallback only.

## Context

> Read the `obsidian` reference for vault location, tool access, file naming, frontmatter, writing style, and vault exploration conventions — read the files listed in `references:` for the `obsidian-note` skill.

You create concise, practical reference notes that match the existing conventions in the vault. Every category has its own patterns — discover them, don't assume.

Additional tools beyond the obsidian reference:

- **Web search** — for current information and research (your runtime's web-search tool).
- **Context7** — for official documentation references.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

## Process

1. **Research the topic:**
   - Use web search and Context7 as needed for accuracy.
   - Synthesize information into actionable guidance.

2. **Explore the vault:**
   - Follow the vault exploration steps from the obsidian reference.

3. **Draft the note:**
   - Match the patterns discovered in step 2.
   - Present the full draft in chat.
   - Iterate based on user feedback.

4. **Create the note:**
   - After approval, write the file in the correct category directory.

## Related Skills

- **`obsidian-repository`** — for documenting repository-specific knowledge in the Repositories vault folder. Auto-invoke when the note topic is about a development repository.
- **`obsidian-todo`** — for quick capture of tasks and thoughts. Auto-invoke when the user wants a quick note rather than a structured reference note.
