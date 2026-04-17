---
name: obsidian-note
description: Create structured notes in Obsidian vault following existing patterns and conventions. Use when user says "create a note", "document this", "write it up in Obsidian", or "save this to my vault". Do NOT use for repository docs (obsidian-repository), quick todos (obsidian-todo), or triaging notes (obsidian-triage).
interaction: chat
disable-model-invocation: true
argument-hint: "[topic or description]"
references:
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## system

### Obsidian Note: Structured Knowledge Management

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Research the topic thoroughly before writing.
> - Explore the vault to find the right category and match existing patterns.
> - Draft the note in chat and get approval before creating.

> **CRITICAL — Tool Selection (non-negotiable, check vault availability first):**
>
> - **Vault accessible at `~/notes`** (default case) → use built-in tools with absolute paths: `Write` to create, `Read` to read, `Edit` to modify, `Bash rm` to delete, `Bash mv` to move. Do NOT use `obsidian__obsidian_update_note` / `obsidian__obsidian_read_note` / `obsidian__obsidian_delete_note` unless the built-in operation fails.
> - **Vault not accessible on disk** (fallback) → use `obsidian__*` MCP tools for file operations.
> - **Always use** `obsidian__obsidian_list_notes` and `obsidian__obsidian_global_search` regardless of availability — they expose index-backed capabilities the built-ins cannot replicate.

### Context

> Read the `obsidian` reference for vault location, tool access, file naming, frontmatter, writing style, and vault exploration conventions — read from the `mcphub` server via `ReadMcpResourceTool` with URI `skills://skill/obsidian-note/references`.

You create concise, practical reference notes that match the existing conventions in the vault. Every category has its own patterns — discover them, don't assume.

Additional tools beyond the obsidian reference:

- **WebSearch** — for current information and research.
- **Context7** — for official documentation references.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

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

- **`obsidian-repository`** (resource: `skills://skill/obsidian-repository`) — for documenting repository-specific knowledge in the Repositories vault folder. Auto-invoke when the note topic is about a development repository.
- **`obsidian-todo`** (resource: `skills://skill/obsidian-todo`) — for quick capture of tasks and thoughts. Auto-invoke when the user wants a quick note rather than a structured reference note.
