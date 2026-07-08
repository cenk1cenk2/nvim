---
name: linear-triage
description: Process all Linear issues in triage status, recommending projects, priorities, teams, and refinements interactively. Use when user says "triage issues", "process the triage queue", or "review untriaged issues". Requires a workspace skill (linear-kilic or linear-laravel). Do NOT use for cycle planning (linear-cycle) or picking next tasks (linear-next-task).
references:
  - ../references/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/linear-issue-states.md
  - ../references/present-first.md
---

## Linear Triage

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

> Read the `linear-issue-states` reference for state meanings and transition rules when recommending target states.

## Process

### Step 1: Fetch Triage Issues

- Use `list_issues` with `state: "triage"` to fetch all issues in triage status.
- If there are many issues, paginate using `cursor`.
- Group issues by theme, label, or apparent domain to make the review easier.

### Step 2: Fetch Context

- Fetch all active projects using `list_projects` (exclude archived).
- Fetch current cycle using `list_cycles` with `type: "current"`.
- Keep these available throughout the session for recommendations.

### Step 3: Present Overview

Present the triage queue to the user:

- Total number of issues in triage.
- Grouping by theme if patterns are visible (e.g., "5 issues related to authentication, 3 related to monitoring").
- **Project creation signal** — if 3+ issues cluster around a common theme and no existing project covers it, flag this to the user and recommend creating a project via `linear-project-create`. Do NOT create the project yourself — just recommend it and move on. The user can act on it after triage.
- Ask the user if they want to process all issues or focus on a specific group.

### Step 4: Process Each Issue

For each issue:

- Fetch comments on the issue using `list_comments`. Comments often contain context about priority, scope clarifications, team ownership, or urgency that informs better recommendations. Skip if the issue has no comments.

Present a recommendation covering:

1. **Summary** — restate what the issue is about in one sentence.
2. **Project** — recommend an existing project if one fits. If no project fits, say so — not every issue needs a project. Never force a project assignment.
3. **Priority** — recommend a priority (0=None, 1=Urgent, 2=High, 3=Normal, 4=Low) with brief reasoning.
4. **Labels** — recommend labels from the fetched label list if the issue has none or if current labels seem wrong.
5. **Team** — confirm team assignment. Flag if the issue seems like it belongs to a different team.
6. **Target state** — recommend `backlog` as the default. Recommend `todo` if the issue is urgent or the user wants it in the current cycle.
7. **Cycle** — if recommending `todo`, suggest adding to the current cycle. Only if the user confirms.
8. **Description refinement** — if the description is vague, incomplete, or could be improved, suggest specific changes. Follow the approach from the `linear-issue-update` skill: identify what's missing or unclear, draft improvements, and present them for approval.
9. **Estimate** — recommend an estimate if missing.

**Present recommendations as a concise block per issue.** Example:

```
### K-123: Fix authentication timeout on mobile

- **Project:** Authentication Overhaul (fits the scope)
- **Priority:** 3 (Normal) — not blocking other work
- **Labels:** bug
- **Team:** Platform (current, looks correct)
- **State:** backlog
- **Estimate:** 2
- **Description:** Looks clear, no changes needed.

Accept? (or tell me what to change)
```

Wait for the user to accept, modify, or skip each issue before proceeding.

### Step 5: Apply Changes

For each accepted issue:

- Use `save_issue` with the agreed fields: `state`, `priority`, `labels`, `estimate`, `project`, `team`, `cycle`.
- If description refinement was approved, update `description` in the same call.
- Batch where possible — if the user approves multiple issues in a row, apply them together using parallel tool calls.

### Step 6: Summary

After processing all issues (or when the user stops), present a summary:

- How many issues were processed, skipped, and remain in triage.
- Any project creation recommendations that came up during the session.
- Issues that were added to the current cycle.

## Key Rules

- **One issue at a time** — present, wait for user response, then proceed. Do not dump all recommendations at once.
- **Never force a project** — some issues are standalone. Recommend but accept "no project".
- **3+ similar issues = project signal** — flag it once during the overview, do not repeat per issue.
- **User decides everything** — you recommend, the user approves. Skip without argument if the user says skip.
- **Refine descriptions inline** — when a description needs improvement, propose the changes right there instead of deferring to a separate skill invocation.
- **Labels must exist** — only recommend labels from the fetched label list. Never invent labels.
- **State floor is `backlog`** — triage issues move to at least `backlog`. They move to `todo` only if the user explicitly confirms.
