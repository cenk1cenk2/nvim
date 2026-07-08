---
name: linear-project-post
description: Draft a project update post for a Linear project by analyzing recent progress, deviations, and next steps. Use when user says "write a project update", "post a status update", "summarize project progress", or "draft a project post". Do NOT use for modifying project structure (/linear-project-update).
argument-hint: "[project-name or Linear URL]"
references:
  - ../references/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/present-first.md
---

## Linear Project Update Post

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Prerequisite

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

## Process

1. **Fetch the project issues** using `list_issues` with the `project` parameter (do NOT use `get_project` or `list_projects` — they have complexity limits).
2. **Fetch prior project updates** using `get_status_updates` to establish the baseline — what was the last update, what was communicated, what was the state at that point.
3. **Analyze the last update** — identify the cutoff point. Everything after this update is "recent" for the purpose of the new post.
4. **Check timestamps** — use `updatedAt` on issues and `createdAt` on comments to build an accurate timeline of what happened since the last update. If timestamps suggest the user's session knowledge may be more recent than what's recorded in Linear, ask the user to fill in gaps before drafting.
5. **Categorize issues** by status from the `list_issues` response.
6. **Investigate completed issues since the last update** — these form the first paragraph. Understand what was accomplished, not just the issue titles. Read descriptions if needed to summarize the work meaningfully.
7. **Investigate cancelled or descoped issues since the last update** — these form the deviations section. Summarize why they were dropped or changed in a concise manner.
8. **Investigate in-progress and upcoming issues** — identify the immediate next steps for the closing sentence(s).
9. **Draft the update post** following the format below.
10. **Present the draft to the user.** Iterate based on feedback.
11. **Post only after explicit user approval** using the `save_status_update` tool.

## Post Format

The update should read as a cohesive narrative, not a bullet list. Write in plain prose — short paragraphs, no headers, no markdown formatting.

**Structure:**

1. **What was accomplished** (1-3 sentences) — summarize completed work since the last update. Focus on outcomes and milestones, not individual tasks.
2. **Deviations** (1-2 sentences, only if applicable) — briefly note any cancelled work, changed approach, or unexpected challenges. Skip this section entirely if there are no deviations.
3. **Next steps** (1-2 sentences) — what is immediately ahead based on in-progress or next-up issues.

**Tone:**

- Professional but concise — this is a status update, not a report.
- Focus on what matters to stakeholders — outcomes over implementation details.
- Be honest about challenges without being alarmist.
- Use past tense for completed work, future tense for next steps.

## Example

> The cache operator has been deployed to the development instance, and traffic has been cut over to the new gateway. This week, we completed the implementation of the messaging operator and prepared it for deployment. Traffic will be cut over to the new gateway on the development instance starting next week. The migration documentation has also been prepared with a straightforward rollback mechanism in place.
>
> While there are minor differences between the old and new gateway operations, we have not encountered any significant challenges to date.
>
> The next steps are to standardize monitoring to match our current setup and update the dashboards to support both gateways.

## Key Rules

- **Never post without user approval.**
- **Never exit plan mode.**
- **Read prior updates first** — the post must build on the last update, not repeat it.
- **Keep it concise** — a good update is 3-6 sentences, not a wall of text.
- **No bullet lists or markdown** — plain prose paragraphs only.
- **Skip the deviations section** if there are none — don't force it.
