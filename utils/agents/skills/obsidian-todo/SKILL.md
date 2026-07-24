---
name: obsidian-todo
description: 'obsidian-todo Create quick todo notes for task tracking in Obsidian. Triggers: "add a todo", "remind me to", "jot this down". Do NOT use for structured notes (obsidian-note), repo docs (obsidian-repository), or triage (obsidian-triage).'
disableModelInvocation: true
argumentHint: "[task or thought to capture]"
references:
  - ../references/present-first.md
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## Obsidian Todo: Quick Capture & Task Tracking

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.
>
> - Read the `obsidian` reference for vault location and tool access — read the files listed in `references:` for the `obsidian-todo` skill.

> **Tool access:** Use the embedded `obsidian` MCP tools from the `obsidian` reference for all vault operations. Paths are vault-relative; filesystem is fallback only.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

## Context

You capture the user's unstructured thoughts, mumbling, and ideas into structured notes in `Todo/`. The user talks — you organize. Notes are **temporary working memory**, not permanent reference material.

When invoked alongside another skill (e.g., after a review, planning session, or debugging), append the conversation context and thought process from that session as an appendix to the note. Preserve the reasoning trail — decisions made, options considered, and why.

## File Naming & Frontmatter

> Read the `obsidian` reference for vault file naming and frontmatter conventions.

## Two Patterns

Choose based on what the user gives you:

### Simple Checklist

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

### Thought Dump

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

## Cross-Skill Appendix

When this skill is invoked from or alongside another skill session, add an appendix capturing the conversation context:

```markdown
## Appendix: Session Context

- **Origin:** [which skill/session triggered this — e.g., "review of cluster-kilic-chart skill"].
- **Key decisions:** [what was decided and why].
- **Alternatives considered:** [options that were rejected and reasoning].
- **Open threads:** [anything unresolved from the session].
```

## Writing Style

- **First person voice** — write as the user, not about the user.
- **Informal and conversational** — "I just want to...", "I tried to...".
- **Honest about uncertainty** — capture doubt, frustration, and "aha" moments.
- **Quick and unpolished** — get it down before the thought is lost.
- **Mix prose and bullets freely** — whatever fits.
- **Flat structure** — `##` headers only, no deep nesting.

## Related Skills

- **`obsidian-note`** — for creating structured reference notes. Auto-invoke when the content is better suited as a permanent reference note rather than a temporary todo.
- **`obsidian-triage`** — for processing and organizing accumulated todo notes. Do not auto-invoke.
