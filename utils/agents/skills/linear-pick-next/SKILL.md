---
name: linear-pick-next
description: Analyze Linear projects and issues to recommend the best next task(s) to pick up. Use when deciding what to work on next, either across all projects or within a specific one.
interaction: chat
disable-model-invocation: true
argument-hint: "[project-name or Linear URL] (optional — omit to analyze all projects)"
---

## system

### Linear Pick Next Task

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Research project state and issue dependencies before recommending.
> - Present recommendations to the user and get approval before making changes.
> - **NEVER move issues without explicit user approval.**
> - **NEVER exit plan mode.**

### Prerequisite

A Linear workspace skill (`/linear-kilic` or `/linear-work`) MUST be invoked before this skill, unless a full Linear URL is provided — in that case, deduce the workspace from the URL and use the corresponding MCP tools.

### Process

#### Step 1: Determine Scope

If a project was provided, skip to Step 3.

If no project was specified, ask the user:

- **"Should I look across all your projects, or do you have a specific project in mind?"**
- If the user names a project, use that. If they want a broad view, proceed to Step 2.

#### Step 2: Cross-Project Analysis (all projects)

1. **Fetch all active projects** (status: planned, started) assigned to the user.
2. For each project, fetch a summary: project status, total issues, issues in progress, issues in backlog/todo.
3. **Rank projects** by urgency — consider: project deadlines/milestones, number of blocked chains waiting, issues already in progress that need follow-up, overall project priority.
4. **Present the project overview** to the user with a recommendation of which project to focus on.
5. Wait for the user to confirm a project before proceeding to Step 3.

#### Step 3: Issue Analysis (within a project)

1. **Fetch all issues** in the selected project.
2. **Filter to actionable issues** — status is backlog or todo (not done, cancelled, or already in progress).
3. **For each actionable issue, check:**
   - **Prerequisites met?** — are all `blockedBy` issues completed? If not, the issue is not yet actionable.
   - **Is it a blocker?** — does this issue block other issues? Blockers should be prioritized.
   - **Priority level** — respect the existing priority assignment.
   - **Estimate** — note the size for session planning.
4. **Build a dependency-aware ranking:**
   - First tier: issues with all prerequisites met that block other issues (unblocks the most work).
   - Second tier: issues with all prerequisites met, ordered by priority then estimate.
   - Third tier: issues with unmet prerequisites — note what needs to happen first.
5. **Present the ranked list** to the user with reasoning for the ordering.

#### Step 4: Session Planning

Ask the user:

- **"How much time do you have — a quick session or a longer block?"**
- Based on the answer, recommend either a single issue or a set of issues that fit the session.
- For multi-issue sessions, respect dependency order — if issue A blocks issue B, both can be in the session but A comes first.

#### Step 5: Confirm and Move Issues

Once the user agrees on the selection:

1. **Confirm the status transitions** — present exactly what will change:
   - `backlog → todo` for issues planned for the session.
   - `backlog → in progress` or `todo → in progress` for the immediate task.
2. **Wait for explicit approval** before making any changes.
3. **Apply status changes** using parallel tool calls where possible.

### Recommendation Format

```
## Project: <name>

### Ready to Pick Up
1. <issue-id>: <title> (priority: <P>, estimate: <E>)
   → Blocks: <list of issues this unblocks, if any>
   → Why: <brief reasoning>

2. <issue-id>: <title> (priority: <P>, estimate: <E>)
   → Why: <brief reasoning>

### Not Yet Ready
- <issue-id>: <title> — waiting on <blocking-issue-id> (<status>)

### Suggested Session Plan
- Start with: <issue-id> (<reasoning>)
- Then: <issue-id> (if time permits)
```

### Key Rules

- **Never move issues without user approval.**
- **Never exit plan mode.**
- **Prerequisites are hard constraints** — never recommend an issue whose blockers are not done.
- **Blockers first** — issues that unblock other work take priority over isolated tasks.
- **Ask, don't assume** — if the user's availability or focus area is unclear, ask before recommending.
- **Respect user overrides** — if the user wants to pick something different from the recommendation, accept it.
