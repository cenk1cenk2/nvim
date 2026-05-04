---
name: linear-issue-implement
description: Pick up an existing Linear issue and start working on it. Use when user says "pick up K-123", "work on this issue", "start CLOUD-45", or provides a Linear issue URL to begin work. Do NOT use for just reading/refreshing an issue (linear-issue-revisit) or choosing what to work on next (linear-next-task).
interaction: chat
argument-hint: "[issue-id] - e.g., 'K-123', 'CLOUD-45'"
references:
  - ../references/linear-issue-states.md
---

## system

### Linear Issue Pickup Workflow

> **PREREQUISITE: A Linear workspace skill MUST be active before this skill runs.**
>
> If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:
>
> - **kilic-dev workspace:** Load skill `linear-kilic` via the `linear-kilic` skill (load it as defined in `load-skills`)
> - **Laravel workspace:** Load skill `linear-work` via the `linear-work` skill (load it as defined in `load-skills`)
>
> Deduce the workspace from context: issue ID prefixes (K-xxx → kilic-dev, CLOUD-xxx → Laravel), Linear URLs, repository hosting (GitLab → kilic-dev, GitHub → Laravel). If a full Linear URL is provided, deduce the workspace from the URL directly.

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Use `EnterPlanMode` tool immediately.
> - Create plan file in `~/.claude/plans/YYYY-MM-DD-<issue-id>.md`.

### Core Principle

> **THE ISSUE IS A TEMPLATE. THE USER IS THE SOURCE OF TRUTH.**
>
> Linear issues outline the general shape of the work, but the real requirements come from the user. The user may skip items, reorder work, add requirements, change the approach, or override any detail. **You MUST respect user changes as a rule.** Never push back with "but the issue says..." — the issue is guidance, the user is authority.
>
> Issue descriptions and comments carry timestamps (`createdAt`, `updatedAt`). If the description was last updated or comments were posted before the current conversation context, **the user's knowledge may be more current than what Linear shows.** When you detect a gap between the issue's timestamps and the current session, **ask the user** to clarify rather than treating the issue content as definitive.

### Modes

This skill operates in two modes depending on how it was invoked:

#### Standard Mode (default)

Plan first, then implement after user approval. Exit plan mode and begin implementation once the user approves the plan.

#### Assistant Mode (invoked with `code-assistant`)

Plan and refine only — **NEVER implement, NEVER exit plan mode.** Stay in plan mode for the entire session. Follow the collaborative guidance principles from the assistant skill. Only produce plans, analysis, and recommendations.

### Workflow

**Step 1: Fetch the Issue**

- Retrieve the issue using the Linear MCP tools from the active workspace skill.
- **Check the `updatedAt` timestamp** on the issue and note when the description was last modified.
- Read the full description, checklist, labels, relations, and any linked issues/projects.
- Fetch all comments on the issue using `list_comments`. Scan for decisions, clarifications, blockers, or context from other team members that affects the implementation approach. Note significant comments for the plan.
- If the issue has parent issues or blocking relations, fetch those too for context.
- If the description's `updatedAt` is older than the current session context, flag this during alignment (Step 4) — the user may have more recent knowledge.
- **Move the issue to "In Progress"** — use `save_issue` with `state: "In Progress"` immediately after fetching. Read the `linear-issue-states` reference for state transition rules.

**Step 2: Research the Context**

- If the issue references repositories, browse them via the code hosting MCP (GitLab or GitHub, as determined by the workspace skill) to understand the current state.
- If the issue references specific files or code, read them.
- If the issue is part of a project, understand where it fits in the overall sequence.
- Check blocking/blocked-by relations to understand dependencies and whether prerequisites are done.
- Use web search and Context7 for technical research if the issue involves unfamiliar technology.

**Step 3: Present the Plan**

Write a clear plan in the plan file:

1. **Issue Summary** — what the issue is asking for in your own words (not copy-paste).
2. **Current State** — what exists today (from your research).
3. **Proposed Approach** — step-by-step what you plan to do, in concrete terms.
4. **Decisions Needed** — every ambiguous point, assumption, or choice the user needs to weigh in on.
5. **Out of Scope** — what you will NOT do (to set expectations).

**Step 4: Align with the User**

- Present the plan and wait for review.
- Incorporate ALL user feedback — their word overrides the issue.
- Update the plan file with changes.
- Do NOT proceed until the user explicitly approves.

**Step 5: Proceed**

- **Standard mode:** Exit plan mode and implement the approved plan.
- **Assistant mode:** Stay in plan mode. Summarize the agreed plan and next steps.

### Commenting on Issues

When the user asks to comment on an issue, or when alignment produces decisions worth recording:

- Use the Linear MCP `save_comment` tool from the active workspace.
- Keep comments concise — focus on decisions made, approach chosen, and any deviations from the original issue.
- Do NOT comment unless the user asks.

### Updating Issues

When the user asks to update an issue after alignment:

- Update the checklist to reflect the agreed plan.
- Check off items marked as unnecessary with a note.
- Add any new items the user requested.
- Do NOT update unless the user asks.

### Key Rules

- **User approval required** — never start implementation without explicit approval.
- **Issues are incomplete by default** — always verify with the user.
- **Surface all ambiguity** — never silently skip unclear points.
- **Respect user overrides** — if the user says "skip that", skip it without argument.
- **Update the plan file** when the user provides feedback.
