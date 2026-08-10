---
name: linear-project-post
description: 'linear-project-post Draft a Linear project status update from recent progress, deviations, and next steps. Triggers: "write a project update", "post a status update". Do NOT use for editing description/docs (/linear-project-update) or structure changes (/linear-project-reconcile).'
argumentHint: "[project-name or Linear URL]"
references:
  - ../references/present-first.md
  - ../references/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/linear-absolute-approval.md
---

## Linear Project Update Post

Posture: `present-first`.
A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

> **⛔ Absolute approval required — see `linear-absolute-approval`.** Status-update writes always require explicit approval for the specific change; a general blessing (`g` / `go` / autopilot) does NOT clear them. Never call `save_status_update` before the user approves the drafted post.

## Process

1. **Fetch the project issues** using `list_issues` with the `project` parameter (do NOT use `get_project` or `list_projects` — they have complexity limits).
2. **Fetch prior project updates** using `get_status_updates` to establish the baseline — what was the last update, what was communicated, what was the state at that point.
3. **Analyze the last update** — identify the cutoff point. Everything after this update is "recent" for the purpose of the new post.
4. **Check timestamps** — use `updatedAt` on issues and `createdAt` on comments to build an accurate timeline of what happened since the last update. If timestamps suggest the user's session knowledge may be more recent than what's recorded in Linear, ask the user to fill in gaps before drafting.
5. **Categorize issues** by status from the `list_issues` response.
6. **Investigate completed issues since the last update** — these inform the opening paragraph. Understand what was *accomplished* so you can describe the outcome in prose. Read descriptions if needed. Never name the issues, PRs, or MRs themselves — the update describes progress and current status, not a list of merged work.
7. **Investigate cancelled or descoped issues since the last update** — these form the deviations section. Summarize why they were dropped or changed in a concise manner.
8. **Investigate in-progress and upcoming issues** — identify the immediate next steps for the closing sentence(s).
9. **Draft the update post** following the format below.
10. **Present the draft to the user** per `output-diff`. Iterate based on feedback.
11. **Post only after explicit user approval** using the `save_status_update` tool.

## Post Format

The update should read as a cohesive narrative, not a bullet list. Write in plain prose — short paragraphs, no headers, no markdown formatting.

Describe the current status and momentum in flowing language — never enumerate specific issues, pull/merge requests, or phrasings like "X was merged". A reader should come away understanding what has moved since the last update and what is next, not read a changelog of closed tickets.

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

- **Never post without user approval** — status-update writes require explicit, per-change approval; no blessing/autopilot shortcut applies (see `linear-absolute-approval`).
- **Read prior updates first** — the post must build on the last update, not repeat it.
- **Keep it concise** — a good update is 3-6 sentences, not a wall of text.
- **No bullet lists or markdown** — plain prose paragraphs only.
- **Never name issues, PRs, or MRs.** The update is a flowing description of status — what has progressed since the last update and what is next — not a record of what was merged or which tickets closed.
- **Skip the deviations section** if there are none — don't force it.
