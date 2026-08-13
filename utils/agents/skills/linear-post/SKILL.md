---
name: linear-post
description: linear-post Draft a Linear status update as plain prose - for a project from its issues, or for an initiative from its projects - and post only on explicit approval. Use on "write a project update", "post initiative status". Not for editing a description or documents, or for structural changes.
argumentHint: '[project or initiative, name/ID/URL]'
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/linear/linear-absolute-approval.md
  - ../references/identifier-legibility.md
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## Linear Status Update Post

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

> **Absolute approval required — see `linear-absolute-approval`.** Status-update writes always require explicit approval for the specific change; a general blessing (`g` / `go` / autopilot) does NOT clear them. Never call `save_status_update` before the user approves the drafted post.

## Scope

| Scope | Members | Prior updates | Post with |
|---|---|---|---|
| Project | `list_issues` with the `project` parameter — never `get_project` / `list_projects`, they hit complexity limits | `get_status_updates` on the project | `save_status_update` |
| Initiative | `get_initiative` with `includeProjects: true`, then `get_status_updates` with `type: "project"` per project | `get_status_updates` with `type: "initiative"` and the initiative id | `save_status_update` with `type: "initiative"` and the initiative id |

## Altitude

The rule is the same at both scopes — describe momentum, never enumerate. What counts as too granular is what shifts:

| Scope | Written from | Describe | Never name |
|---|---|---|---|
| Project | its issues and their comments | outcomes and milestones of the work itself | issues, PRs, MRs |
| Initiative | its projects and their status updates | project-level milestones and direction | issues, PRs, MRs, or projects as a checklist |

## Process

1. **Fetch the scope's members** per the Scope table.
2. **Fetch prior updates** for the scope to establish the baseline — what was the last update, what was communicated, what was the state at that point.
3. **Analyze the last update** — identify the cutoff point. Everything after it is "recent" for the purpose of the new post.
4. **Check timestamps** — use `updatedAt` on issues and projects, and `createdAt` on comments and prior updates, to build an accurate timeline of what happened since the cutoff. If timestamps suggest the user's session knowledge is more recent than what Linear records, ask them to fill in the gaps before drafting.
5. **Categorize the members** by status.
6. **Investigate what completed since the cutoff** — this informs the opening paragraph. Understand what was *accomplished* so you can describe the outcome in prose; read descriptions if needed. At initiative scope, that means which projects advanced, completed, or shipped a meaningful outcome.
7. **Investigate what was cancelled, descoped, paused, or re-prioritized since the cutoff** — this forms the deviations section. Summarize why concisely.
8. **Investigate what is in flight and upcoming** — the immediate next steps for the closing sentence(s).
9. **Draft the update post** following the format below.
10. **Present the draft to the user** in logical chunks per `output-diff`. Iterate based on feedback.
11. **Post only after explicit user approval**, with the tool and arguments from the Scope table.

## Post Format

The update should read as a cohesive narrative, not a bullet list. Write in plain prose — short paragraphs, no headers, no markdown formatting.

Describe the current status and momentum in flowing language — never enumerate specific work or use phrasings like "X was merged". A reader should come away understanding what has moved since the last update and what is next, not read a changelog.

**Structure:**

1. **What has moved** (1-3 sentences) — summarize what completed since the last update. Focus on outcomes and milestones at the scope's altitude, not individual tasks.
2. **Deviations** (1-2 sentences, only if applicable) — briefly note cancelled, paused, or re-prioritized work, a changed approach, or unexpected challenges. Skip this section entirely if there are none.
3. **Next steps** (1-2 sentences) — what is immediately ahead, based on what is in flight and up next.

**Tone:**

- Professional but concise — this is a status update, not a report.
- Focus on what matters to stakeholders — outcomes and direction over implementation details.
- Be honest about challenges without being alarmist.
- Use past tense for what has moved, future tense for next steps.

## Examples

**Project scope:**

> The cache operator has been deployed to the development instance, and traffic has been cut over to the new gateway. This week, we completed the implementation of the messaging operator and prepared it for deployment. Traffic will be cut over to the new gateway on the development instance starting next week. The migration documentation has also been prepared with a straightforward rollback mechanism in place.
>
> While there are minor differences between the old and new gateway operations, we have not encountered any significant challenges to date.
>
> The next steps are to standardize monitoring to match our current setup and update the dashboards to support both gateways.

**Initiative scope** — same voice, one altitude up:

> The gateway migration is now well underway across the initiative. The cache and messaging workstreams have both reached the development instance, and traffic has begun cutting over to the new gateway. Documentation and a straightforward rollback path are in place, giving us confidence to widen the rollout.
>
> One workstream was paused while we align on monitoring standards, but this has not blocked overall momentum.
>
> Next, we will standardize monitoring across both gateways and begin extending the cutover to the remaining instances.

## Key Rules

- **Never post without user approval** — status-update writes require explicit, per-change approval; no blessing/autopilot shortcut applies (see `linear-absolute-approval`).
- **Read prior updates first** — the post must build on the last update, not repeat it.
- **Keep it concise** — a good update is 3-6 sentences, not a wall of text.
- **No bullet lists or markdown** — plain prose paragraphs only.
- **Stay at the scope's altitude** — see the Altitude table. The update is a flowing description of status, not a record of what was merged or which tickets closed.
- **Skip the deviations section** if there are none — don't force it.
