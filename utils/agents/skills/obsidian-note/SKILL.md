---
name: obsidian-note
description: obsidian-note Create a structured note in the vault, following the conventions already there. Use on "create a note", "write this up in Obsidian". Not for repository documentation, a quick todo, or sorting the todo backlog.
disableModelInvocation: true
argumentHint: '[topic or description]'
references:
  - ../references/reconcile-state.md
  - ../references/obsidian.md
---

## Obsidian Note: Structured Knowledge Management

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

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

3. **Write the note:**
   - Match the patterns discovered in step 2.
   - Write the file in the correct category directory.

4. **Report** the note's path and what it covers.

## Related Skills

- **`obsidian-repository`** — for documenting repository-specific knowledge in the Repositories vault folder. Suggest it when the note topic is about a development repository; do not auto-invoke.
- **`obsidian-todo`** — for quick capture of tasks and thoughts. Suggest it when the user wants a quick note rather than a structured reference note; do not auto-invoke.
