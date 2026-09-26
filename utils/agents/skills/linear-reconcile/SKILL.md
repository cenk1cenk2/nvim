---
name: linear-reconcile
description: linear-reconcile Audit and fix Linear structure in one pass - a project, an issueset, or a single issue - covering statuses, priorities, estimates, labels, parent links and blocking relations. Use on "reconcile the project", "reconcile K-123", "review the priorities". Not for prose or document edits, syncing state from merged work, posting an update, or creating issues.
argumentHint: '[project, issueset parent, issue id, or URL]'
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/linear/linear-absolute-approval.md
  - ../references/linear/linear-issuesets.md
  - ../references/linear/linear-issue-philosophy.md
  - ../references/linear/linear-mandatory-fields.md
  - ../references/identifier-legibility.md
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## Linear Reconcile

Audit a scope of Linear work and fix what drifted. The scope is a **project**, an **issueset** — a parent issue and its sub-issues, per `linear-issuesets` — or a **single issue**. The checks are the same; only the membership differs.

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

> **Status updates and summary comments: offer, never auto-post, per `linear-absolute-approval`.** Reconciliation covers **issues + structure only** — no project or initiative status update and no summary comment on a parent of its own accord. When progress is genuinely update-worthy, finish all the issue work first, then offer it in one line ("X and Y landed — I can post a project update if you'd like"), and Load `linear-post` or `linear-issue-comment` **only after the user explicitly says yes**. A general blessing / `g` / autopilot does NOT clear this.

## Timestamp Awareness

Record vs conversation authority and the timestamp check per `linear-issue-philosophy`: **check `updatedAt` on each issue**, and when you flag a description as stale, quote it and ask the user to confirm before recommending changes.

## Scope

| Scope | Resolve it with | Container record | Members |
|---|---|---|---|
| Project | `list_issues` with the `project` parameter | the project | every issue in it |
| Issueset | `get_issue` on the parent, then `list_issues` filtered by that parent | the parent issue | its sub-issues, recursively |
| Single issue | `get_issue` | the issue | none |

- **Resolve the scope first and name which one you resolved.** An id handed to you as one issue but carrying sub-issues is an issueset — say so and audit the children too.
- **The project record** — description, status, labels, initiatives, milestones — comes from `get_project` with `includeMilestones: true`.
- **Never write outside the resolved scope.** A blocker in another project, a sibling under a different parent, a parent one level above the scope — read them for context and **flag them in the report**, never edit them.
- A single issue still gets the cross-issue checks against its relations; every proposed change just lands on that one issue.

## Process

1. **Resolve the scope** per the table above and fetch its members. State the scope kind and the member count before auditing.
2. **Audit the container record**, which differs by scope kind:
   - **Project** — does the description still accurately reflect the goal and scope? Is the status correct (backlog, planned, started, paused, completed, canceled)? Are the labels and initiative assignments still relevant? Is the milestone appropriate given current progress?
   - **Parent issue** — does the description still describe the whole of what the sub-issues do, or has it drifted to one slice? Does its status match the aggregate — children all done with the parent still open, or the parent closed over open children? Is its estimate consistent with the children's? Do the children share labels the parent lacks?
   - **Single issue** — no container layer; the member audit below is the whole audit.
3. **Audit each issue in scope:**
   - **Status accuracy** — does each issue's status reflect reality? Are completed issues marked done? Are stale "in progress" issues actually being worked on?
   - **Estimate validity** — are estimates reasonable given what we now know? Flag issues with missing or clearly wrong estimates.
   - **Label consistency** — do all issues have appropriate labels? Are labels consistent across the scope?
   - **Priority correctness** — apply the blocking-priority rule: issues that block others should generally have equal or higher priority than the issues they block. Flag violations.
   - **Blocking relations** — fetch each issue's relations with `get_issue` and `includeRelations: true`; `list_issues` does not return them. Are dependency chains correct? Are there missing `blocks`/`blockedBy` relations? Are there stale relations to issues that are already done?
   - **Issueset structure** — resolve each issue's parent and its sub-issues, and check the set: orphans, a parent missing children, a flat set that wants a parent, wrong or missing `parentId` links.
   - **Description freshness** — flag issues whose descriptions are clearly outdated or no longer match the current approach. Use the `updatedAt` timestamp as evidence.
4. **Build a change report** organized by category:
   - **Container changes** — the project (description, status, labels, initiative, milestone) or the parent issue (description, status, estimate, labels).
   - **Priority adjustments** with rationale (especially blocking-priority violations).
   - **Estimate corrections** with reasoning.
   - **Missing or incorrect relations** to add/remove.
   - **Status corrections** for issues that don't reflect reality.
   - **Description updates** for stale issues.
   - **Label changes** for consistency.
   - **Out-of-scope findings** — anything wrong on an issue this pass will not touch, listed for the user to act on.
5. **Present the report to the user** per `output-diff`, before anything is written to Linear. Group changes by severity — things that are clearly wrong first, then improvements, then suggestions.
6. **Iterate** based on user feedback. The user may approve all, some, or none of the changes.
7. **Apply approved changes** — update issues in batch where possible using parallel tool calls. Label and relation write semantics, and relation read-back, per `linear-mandatory-fields`.

## Blocking-Priority Rule

Issues that block other issues are prerequisites — they must be completed first. Therefore:

- A blocking issue should have **equal or higher** priority than the issues it blocks.
- If issue A blocks issue B, and A has lower priority than B, flag this as a violation.
- Priority scale: 1=Urgent > 2=High > 3=Medium > 4=Low (lower number = higher priority).
- When recommending priority changes, prefer raising the blocker's priority over lowering the blocked issue's priority.

## Report Format

Present findings as a structured summary, not a raw dump:

```
## Scope: <project | issueset | issue> — <name>

### Container
- [project or parent issue: status/description/label/estimate changes if any]

### Priority Violations
- <issue-id>: priority <current> → <recommended> (blocks <blocked-issue-id> which is priority <X>)

### Estimate Issues
- <issue-id>: [missing | needs adjustment] — <reasoning>

### Missing Relations
- <issue-id> should block <issue-id> — <reasoning>

### Status Corrections
- <issue-id>: <current-status> → <recommended-status> — <reasoning>

### Stale Descriptions
- <issue-id>: <brief note on what's outdated>

### Label Inconsistencies
- <issue-id>: [missing | wrong] label — <recommendation>

### Out of Scope
- <issue-id>: <what looks wrong> — outside this scope, flagged only
```

Omit sections that have no findings.

## The Change Ledger

Present every proposed change as one row, so a batch approval is reviewable rather than trusted. Group by severity — clearly wrong first, then improvements, then suggestions:

| Issue | Field | Now | Proposed | Why |
|---|---|---|---|---|
| K-219 | priority | None | High | blocks K-221 and K-224 |
| K-221 | parent | none | K-219 | it is a slice of that work |
| K-233 | estimate | 8 | 3 | scope shrank when the API landed |

The **Now** column is what makes this approvable — a proposal with no current value asks the user to trust that a change is needed. Nothing is written until the whole table is approved.

## Key Rules

- **Never modify issues without user approval.**
- **Stay inside the resolved scope** — findings outside it are reported, never written.
- **Present all findings before making changes** — the user decides what to act on.
- **Batch updates** — apply approved changes efficiently using parallel tool calls.
- **Preserve content that hasn't changed** — only update fields discussed and approved.
- **Be opinionated but not rigid** — flag issues clearly but accept the user's judgment.
