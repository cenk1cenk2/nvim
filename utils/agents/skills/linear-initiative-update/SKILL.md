---
name: linear-initiative-update
description: linear-initiative-update Revise a Linear initiative's description and review whether its projects still belong to it. A Linear workspace skill must be active first. Use on "update the initiative", "revise the initiative description". Not for creating one, or for posting its status.
argumentHint: '[initiative name or ID]'
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear-prerequisite.md
  - ../references/linear-description-structure.md
  - ../references/output-diff.md
  - ../references/linear-absolute-approval.md
---

## Linear Initiative Update

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill must be active first — detection rules in `linear-prerequisite`.

> **⛔ Absolute approval required per `linear-absolute-approval`.** Initiative writes always require explicit approval for the specific change; an upfront blessing (`g` / `go` / autopilot) does NOT clear them. Never call `save_initiative` / `save_project` before the user approves the drafted change.

## Core Principle

> **THE CONVERSATION IS MORE RECENT THAN THE INITIATIVE.**
>
> Initiative descriptions carry timestamps. The user's session knowledge and the current conversation context hold the most recent understanding of the initiative's intent. When the initiative's content is stale relative to the conversation, **treat the conversation as the source of truth** and update the initiative to match — always confirming with the user before applying.

## Process

1. **Fetch the initiative** using `get_initiative` with `includeProjects: true`.
2. **Check the timestamp** — note when the description was last updated. If stale, ask the user what has changed.
3. **Review the conversation** for deviations — changed goals, shifted priorities, new context, corrected assumptions.
4. **Draft updated description** — revise `name`, `summary`, `description`, `status`, `targetDate` as needed. Present changes to the user in logical chunks per `output-diff`, highlighting what changed and why.
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

Initiative description format per `linear-description-structure`.

Preserve sections that haven't changed. Only update what deviated.

## Key Rules

- **Never modify without explicit, per-change user approval** — per `linear-absolute-approval`; no blessing/autopilot shortcut applies.
- **Conversation context wins over stale initiative content.**
- **Always review project alignment** — this is not optional, it is a core part of the update workflow.
- **Be specific when flagging misalignment** — explain why a project no longer fits or why an orphan project does fit, referencing the updated goals.
