---
name: linear-project-read
description: 'linear-project-read Read-only refresh of a Linear project - scan issues and statuses, re-read description and latest update, surface what changed. Triggers: "read/refresh the project", "project pulse". Do NOT use for structure audits (/linear-project-reconcile), status posts (/linear-project-post), or per-issue reads (/linear-issue-read).'
argument-hint: "[project-name or Linear URL]"
references:
  - ../references/linear-prerequisite.md
  - ../references/present-first.md
  - ../references/linear-document-handling.md
---

## Linear Project Read

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Prerequisite

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

## Core Principle

> **THE PROJECT RECORD IS NOT THE ABSOLUTE TRUTH.**
>
> Project descriptions, issues, and status updates carry timestamps (`createdAt`, `updatedAt`). If the project description or most recent update predates the user's latest work, **the user's knowledge may be more current than what Linear shows.** When you detect a gap, **ask the user** rather than assuming Linear is authoritative. Use timestamps as the deciding factor — never treat stale records as truth.

> Read the `linear-document-handling` reference — in this read-only skill, glimpse the project's documents for context, surface what's relevant, and flag stale ones with their timestamps. Never edit; hand off actionable edits to `linear-project-update`.

## Purpose

When you resume work on a project after time has passed — or when the user jumps back into a project after working elsewhere — your high-level understanding may be stale. This skill does a project-level sweep: description, latest update, open issues by status, recent comment activity. The goal is common-sense situational awareness, not a deep per-issue audit.

Compare to sibling skills:

- `linear-issue-read` — deep per-issue reconciliation (one issue, all comments, all relations).
- `linear-project-read` (this skill) — top-level project sweep (all issues, just statuses + titles; latest update; description).
- `linear-project-reconcile` — audit + modify project structure (priorities, estimates, labels, relations).
- `linear-project-post` — draft a new status update post.

## Process

### Step 1: Fetch project issues

Use `list_issues` with the `project` parameter to pull every issue in the project. Do NOT use `get_project` / `list_projects` — they have complexity limits. Project metadata (name, description, status, initiative, milestone) can be inferred from the issues' `project` field when present, or fetched separately if needed.

### Step 2: Fetch prior status updates

Use `get_status_updates` on the project to pull the history of posted updates. Identify:

- **Most recent update's date** — the user's last communicated picture of the project.
- **Cadence** — how often updates have been posted; is the project going quiet, or actively updated?
- **Themes** — what was emphasised in the last 1–2 updates (deliverables, risks, next steps)?

If no updates exist, note that — the project has never had a posted status summary.

### Step 3: Re-read the project description

- Compare the current description against prior session knowledge (memory, conversation context).
- Check the description's `updatedAt`. If older than the current session, flag it — the user may have moved past what's written there.
- Note any description updates or scope changes since your last read.

### Step 4: Categorise open issues by status

Group the project's issues into buckets based on `statusType`:

- **In Progress** — actively being worked on.
- **In Review** — open MR/PR, waiting for merge.
- **Todo / Unstarted** — on deck, not started.
- **Backlog** — deferred.
- **Done / Canceled** — closed (for context on recent wins/drops).

Report counts + a brief list of titles per bucket. Flag:

- Stale "In Progress" issues (last `updatedAt` older than a week or two) — may not actually be active.
- "In Review" issues with no recent comment activity — possible forgotten merges or stuck reviews.
- "Todo" issues with blockers that are already Done — newly actionable.

### Step 5: Scan recent comment activity

For the 5–10 most recently `updatedAt` issues, check comment streams briefly. Look for:

- Decisions or pivots not reflected in descriptions.
- Blockers surfaced.
- Questions awaiting response.
- External dependencies mentioned.

Don't read every comment on every issue — skim the recently active ones and summarise signals.

### Step 6: Present reconciliation report

Format:

```
## Project Revisit: <project-name>

### Snapshot
- Status: <active/paused/etc>
- Issues: <count by bucket — e.g., 3 In Progress / 2 In Review / 8 Todo / 4 Done / 1 Canceled>
- Last update posted: <date> (<N days> ago) — <one-line theme>
- Description last updated: <date>

### Description Changes
- [Deviations from prior understanding, or "No changes detected."]

### Status-Bucket Highlights
- **In Progress:** <issue-id> — <title> (<updated N days ago>). [Flag if stale.]
- **In Review:** ...
- **Todo:** ...
- **Recently Done:** <recent wins since last revisit>
- **Newly Actionable:** <issues whose blockers are now Done>

### Comment Activity Highlights
- <issue-id>: <significant decision / blocker / question>

### Staleness Flags
- [Any records whose timestamps suggest the user's knowledge is more current than Linear's record.]

### Recommended Next Actions
- [What to look at first — e.g., "Review the stuck 'In Review' issue K-45", "Confirm whether K-67 is still being worked on", "Newly unblocked: K-89".]
```

Omit sections that have no findings. Keep bullets short — this is a survey, not an audit.

## Key Rules

- **Read-only.** Never modify issues, comments, the project, or status updates. For modifications, refer the user to `linear-project-reconcile`.
- **Highlight deltas, not full restatements.** The value is in surfacing *what changed since I last looked*, not describing the project from scratch.
- **Timestamps drive staleness.** Quote `updatedAt` when flagging anything as possibly stale.
- **Brief over thorough.** If the user wants a deep dive on a specific issue, refer them to `linear-issue-read`.

## Related Skills

- **`linear-issue-read`** — per-issue deep reconciliation.
- **`linear-project-pickup`** — prepare the project or a project slice for implementation after this read-only refresh.
- **`agents-pickup`** — execute the refreshed project scope with direct work and/or agents.
- **`linear-project-update`** — edit the project description and documents to match the conversation.
- **`linear-project-reconcile`** — audit + modify project structure.
- **`linear-project-post`** — draft a new status update post.
- **`linear-project-match`** — sync issue states against external reality (merged MRs/PRs, user statements). Can be invoked as a follow-up when this read flags mismatched states.
