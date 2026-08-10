---
name: obsidian-note
description: 'obsidian-note Create structured notes in the Obsidian vault following existing conventions. Triggers: "create a note", "write it up in Obsidian". Do NOT use for repo docs (obsidian-repository), quick todos (obsidian-todo), or triage (obsidian-triage).'
disableModelInvocation: true
argumentHint: "[topic or description]"
references:
  - ../references/present-first.md
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## Obsidian Note: Structured Knowledge Management

Posture: `present-first`.
## Context

Vault location, tool access, file naming, frontmatter, writing style, and vault exploration: `obsidian`.

You create concise, practical reference notes that match the existing conventions in the vault. Every category has its own patterns — discover them, don't assume.

Additional tools beyond the obsidian reference:

- **Web search** — for current information and research (your runtime's web-search tool).
- **Context7** — for official documentation references.

## Process

1. **Research the topic:**
   - Use web search and Context7 as needed for accuracy.
   - Synthesize information into actionable guidance.

2. **Explore the vault:**
   - Follow the vault exploration steps in `obsidian`.

3. **Draft the note:**
   - Match the patterns discovered in step 2.
   - Present the full draft in chat per `output-diff`.
   - Iterate based on user feedback.

4. **Create the note:**
   - After approval, write the file in the correct category directory.

## Related Skills

- **`obsidian-repository`** — for documenting repository-specific knowledge in the Repositories vault folder. Auto-invoke when the note topic is about a development repository.
- **`obsidian-todo`** — for quick capture of tasks and thoughts. Auto-invoke when the user wants a quick note rather than a structured reference note.
