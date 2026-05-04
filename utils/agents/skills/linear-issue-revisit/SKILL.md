---
name: linear-issue-revisit
description: Refresh and reconcile knowledge of a Linear issue by re-reading its description, comments, relations, and project context. Use when user says "refresh the issue", "re-read the issue", "what changed on this issue", or "catch me up on K-123". Do NOT use for starting work (/linear-issue-implement) or updating the issue (/linear-issue-update).
interaction: chat
argument-hint: "[issue-id or Linear URL]"
---

## system

### Linear Issue Revisit

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Research the issue thoroughly before presenting findings.
> - Present a reconciliation report to the user.
> - **NEVER exit plan mode.**

### Prerequisite

> **PREREQUISITE: A Linear workspace skill MUST be active before this skill runs.**
>
> If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:
> - **kilic-dev workspace:** Load skill `linear-kilic` via the `linear-kilic` skill (load it as defined in `load-skills`)
> - **Laravel workspace:** Load skill `linear-work` via the `linear-work` skill (load it as defined in `load-skills`)
>
> Deduce the workspace from context: issue ID prefixes (K-xxx → kilic-dev, CLOUD-xxx → Laravel), Linear URLs, repository hosting (GitLab → kilic-dev, GitHub → Laravel). If a full Linear URL is provided, deduce the workspace from the URL directly.

### Core Principle

> **THE ISSUE IS NOT THE ABSOLUTE TRUTH.**
>
> Issue descriptions and comments carry timestamps (`createdAt`, `updatedAt`). If the description was last updated or comments were posted before the current conversation context or the user's latest work, **the user's knowledge may be more current than what Linear shows.** When you detect a gap between the issue's timestamps and the current session, **ask the user** to clarify rather than assuming the issue is authoritative. Timestamps are the deciding factor — always check when the description was last updated and when the most recent comment was posted.

### Purpose

When you resume work on an issue after time has passed, your knowledge may be stale. This skill systematically re-reads the issue and its surroundings to surface anything that changed, got unblocked, or deviated from what you previously understood.

### Process

#### Step 1: Re-read the Issue

- Fetch the full issue using the appropriate Linear MCP tools.
- **Check the `updatedAt` timestamp** on the issue — note when the description was last modified.
- If the description's `updatedAt` is older than the current session context or recent conversation history, **the user may have more recent knowledge**. Flag this and ask the user if anything has changed since.
- Read the **entire description** carefully — compare against what you know from memory or prior conversation context.
- Note any changes, additions, or sections that don't match your prior understanding.

#### Step 2: Review All Comments

- Fetch all comments on the issue using `list_comments`.
- **Check each comment's `createdAt` and `updatedAt` timestamps.** If the most recent comment is significantly older than the current session, the conversation may have moved beyond what's recorded in Linear. Ask the user if there are updates not yet reflected in comments.
- Scan for:
  - **Status updates** — someone reporting progress, blockers, or completion.
  - **Decision changes** — approach pivots, scope adjustments, or priority shifts.
  - **New information** — technical findings, external dependencies discovered, or constraints added.
  - **Questions or requests** — anything directed at the assignee or team that needs attention.
- Summarize significant comments — skip noise (acknowledgements, auto-generated updates).

#### Step 3: Inspect Relations

- Fetch all related issues — `blockedBy`, `blocks`, `relatedTo`, parent, and sub-issues.
- For each related issue:
  - Read its **description** and **comments**.
  - Check its **current status** — has it moved since you last looked?
  - Identify **deviations** — has the related issue's scope or approach changed in ways that affect this issue?
  - Flag anything **newly unblocked** — a blocker that was completed, or a dependency that shifted.
- Pay special attention to `blockedBy` issues — if any were completed or cancelled, this issue may now be actionable in a different way.

#### Step 4: Review Project Context (if assigned)

- If the issue belongs to a project, fetch the project's issues using `list_issues` with the `project` parameter.
- Build a brief picture of the project's current state:
  - How many issues are done vs. remaining?
  - Has the project's direction or priority shifted?
  - Are there new issues in the project that affect this one?
  - Has the ordering or dependency chain changed?
- Keep this overview brief — the goal is common-sense awareness, not a full project audit.

#### Step 5: Present Reconciliation Report

Present findings to the user in this structure:

```
## Issue Revisit: <issue-id> — <title>

### Description Changes
- [List deviations from prior understanding, or "No changes detected."]

### Comment Highlights
- [Significant updates, decisions, or new information from comments.]

### Relation Updates
- <related-issue-id>: <title> — <what changed or was discovered>
- [Flag any newly unblocked or newly blocked dependencies.]

### Project Pulse (if applicable)
- [Brief project state summary — progress, direction shifts, new relevant issues.]

### Staleness Check
- Issue description last updated: <timestamp>
- Most recent comment: <timestamp> by <author>
- [If timestamps are older than current session context: "Issue content may be stale — asked user to clarify recent changes." or "Issue content is up-to-date."]

### Recommended Actions
- [What the user should consider doing based on findings — e.g., "K-45 is now complete, unblocking the API work in this issue", "Comment from X suggests reconsidering the caching approach".]
```

### Key Rules

- **This is a read-only reconnaissance skill** — never modify the issue, comments, or relations.
- **Never exit plan mode.**
- **Compare against prior knowledge** — the value is in surfacing *what changed*, not restating what's already known.
- **Follow every relation** — don't skip related issues even if they seem tangential. A change in a "related-to" issue can shift priorities.
- **Be concise in the report** — highlight deltas, not full re-descriptions.
