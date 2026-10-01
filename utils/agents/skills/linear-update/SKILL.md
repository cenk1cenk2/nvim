---
name: linear-update
description: linear-update Rewrite a Linear issue, project, or initiative so its prose matches what the work decided - project documents included, and an initiative's project links reviewed. Use on "update the issue", "the description is out of date", "the project docs are stale", "update the initiative". Not for a state change alone, a comment, structural audits, or a status post.
argumentHint: '[issue id, project, or initiative - name, id, or URL]'
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/linear/linear-absolute-approval.md
  - ../references/linear/linear-document-handling.md
  - ../references/linear/linear-issue-philosophy.md
  - ../references/linear/linear-description-structure.md
  - ../references/identifier-legibility.md
---

Issues, MRs and PRs carry their title and link, per `identifier-legibility`.

## Linear Update

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

> **Absolute approval required at project and initiative scope — see `linear-absolute-approval`.** Those writes always require explicit approval for the specific change; a general blessing (`g` / `go` / autopilot) does NOT clear them. Never call `save_project` / `save_document` / `save_initiative` before the user approves the drafted change. At issue scope, the drafted change still waits for the user's approval.

## Core Principle

> **THE RECORD IS NOT THE ABSOLUTE TRUTH. THE CONVERSATION IS.** Record vs conversation authority, and the timestamp check that decides it, per `linear-issue-philosophy`. This skill applies deviations from the conversation back to the record's **prose**: when its `updatedAt` is older than the current conversation, update it to match, always confirming with the user before applying.

Attached, linked, and project documents follow `linear-document-handling`.

## Scope

| Scope | Members | Resolve it with | Depth |
|---|---|---|---|
| Issue | the description and its task lists | `get_issue`, then `list_comments` | every comment — they hold agreements and corrections the description does not yet capture |
| Project | the description and its documents | `get_project`, then `list_documents` / `get_document` | the description plus each document, classified per `linear-document-handling` |
| Initiative | `name`, `summary`, `description`, `status`, `targetDate`, and its project links | `get_initiative` with `includeProjects: true`, then `list_projects` | the initiative record, then a project alignment review across every project |

- **Resolve the scope first and name which one you resolved.**
- **This skill edits prose and an initiative's project links.** Issue structure, priorities, estimates, and relations belong to a structural audit; progress narratives belong to a status post.

## Process

1. **Fetch the scope** per the Scope table. Note each target's `updatedAt`.
2. **Check timestamps** — if the description or a plan-like document is older than the current session context, ask the user what has changed before assuming the stored content is current.
3. **Review the conversation** for deviations from the recorded intent — changed requirements or goals, shifted priorities, rejected approaches, new decisions, corrected assumptions, scope shifts.
4. **Flag outdated or contradicted sections** — warn the user about parts that are stale, inapplicable, or contradicted by the conversation, and get explicit approval before modifying or removing them. Leave external documents read-only.
5. **Draft the updates**, section shape per `linear-description-structure`, and present them per `output-diff` — one chunk per target (description, each document, each initiative field set), highlighting what changed and why.
6. **Iterate** based on user feedback until the prose accurately reflects the current understanding.
7. **Initiative scope: review project alignment** once the updated initiative is agreed. This step is mandatory at initiative scope.
   - **Misaligned projects** — a linked project that does not fit the updated goals: warn the user and recommend removal.
   - **Orphan candidates** — a project with no initiative that now fits the updated goals: present it and ask whether to link it.
   - **Better fits** — a linked project that fits better under a different initiative: suggest the move.
   - Be specific: explain why a project does not fit, or why an orphan does, referencing the updated goals.
8. **Apply changes** only after approval, each as a `patch` against a fresh fetch per `linear-description-structure`:

   | Scope | Write with |
   |---|---|
   | Issue | `save_issue` |
   | Project | `save_project` for the description, `save_document` for each approved document |
   | Initiative | `save_initiative` with the initiative `id`; `save_project` with `addInitiatives` / `removeInitiatives` for project links |

9. **Present results** and wait for user direction.

## What to Update

- **Description text** — rewrite sections that do not reflect the agreed goal, scope, or approach.
- **Issue task lists** — add, remove, check, or cancel items to match the current plan.
- **Project plan-like documents** — bring agent-authored plans and specs in line with the conversation, with agreement.
- **Initiative fields** — `name`, `summary`, `description`, `status`, `targetDate` as the conversation requires.
- **`## Thoughts` section** — on an issue or project description, append a markdown list of key deviations and the reasoning behind them.

## Thoughts Section Format

```markdown
## Thoughts

- Switched from X to Y because Z.
- Dropped requirement A — not needed after discovering B.
- Added milestone C which was missing from the original plan.
```

Only include deviations that matter for future readers understanding *why* the record looks different from what was originally written.

## Key Rules

- **Never modify without user approval** — and at project and initiative scope, explicit per-change approval per `linear-absolute-approval`.
- **Preserve content that hasn't changed** — only update what deviated.
- **The Thoughts section documents *why*, not *what*** — the description itself reflects the *what*.
- **Prefer comments for small issue deviations** — in autonomous agent workflows, rewrite an issue description only when future agents need it to stay aligned, or when it is materially out of whack.
- **Prefer a status post for progress narratives** — this skill corrects recorded intent; it does not communicate progress.
