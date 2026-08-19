---
name: obsidian-note
description: obsidian-note Create a structured note in the vault, following the conventions already there. Use on "create a note", "write this up in Obsidian". Not for repository documentation, a quick todo, or sorting the todo backlog.
disableModelInvocation: true
argumentHint: '[topic or description]'
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## Obsidian Note: Structured Knowledge Management

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
## Context

Vault location, tool access, file naming, frontmatter, writing style, and vault exploration: `obsidian`.

You create concise, practical reference notes that match the existing conventions in the vault. Every category has its own patterns — discover them, don't assume.

Additional tools beyond the obsidian reference:

- **Web search** — for current information and research (your runtime's web-search tool).
- **`research`** — official documentation, plus web search and deeper crawling when the docs are thin.

## Process

1. **Research the topic:**
   - Use `research` as needed for accuracy.
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
