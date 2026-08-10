---
name: linear-initiative-post
description: 'linear-initiative-post Draft a status update post for a Linear initiative from recent progress across its projects and next steps. Use for "write an initiative update", "post an initiative status update". Do NOT use for description edits (/linear-initiative-update) or project status updates (/linear-project-post).'
argumentHint: "[initiative-name or ID]"
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/linear-absolute-approval.md
---

## Linear Initiative Update Post

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill must be active first — detection rules in `linear-prerequisite`.

> **⛔ Absolute approval required per `linear-absolute-approval`.** Initiative writes always require explicit approval for the specific change; an upfront blessing (`g` / `go` / autopilot) does NOT clear them. Never call `save_status_update` before the user approves the drafted post.

## Process

1. **Fetch the initiative and its projects** using `get_initiative` with `includeProjects: true`.
2. **Fetch prior initiative updates** using `get_status_updates` with `type: "initiative"` and the `initiative` id, to establish the baseline — what was the last update, what was communicated, what was the state at that point.
3. **Analyze the last update** — identify the cutoff point. Everything after this update is "recent" for the purpose of the new post.
4. **Gauge project-level progress since the cutoff** — for the initiative's projects, look at project state changes and each project's recent status updates (`get_status_updates` with `type: "project"` per project) to understand what has moved. Use project `updatedAt` and status-update timestamps to build an accurate timeline. If timestamps suggest the user's session knowledge is more recent than what's recorded in Linear, ask the user to fill in gaps before drafting.
5. **Identify milestones and outcomes** — which projects advanced, completed, or shipped a meaningful outcome since the last update. These form the opening paragraph. Work at the initiative's altitude: describe project-level milestones and outcomes, never individual issues, PRs, or MRs.
6. **Identify deviations** — projects that were descoped, paused, re-prioritized, or that hit unexpected challenges since the last update. These form the deviations section (only if applicable).
7. **Identify what's next** — the immediate direction based on in-flight and upcoming projects, for the closing sentence(s).
8. **Draft the update post** following the format below.
9. **Present the draft to the user** in logical chunks per `output-diff`. Iterate based on feedback.
10. **Post only after explicit user approval** using `save_status_update` with `type: "initiative"` and the `initiative` id.

## Post Format

The update should read as a cohesive narrative, not a bullet list. Write in plain prose — short paragraphs, no headers, no markdown formatting.

Describe the current status and momentum in flowing language — never enumerate specific issues, pull/merge requests, projects-as-a-checklist, or phrasings like "X was merged". A stakeholder should come away understanding where the initiative stands, what has moved since the last update, and what is next — not read a changelog of closed work.

**Structure:**

1. **What has moved** (1-3 sentences) — summarize the progress across the initiative since the last update. Focus on milestones and outcomes at the initiative altitude.
2. **Deviations** (1-2 sentences, only if applicable) — briefly note any paused, descoped, or re-prioritized work, or unexpected challenges. Skip this section entirely if there are none.
3. **Next steps** (1-2 sentences) — the immediate direction ahead based on in-flight and upcoming projects.

**Tone:**

- Professional but concise — this is a status update, not a report.
- Focus on what matters to stakeholders — outcomes and direction over implementation details.
- Be honest about challenges without being alarmist.
- Use past tense for what has moved, future tense for next steps.

## Example

> The gateway migration is now well underway across the initiative. The cache and messaging workstreams have both reached the development instance, and traffic has begun cutting over to the new gateway. Documentation and a straightforward rollback path are in place, giving us confidence to widen the rollout.
>
> One workstream was paused while we align on monitoring standards, but this has not blocked overall momentum.
>
> Next, we will standardize monitoring across both gateways and begin extending the cutover to the remaining instances.

## Key Rules

- **Never post without user approval** — initiative writes require explicit, per-change approval; no blessing/autopilot shortcut applies (see `linear-absolute-approval`).
- **Read prior updates first** — the post must build on the last update, not repeat it.
- **Keep it concise** — a good update is 3-6 sentences, not a wall of text.
- **No bullet lists or markdown** — plain prose paragraphs only.
- **Never name issues, PRs, or MRs.** The update is a flowing description of status — what has progressed since the last update and what is next — not a record of what was merged or which tickets closed. Stay at the initiative altitude.
- **Skip the deviations section** if there are none — don't force it.
