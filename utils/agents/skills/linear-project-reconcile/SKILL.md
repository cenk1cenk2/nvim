---
name: linear-project-reconcile
description: linear-project-reconcile Reconcile a Linear project's records with reality — audit and fix structure, subissues, priorities, estimates, labels, and blocking relations in one pass. Use when user says "reconcile the project", "audit the project", "clean up the project", "review project priorities", or "is the project still accurate". Do NOT use for editing the project description/documents (/linear-project-update), state-only sync from merged MRs/PRs (/linear-project-match), posting status updates (/linear-project-post), or creating new projects (/linear-project-create).
argument-hint: "[project-name or Linear URL]"
references:
  - ../references/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/present-first.md
  - ../references/linear-absolute-approval.md
---

## Linear Project Reconcile

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> **Project/initiative status updates: offer, don't auto-post.** Read the `linear-absolute-approval` reference. Reconciliation covers **issues + structure only** — it does NOT post a project or initiative status update on its own. When progress is genuinely update-worthy, finish all the issue work first, then **proactively offer** one — briefly note what happened and that it may be worth an update (e.g. "X and Y landed — I can post a project update if you'd like") — and post via `/linear-project-post` or `/linear-initiative-post` **only after the user explicitly says yes**. A general blessing / `g` / autopilot does NOT clear this.

## Prerequisite

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

## Timestamp Awareness

Issue descriptions and comments carry timestamps (`createdAt`, `updatedAt`). When auditing, **check `updatedAt` on each issue** — if a description hasn't been updated in a while, it may be stale regardless of how it reads. The current conversation context holds the most recent understanding of the project — the goal is to bring Linear in line with reality, not the other way around. When you flag a description as stale, note its `updatedAt` timestamp and ask the user to confirm before recommending changes.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

## Process

1. **Fetch all project issues** using `list_issues` with the `project` parameter (do NOT use `get_project` or `list_projects` — they have complexity limits). Note the project name from the issues' `project` field.
2. **Extract project details** from the issues — description, status, labels, initiative, and milestone can be inferred from the issues' metadata.
3. **Audit the project-level configuration:**
   - Does the project description still accurately reflect the goal and scope?
   - Is the project status correct (backlog, planned, started, paused, completed, cancelled)?
   - Are the labels and initiative assignments still relevant?
   - Is the milestone appropriate given current progress?
4. **Audit each subissue:**
   - **Status accuracy** — does each issue's status reflect reality? Are completed issues marked done? Are stale "in progress" issues actually being worked on?
   - **Estimate validity** — are estimates reasonable given what we now know? Flag issues with missing or clearly wrong estimates.
   - **Label consistency** — do all issues have appropriate labels? Are labels consistent across the project?
   - **Priority correctness** — apply the blocking-priority rule: issues that block others should generally have equal or higher priority than the issues they block. Flag violations.
   - **Blocking relations** — are dependency chains correct? Are there missing `blocks`/`blockedBy` relations? Are there stale relations to issues that are already done?
   - **Parent / sub-issue structure** — resolve each issue's parent and its sub-issues. Are issues that should be sub-issues of a parent (or a parent that should own them) actually linked? Flag orphaned sub-issues, a parent missing children, and wrong or missing `parentId` links. This is the most-missed relation — check it explicitly every time.
   - **Description freshness** — flag issues whose descriptions are clearly outdated or no longer match the current approach. Use the `updatedAt` timestamp as evidence.
5. **Build a change report** organized by category:
   - **Project-level changes** (description, status, labels, initiative, milestone).
   - **Priority adjustments** with rationale (especially blocking-priority violations).
   - **Estimate corrections** with reasoning.
   - **Missing or incorrect relations** to add/remove.
   - **Status corrections** for issues that don't reflect reality.
   - **Description updates** for stale issues.
   - **Label changes** for consistency.
6. **Present the report to the user.** Group changes by severity — things that are clearly wrong first, then improvements, then suggestions.
7. **Iterate** based on user feedback. The user may approve all, some, or none of the changes.
8. **Apply approved changes** — update issues in batch where possible using parallel tool calls.

## Blocking-Priority Rule

Issues that block other issues are prerequisites — they must be completed first. Therefore:

- A blocking issue should have **equal or higher** priority than the issues it blocks.
- If issue A blocks issue B, and A has lower priority than B, flag this as a violation.
- Priority scale: 1=Urgent > 2=High > 3=Normal > 4=Low (lower number = higher priority).
- When recommending priority changes, prefer raising the blocker's priority over lowering the blocked issue's priority.

## Report Format

Present findings as a structured summary, not a raw dump:

```
## Project: <name>

### Project-Level
- [status/description/label changes if any]

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
```

Omit sections that have no findings.

## Key Rules

- **Never post a project/initiative status update on your own** — when it's warranted, proactively OFFER it (note what happened, that it's update-worthy) after everything else, and post only on the user's explicit yes (see `linear-absolute-approval`); reconcile itself only touches issues/structure.
- **Never modify issues without user approval.**
- **Present all findings before making changes** — the user decides what to act on.
- **Batch updates** — apply approved changes efficiently using parallel tool calls.
- **Preserve content that hasn't changed** — only update fields discussed and approved.
- **Be opinionated but not rigid** — flag issues clearly but accept the user's judgment.
