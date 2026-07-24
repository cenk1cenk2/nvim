---
name: linear-initiative-update
description: linear-initiative-update Revise a Linear initiative's description and review its project alignment. Use when user says "update the initiative", "review initiative alignment", or "revise initiative description". Requires a workspace skill (/linear-kilic or /linear-laravel). Do NOT use for creating initiatives (/linear-initiative-create) or for posting status updates (/linear-initiative-post).
argument-hint: "[initiative-name or ID]"
references:
  - ../references/linear-prerequisite.md
  - ../references/linear-description-structure.md
  - ../references/output-diff.md
  - ../references/present-first.md
  - ../references/linear-absolute-approval.md
---

## Linear Initiative Update

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> **Absolute approval required.** Read the `linear-absolute-approval` reference — initiative writes always require explicit approval for the specific change; the present-first blessing shortcut (`g` / `go` / autopilot) does NOT clear them. Never call `save_initiative` / `save_project` before the user approves the drafted change.

## Core Principle

> **THE CONVERSATION IS MORE RECENT THAN THE INITIATIVE.**
>
> Initiative descriptions carry timestamps. The user's session knowledge and the current conversation context hold the most recent understanding of the initiative's intent. When the initiative's content is stale relative to the conversation, **treat the conversation as the source of truth** and update the initiative to match — always confirming with the user before applying.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

## Process

1. **Fetch the initiative** using `get_initiative` with `includeProjects: true`.
2. **Check the timestamp** — note when the description was last updated. If stale, ask the user what has changed.
3. **Review the conversation** for deviations — changed goals, shifted priorities, new context, corrected assumptions.
4. **Draft updated description** — revise `name`, `summary`, `description`, `status`, `targetDate` as needed. Present changes to the user, highlighting what changed and why.
5. **Iterate** based on user feedback.
6. **Project alignment review** — after agreeing on the updated initiative description:
   - Fetch all projects using `list_projects`.
   - **Misaligned projects** — review projects currently linked to this initiative. If any no longer align with the updated goals, warn the user and recommend removal.
   - **Orphan candidates** — identify projects with no initiative that now fit the updated goals. Present them and ask the user which to link.
   - **Better fits** — if a linked project would fit better under a different initiative, suggest the move.
7. **Apply approved changes:**
   - Update the initiative using `save_initiative` with the initiative `id`.
   - For project linking/unlinking, use `save_project` with `addInitiatives` or `removeInitiatives`.
8. **Present results** and wait for user direction.

## Description Structure

> Read the `linear-description-structure` reference for the initiative description format.

Preserve sections that haven't changed. Only update what deviated.

## Key Rules

- **Never modify without explicit, per-change user approval** — see the `linear-absolute-approval` reference; no blessing/autopilot shortcut applies.
- **Conversation context wins over stale initiative content.**
- **Always review project alignment** — this is not optional, it is a core part of the update workflow.
- **Be specific when flagging misalignment** — explain why a project no longer fits or why an orphan project does fit, referencing the updated goals.
