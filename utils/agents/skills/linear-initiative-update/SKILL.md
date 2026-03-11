---
name: linear-initiative-update
description: Revise a Linear initiative's description and review its project alignment. Use when user says "update the initiative", "review initiative alignment", or "revise initiative description". Requires a workspace skill (/linear-kilic or /linear-work). Do NOT use for creating initiatives (/linear-initiative-create).
interaction: chat
argument-hint: "[initiative-name or ID]"
---

## system

### Linear Initiative Update

> **PREREQUISITE: A Linear workspace skill MUST be active before this skill runs.**
>
> If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:
> - **kilic-dev workspace:** Load `~/.config/nvim/utils/agents/skills/linear-kilic/SKILL.md`
> - **Laravel workspace:** Load `~/.config/nvim/utils/agents/skills/linear-work/SKILL.md`
>
> Deduce the workspace from context: issue ID prefixes (K-xxx → kilic-dev, CLOUD-xxx → Laravel), Linear URLs, repository hosting (GitLab → kilic-dev, GitHub → Laravel), or ask the user if ambiguous.

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Fetch and review the initiative before proposing changes.
> - Present proposed changes to the user and get approval before applying.
> - **NEVER exit plan mode.**

### Core Principle

> **THE CONVERSATION IS MORE RECENT THAN THE INITIATIVE.**
>
> Initiative descriptions carry timestamps. The user's session knowledge and the current conversation context hold the most recent understanding of the initiative's intent. When the initiative's content is stale relative to the conversation, **treat the conversation as the source of truth** and update the initiative to match — always confirming with the user before applying.

### Process

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

### Description Structure

1. **Brief overview** (1-2 sentences) — what the initiative is about.
2. **## Motivation** (optional) — why this initiative exists.
3. **## Goals** (optional) — what we are trying to achieve.

Preserve sections that haven't changed. Only update what deviated.

### Key Rules

- **Never modify without user approval.**
- **Conversation context wins over stale initiative content.**
- **Always review project alignment** — this is not optional, it is a core part of the update workflow.
- **Be specific when flagging misalignment** — explain why a project no longer fits or why an orphan project does fit, referencing the updated goals.
