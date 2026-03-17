---
name: obsidian-triage
description: Process todo notes in Obsidian vault. Organizes, moves, renames, or removes notes interactively. Use when user says "triage my notes", "clean up todos", or "organize the Todo folder". Do NOT use for creating notes (/obsidian-note), repository docs (/obsidian-repository), or adding todos (/obsidian-todo).
interaction: chat
disable-model-invocation: true
references:
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## system

### Obsidian Triage

> **DO NOT enter plan mode.** This is an interactive, note-by-note workflow driven by user decisions.

> **CRITICAL — Tool Selection (non-negotiable, check CWD first):**
>
> - **CWD is `~/notes`** → use built-in tools: `Write` to create, `Read` to read, `Edit` to modify, `Bash rm` to delete, `Bash mv` to move. Do NOT use `obsidian__obsidian_update_note` or `obsidian__obsidian_read_note` or `obsidian__obsidian_delete_note`. Fall back to obsidian MCP only if the built-in tool is unavailable.
> - **CWD is NOT `~/notes`** → use `obsidian__*` MCP tools.
> - **Always use** `obsidian__obsidian_list_notes` and `obsidian__obsidian_global_search` regardless of CWD.

### Context

> Read the `obsidian` reference for vault location, tool access, file naming, frontmatter, and writing style conventions — resolve references from the `<References>` block via `skills__read_reference`.

Todo notes in `Todo/` are quick captures — timestamped files with rough thoughts, checklists, and brain dumps. Over time they accumulate. This skill processes them one by one: organizing relevant notes into proper vault categories (like `/obsidian-note` would), flagging stale or completed notes for removal, and refining what remains.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

### Process

#### Step 1: Fetch Todo Notes

- List all files in `Todo/`.
- Read each note to understand its content.
- Group notes by apparent theme or category if patterns emerge.

#### Step 2: Explore the Vault

- List top-level vault directories to understand available categories.
- Keep the category list available throughout the session for placement recommendations.

#### Step 3: Present Overview

Present the todo queue to the user:

- Total number of notes in `Todo/`.
- Grouping by theme if patterns are visible.
- Any notes that look obviously stale, completed, or empty.
- Ask the user if they want to process all notes or focus on a specific group.

#### Step 4: Process Each Note

For each note, present its content summary and recommend one of:

1. **Move** — the note has lasting value and belongs in a proper vault category.
   - Recommend a target category based on the vault structure.
   - Propose a kebab-case filename (replacing the timestamp name).
   - Propose updated frontmatter following the target category's conventions (read 1-2 existing notes in that category if not already familiar with its patterns).
   - Propose restructured content to match the category's style — following the same approach as `/obsidian-note` (`~/.config/nvim/utils/agents/skills/obsidian-note/SKILL.md`): concise, practical, flat `##` structure.
   - Present the full proposed note for approval before writing.

2. **Keep** — the note is still an active todo and should stay in `Todo/`.
   - Optionally suggest refinements: clearer alias, better structure, completed items checked off.
   - If refinements are proposed, present them for approval.

3. **Remove** — the note is stale, completed, or no longer relevant.
   - Explain why you think it can be removed.
   - **Only remove after explicit user confirmation.**

**Present recommendations one note at a time.** Example:

```
### Todo/20260215T091422.md — "Migrate CI pipelines to GitLab"

Content: Checklist of 5 items, 4 already checked. Last item is "update docs".

**Recommendation:** Remove — 4/5 items done, remaining item is minor.
Alternatively: move to DevOps/ as `gitlab-ci-migration.md` if you want to keep the reference.

What would you like to do?
```

Wait for the user to decide before proceeding to the next note.

#### Step 5: Apply Changes

For each accepted action:

- **Move:** Delete the old file from `Todo/`, create the new file in the target category with the proposed name, frontmatter, and content.
- **Keep:** Update the note in place if refinements were approved.
- **Remove:** Delete the note.

#### Step 6: Summary

After processing all notes (or when the user stops):

- How many notes were moved, kept, removed, and skipped.
- Which categories received new notes.
- How many remain in `Todo/`.

### Key Rules

- **One note at a time** — present, wait for user response, then proceed.
- **Always get confirmation** — never move, rename, or delete without the user saying so.
- **Match category conventions** — when moving a note, read existing notes in the target category to match frontmatter, structure, and style. Do not assume a fixed template.
- **Not everything moves** — some todos are ephemeral and belong in `Todo/` until done. Do not force every note into a category.
- **Stale is not obvious** — a note from 3 months ago might still be relevant. Present your reasoning but let the user decide.
- **Preserve intent** — when restructuring content for a new category, keep the user's original meaning and voice. Do not add information that wasn't there.
