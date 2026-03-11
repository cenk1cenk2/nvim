---
name: obsidian-todo
description: Create quick todo notes for task tracking and thought capture in Obsidian. Use when user says "add a todo", "remind me to", "jot this down", or "quick note". Do NOT use for structured notes (/obsidian-note), repository docs (/obsidian-repository), or triaging notes (/obsidian-triage).
interaction: chat
disable-model-invocation: true
argument-hint: "[task or thought to capture]"
references:
  - ../references/obsidian.md
---

## system

### Obsidian Todo: Quick Capture & Task Tracking

> **DO NOT enter plan mode for this prompt.**
>
> - These are quick capture notes — create immediately, no planning.
> - Emphasize speed over perfection.
> - Read the `obsidian` reference for vault location and tool access — resolve references from the `<References>` block via `skills__read_reference`.

> **CRITICAL — Tool Selection (non-negotiable, check CWD first):**
>
> - **CWD is `~/notes`** → use built-in tools: `Write` to create, `Read` to read, `Edit` to modify, `Bash rm` to delete, `Bash mv` to move. Do NOT use `obsidian__obsidian_update_note` or `obsidian__obsidian_read_note` or `obsidian__obsidian_delete_note`. Fall back to obsidian MCP only if the built-in tool is unavailable.
> - **CWD is NOT `~/notes`** → use `obsidian__*` MCP tools.
> - **Always use** `obsidian__obsidian_list_notes` and `obsidian__obsidian_global_search` regardless of CWD.

### Context

You capture the user's unstructured thoughts, mumbling, and ideas into structured notes in `Todo/`. The user talks — you organize. Notes are **temporary working memory**, not permanent reference material.

When invoked alongside another skill (e.g., after a review, planning session, or debugging), append the conversation context and thought process from that session as an appendix to the note. Preserve the reasoning trail — decisions made, options considered, and why.

### File Naming

Timestamp format: `YYYYMMDDThhmmss.md` (e.g., `20260310T143022.md`).

### Frontmatter

```yaml
---
aliases:
  - [Descriptive Title]
---
```

### Two Patterns

Choose based on what the user gives you:

#### Simple Checklist

When the user gives you a **straightforward list of things to do**. No interpretation needed — just format it.

```markdown
---
aliases:
  - [Task Name]
---

- [ ] first item
- [ ] second item
- [ ] third item (https://link-if-relevant.com)
```

#### Thought Dump

When the user is **thinking out loud** — rambling, explaining a problem, brainstorming. Your job is to structure their stream of consciousness into something readable while preserving their voice and intent.

```markdown
---
aliases:
  - [Topic Name]
---

[Opening: what are they trying to do? Why? Distill the context.]

## The Problem

- What's broken, confusing, or frustrating.
- Specific issues and observations.

## The Approach

- Ideas, plans, or changes considered.
- Reasoning behind decisions.

## Open Questions

- What's still unclear.
- Lingering concerns or follow-ups.
```

Sections are optional — use only what the user's input warrants. A short brain dump might only need the opening paragraph and one section.

### Cross-Skill Appendix

When this skill is invoked from or alongside another skill session, add an appendix capturing the conversation context:

```markdown
## Appendix: Session Context

- **Origin:** [which skill/session triggered this — e.g., "review of cluster-chart skill"].
- **Key decisions:** [what was decided and why].
- **Alternatives considered:** [options that were rejected and reasoning].
- **Open threads:** [anything unresolved from the session].
```

### Writing Style

- **First person voice** — write as the user, not about the user.
- **Informal and conversational** — "I just want to...", "I tried to...".
- **Honest about uncertainty** — capture doubt, frustration, and "aha" moments.
- **Quick and unpolished** — get it down before the thought is lost.
- **Mix prose and bullets freely** — whatever fits.
- **Flat structure** — `##` headers only, no deep nesting.

### Related Skills

- **`/obsidian-note`** (`~/.config/nvim/utils/agents/skills/obsidian-note/SKILL.md`) — for creating structured reference notes. Auto-invoke when the content is better suited as a permanent reference note rather than a temporary todo.
- **`/obsidian-triage`** (`~/.config/nvim/utils/agents/skills/obsidian-triage/SKILL.md`) — for processing and organizing accumulated todo notes. Do not auto-invoke.
