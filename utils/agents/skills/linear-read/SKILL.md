---
name: linear-read
description: linear-read Read-only refresh of Linear work - a project, a parent issue with its sub-issues, or one issue - surfacing what changed since you last looked. Use on "refresh the project", "what changed on K-123", "project pulse". Not for starting work on it, auditing its structure, or editing anything.
argumentHint: '[project, parent issue, issue id, or URL]'
references:
  - ../references/linear/linear-prerequisite.md
  - ../references/linear/linear-document-handling.md
  - ../references/linear/linear-issue-philosophy.md
  - ../references/identifier-legibility.md
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## Linear Read

A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

## Core Principle

> **THE RECORD IS NOT THE ABSOLUTE TRUTH.** Record vs conversation authority, and the timestamp check that decides it, per `linear-issue-philosophy`. "The record" is whatever the scope covers — a project's description, issues and status updates; a parent issue and its children; or one issue's description and comments. This skill is read-only, so it stops at surfacing the gap: flag stale records with their timestamps and ask the user, never present them as definitive. Hand actionable edits to `linear-project-update` or `linear-issue-update`.

Handle attached, linked, and project documents per `linear-document-handling` — in this read-only skill, glimpse them for context, surface what's relevant, and flag stale ones with their timestamps. Never edit.

## Purpose

When you resume work after time has passed — or the user jumps back in after working elsewhere — your understanding may be stale. This skill re-reads the work and surfaces what changed, got unblocked, or deviated from what you previously understood. Situational awareness, not an audit.

## Scope

| Scope | Members | Depth |
|---|---|---|
| Project | `list_issues` with the `project` parameter | wide and shallow — statuses and titles by bucket, plus a comment skim of the 5-10 most recently updated |
| Issue group | `get_issue` on the parent, then its sub-issues | the parent description in full, each child's status and title, comments on the children that actually moved |
| Single issue | `get_issue` | deep — every comment, every relation followed, plus a brief pulse of its project if it has one |

- **The narrower the scope, the deeper the read.** A project sweep that reads every comment is a waste; a single-issue read that skips them is useless.
- **Resolve the scope first and name which one you resolved.** An id carrying sub-issues is an issue group — say so and read the children too.
- **Never use `get_project` or `list_projects`** — they hit complexity limits. Project name, description, status, initiative, and milestone come from the issues' `project` field.
- **Status-update history is a project-scope step only.** An issue has none.

## Process

### Step 1: Resolve the scope and fetch it

Parse the project, parent issue, or issue id/URL. Fetch the members per the Scope table. State the scope kind and the member count before reporting anything.

### Step 2: Re-read the container record

- **Project** — re-read the description against prior session knowledge. Check its `updatedAt`; if older than the current session, flag it. Then fetch prior status updates with `get_status_updates` and identify the **most recent update's date** (the user's last communicated picture), the **cadence** (going quiet, or actively updated?), and the **themes** emphasised in the last 1-2 updates. If none exist, note that the project has never had a posted summary.
- **Parent issue** — read the description in full and check whether it still describes the whole of what the children do. Check its `updatedAt`.
- **Single issue** — read the entire description carefully and compare against memory or prior conversation. Note anything that doesn't match your prior understanding. If its `updatedAt` predates the current session context, **the user may have more recent knowledge** — flag it and ask what changed.

### Step 3: Read the members at the scope's depth

**Project and issue group** — group members by `statusType`:

- **In Progress** — actively being worked on.
- **In Review** — open MR/PR, waiting for merge.
- **Todo / Unstarted** — on deck, not started.
- **Backlog** — deferred.
- **Done / Canceled** — closed (for context on recent wins and drops).

Report counts plus a brief list of titles per bucket, and flag:

- Stale "In Progress" issues (last `updatedAt` older than a week or two) — may not actually be active.
- "In Review" issues with no recent comment activity — possible forgotten merges or stuck reviews.
- "Todo" issues whose blockers are already Done — newly actionable.

Then skim comment streams on the recently active members — the 5-10 most recently `updatedAt` for a project, the children that moved for a group. Look for decisions or pivots not reflected in descriptions, blockers surfaced, questions awaiting response, and external dependencies mentioned. Do not read every comment on every issue.

**Single issue** — fetch all comments with `list_comments` and check each one's `createdAt` / `updatedAt`. If the most recent comment is significantly older than the current session, the conversation may have moved past what Linear records — ask. Scan for:

- **Status updates** — progress, blockers, or completion reported by someone.
- **Decision changes** — approach pivots, scope adjustments, priority shifts.
- **New information** — technical findings, external dependencies, added constraints.
- **Questions or requests** — anything directed at the assignee or team.

Summarize what matters; skip acknowledgements and auto-generated noise.

### Step 4: Follow relations

Fetch `blockedBy`, `blocks`, `relatedTo`, parent, and sub-issues for the issues in scope — every relation for a single issue, the cross-scope ones for a project or group.

For each related issue: read its description and comments, check whether its status moved since you last looked, identify deviations that affect the scope, and flag anything **newly unblocked**. Pay special attention to `blockedBy` — a blocker that completed or was cancelled may make the work actionable in a different way.

For a single issue that belongs to a project, add a brief project pulse: how many issues are done vs remaining, whether direction or priority shifted, new issues that affect this one, and whether the dependency chain changed. Keep it brief — awareness, not an audit.

### Step 5: Present the reconciliation report

```
## Revisit: <project | issue group | issue> — <name>

### Snapshot
- Status: <active/paused/etc, or the issue's own status>
- Members: <count by bucket — e.g., 3 In Progress / 2 In Review / 8 Todo / 4 Done / 1 Canceled>
- Last update posted: <date> (<N days> ago) — <one-line theme>   [project scope only]
- Description last updated: <date>

### Description Changes
- [Deviations from prior understanding, or "No changes detected."]

### Status Buckets                                                [project and issue group]
- **In Progress:** <issue-id> — <title> (<updated N days ago>). [Flag if stale.]
- **In Review:** ...
- **Todo:** ...
- **Recently Done:** <recent wins since last revisit>
- **Newly Actionable:** <issues whose blockers are now Done>

### Comment Highlights
- <issue-id>: <significant decision / blocker / question>

### Relation Updates
- <related-issue-id>: <title> — <what changed or was discovered>
- [Flag anything newly unblocked or newly blocked.]

### Project Pulse                                                 [single issue in a project]
- [Brief project state summary — progress, direction shifts, new relevant issues.]

### Staleness Flags
- [Records whose timestamps suggest the user's knowledge is more current than Linear's.]

### Recommended Next Actions
- [What to look at first — e.g., "Review the stuck In Review issue K-45", "Confirm whether K-67 is still being worked on", "Newly unblocked: K-89".]
```

Omit sections that have no findings. Keep bullets short — this is a survey, not an audit.

## Key Rules

- **Read-only.** Never modify issues, comments, relations, the project, or status updates. For modifications, refer the user to `linear-reconcile`.
- **Highlight deltas, not full restatements.** The value is in surfacing *what changed since I last looked*, not describing the work from scratch.
- **Timestamps drive staleness.** Quote `updatedAt` when flagging anything as possibly stale.
- **Match depth to scope.** Follow every relation on a single issue; skim on a project sweep. If a project read raises a question about one issue, re-run this skill scoped to that issue.

## Related Skills

- **`linear-pickup`** — prepare the refreshed scope for implementation.
- **`agent-pickup`** — execute the refreshed scope with direct work and/or agents.
- **`linear-project-update`, `linear-issue-update`** — edit descriptions and documents to match the conversation.
- **`linear-reconcile`** — audit + modify structure (priorities, estimates, labels, relations).
- **`linear-post`** — draft a new status update post.
- **`linear-project-match`** — sync issue states against external reality (merged MRs/PRs, user statements). A natural follow-up when this read flags mismatched states.
