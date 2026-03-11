---
name: linear-project-update
description: Audit and update a Linear project's structure, subissues, priorities, estimates, labels, and blocking relations. Use when user says "audit the project", "update project structure", "review project priorities", or "is the project still accurate". Do NOT use for posting status updates (/linear-project-post) or creating new projects (/linear-project-create).
interaction: chat
argument-hint: "[project-name or Linear URL]"
---

## system

### Linear Project Audit & Update

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Fetch the project and all its issues before proposing changes.
> - Present findings and proposed changes to the user.
> - Iterate based on feedback.
> - Do NOT modify anything until the user explicitly approves.

### Prerequisite

> **PREREQUISITE: A Linear workspace skill MUST be active before this skill runs.**
>
> If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:
> - **kilic-dev workspace:** Load `~/.config/nvim/utils/agents/skills/linear-kilic/SKILL.md`
> - **Laravel workspace:** Load `~/.config/nvim/utils/agents/skills/linear-work/SKILL.md`
>
> Deduce the workspace from context: issue ID prefixes (K-xxx → kilic-dev, CLOUD-xxx → Laravel), Linear URLs, repository hosting (GitLab → kilic-dev, GitHub → Laravel). If a full Linear URL is provided, deduce the workspace from the URL directly.

### Timestamp Awareness

Issue descriptions and comments carry timestamps (`createdAt`, `updatedAt`). When auditing, **check `updatedAt` on each issue** — if a description hasn't been updated in a while, it may be stale regardless of how it reads. The current conversation context holds the most recent understanding of the project — the goal is to bring Linear in line with reality, not the other way around. When you flag a description as stale, note its `updatedAt` timestamp and ask the user to confirm before recommending changes.

### Process

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

### Blocking-Priority Rule

Issues that block other issues are prerequisites — they must be completed first. Therefore:

- A blocking issue should have **equal or higher** priority than the issues it blocks.
- If issue A blocks issue B, and A has lower priority than B, flag this as a violation.
- Priority scale: 1=Urgent > 2=High > 3=Normal > 4=Low (lower number = higher priority).
- When recommending priority changes, prefer raising the blocker's priority over lowering the blocked issue's priority.

### Report Format

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

### Key Rules

- **Never modify issues without user approval.**
- **Present all findings before making changes** — the user decides what to act on.
- **Batch updates** — apply approved changes efficiently using parallel tool calls.
- **Preserve content that hasn't changed** — only update fields discussed and approved.
- **Be opinionated but not rigid** — flag issues clearly but accept the user's judgment.
