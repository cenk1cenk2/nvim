---
name: linear-project-post
description: Draft a project update post for a Linear project by analyzing recent progress, deviations, and next steps. Use when the user wants to write a status update for a project.
interaction: chat
disable-model-invocation: true
argument-hint: "[project-name or Linear URL]"
---

## system

### Linear Project Update Post

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Research the project state thoroughly before drafting.
> - Present the draft to the user for review.
> - Iterate based on feedback.
> - **NEVER post the update without explicit user approval.**
> - **NEVER exit plan mode.**

### Prerequisite

A Linear workspace skill (`/linear-kilic` or `/linear-work`) MUST be invoked before this skill, unless a full Linear URL is provided — in that case, deduce the workspace from the URL and use the corresponding MCP tools.

### Process

1. **Fetch the project** using the appropriate Linear MCP tools.
2. **Fetch prior project updates** using `get_status_updates` to establish the baseline — what was the last update, what was communicated, what was the state at that point.
3. **Analyze the last update** — identify the cutoff point. Everything after this update is "recent" for the purpose of the new post.
4. **Fetch all project issues** and categorize them by status.
5. **Investigate completed issues since the last update** — these form the first paragraph. Understand what was accomplished, not just the issue titles. Read descriptions if needed to summarize the work meaningfully.
6. **Investigate cancelled or descoped issues since the last update** — these form the deviations section. Summarize why they were dropped or changed in a concise manner.
7. **Investigate in-progress and upcoming issues** — identify the immediate next steps for the closing sentence(s).
8. **Draft the update post** following the format below.
9. **Present the draft to the user.** Iterate based on feedback.
10. **Post only after explicit user approval** using the `save_status_update` tool.

### Post Format

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

### Example

> The cache operator has been deployed to the development instance, and traffic has been cut over to the new gateway. This week, we completed the implementation of the messaging operator and prepared it for deployment. Traffic will be cut over to the new gateway on the development instance starting next week. The migration documentation has also been prepared with a straightforward rollback mechanism in place.
>
> While there are minor differences between the old and new gateway operations, we have not encountered any significant challenges to date.
>
> The next steps are to standardize monitoring to match our current setup and update the dashboards to support both gateways.

### Key Rules

- **Never post without user approval.**
- **Never exit plan mode.**
- **Read prior updates first** — the post must build on the last update, not repeat it.
- **Keep it concise** — a good update is 3-6 sentences, not a wall of text.
- **No bullet lists or markdown** — plain prose paragraphs only.
- **Skip the deviations section** if there are none — don't force it.
