---
name: linear-initiative-create
description: Create a Linear initiative with a description and optional motivation/goals. Links relevant orphan projects to the new initiative. Use after a workspace skill (/linear-kilic or /linear-work) has been invoked.
interaction: chat
---

## system

### Linear Initiative Creation

> **PREREQUISITE: A Linear workspace skill MUST be active before this skill runs.**
>
> If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:
> - **kilic-dev workspace:** Load `~/.config/nvim/utils/agents/skills/linear-kilic/SKILL.md`
> - **Laravel workspace:** Load `~/.config/nvim/utils/agents/skills/linear-work/SKILL.md`
>
> Deduce the workspace from context: issue ID prefixes (K-xxx → kilic-dev, CLOUD-xxx → Laravel), Linear URLs, repository hosting (GitLab → kilic-dev, GitHub → Laravel), or ask the user if ambiguous.

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Use `EnterPlanMode` tool immediately.
> - Present the initiative draft to the user for approval before creating.
> - **NEVER exit plan mode.**

### Process

1. **Gather requirements** — discuss with the user what the initiative is about, why it exists, and what it aims to achieve.
2. **Draft the initiative** — prepare `name`, `summary`, `description`, and other fields. Present to the user.
3. **Iterate** based on user feedback until the user approves.
4. **Create the initiative** using `save_initiative`.
5. **Project matching** — after creation:
   - Fetch all projects using `list_projects`.
   - Identify projects that have **no initiative** attached.
   - Present any orphan projects that seem relevant to this initiative and ask the user which ones to link.
   - For approved matches, use `save_project` with `addInitiatives` to attach them.
6. **Present results** and wait for user direction.

### Initiative Fields

- **`name`** — Required. Concise and descriptive.
- **`summary`** — Required. Max 255 characters. A brief one-liner.
- **`description`** — Required. Following the structure below.
- **`owner`** — Set to the current user.
- **`status`** — Default to `Planned`. Ask the user if they want `Active` instead.
- **`targetDate`** — Discuss with the user. Set if they have a timeline, otherwise skip.
- **`parentInitiative`** — Ask the user if this belongs under an existing initiative. List current initiatives if needed.

### Description Structure

1. **Brief overview** (1-2 sentences) — what the initiative is about.
2. **## Motivation** (optional) — why this initiative exists. What problem, pain point, or opportunity triggered it.
3. **## Goals** (optional) — what we are trying to achieve. The desired end state or outcomes.

Keep it concise. Not every initiative needs Motivation and Goals as separate sections — use them when they add clarity beyond the overview.
