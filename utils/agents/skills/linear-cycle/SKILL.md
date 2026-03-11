---
name: linear-cycle
description: Plan and organize Linear cycles by analyzing projects, issues, and initiatives to define a realistic workload. Use when planning the current, next, or an upcoming cycle.
interaction: chat
disable-model-invocation: true
argument-hint: "[cycle-number or 'current'|'next'] - e.g., '42', 'current', 'next'"
---

## system

### Linear Cycle Planning

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Use `EnterPlanMode` tool immediately.
> - Present the cycle plan to the user for approval.
> - After approval, apply changes **without exiting plan mode**.
> - **NEVER exit plan mode.**

### Prerequisite

A Linear workspace skill (`/linear-kilic` or `/linear-work`) MUST be invoked before this skill. The workspace skill handles session initialization (user discovery, label fetching, team assignment) and determines which Linear MCP tools to use. This skill assumes that context is already available.

### Process

#### Step 1: Identify the Target Cycle

- The user provides which cycle to plan: `current`, `next`, or a specific cycle number.
- Use `list_cycles` from the active workspace to fetch available cycles.
- Identify the target cycle by number, or resolve `current`/`next` from the cycle dates.
- Note the cycle start/end dates and duration for capacity reasoning.

#### Step 2: Analyze the Current State of the Target Cycle

- Fetch all issues already assigned to the target cycle.
- Group them by project and standalone issues.
- Note their current status (todo, in progress, done, cancelled).
- Calculate how much estimated work is already committed.

#### Step 3: Analyze Open Projects

- **This step is mandatory.** Fetch issues from all active projects using `list_issues` with project parameters.
- For each active project:
  - Understand the project scope and how many cycles it is expected to span.
  - Identify which issues are done, in progress, and remaining.
  - Map the dependency graph — which issues block which.
  - For multi-cycle projects, determine what must be done in the target cycle vs. what can wait.
  - Prioritize issues that unblock the most downstream work.

#### Step 4: Review Initiatives (Optional Peek)

- Briefly review active initiatives using `list_initiatives` and `get_initiative` as needed.
- Identify initiatives that are close to completion — their remaining issues should be prioritized.
- Identify high-priority initiatives that should influence cycle planning.
- Keep this lightweight — initiatives inform priority, not the full plan.

#### Step 5: Analyze Standalone Issues

- Fetch unassigned-to-cycle issues that are in backlog or todo state.
- Identify high-priority standalone issues that should be considered for the cycle.
- Check if any standalone issues are blockers for project work.

#### Step 6: Calibrate Capacity

- Fetch the **2-3 most recent completed cycles** using `list_cycles`.
- For each, count the total estimated points completed.
- Use this as a baseline for realistic capacity in the target cycle.
- Account for work already committed (from Step 2).
- Use `sequentialthinking` to reason through capacity constraints if the workload is complex.

#### Step 7: Draft the Cycle Plan

Build a structured plan that fits within the calibrated capacity:

1. **Carry-over work** — issues already in the cycle that are in progress or todo.
2. **Must-do project work** — issues from multi-cycle projects that have dependencies or deadlines forcing them into this cycle.
3. **Initiative completions** — issues that would wrap up an initiative if done this cycle.
4. **High-priority project issues** — next logical issues from active projects, respecting dependency order.
5. **Standalone issues** — high-priority standalone work that fits remaining capacity.
6. **Stretch goals** — optional items if capacity allows, clearly marked as stretch.

For each issue in the plan, note:
- Issue ID and title.
- Project (if any).
- Current state.
- Estimate.
- Why it belongs in this cycle (dependency, priority, initiative completion, etc.).

#### Step 8: Present the Plan

Present the cycle plan to the user in a clear format:

```
## Cycle <number> Plan (<start> — <end>)

### Capacity
- Historical average: <X> points/cycle (based on last 2-3 cycles).
- Already committed: <Y> points.
- Available: <Z> points.

### Carry-over
- <issue-id>: <title> (<estimate>pts, <status>)

### Project Work
#### <Project Name>
- <issue-id>: <title> (<estimate>pts) — <reason>
- <issue-id>: <title> (<estimate>pts) — <reason>

### Standalone Issues
- <issue-id>: <title> (<estimate>pts) — <reason>

### Stretch Goals
- <issue-id>: <title> (<estimate>pts) — <reason>

### Total: <N> points planned / <Z> available
```

- Wait for user feedback and iterate on the plan.
- Adjust priorities, swap issues, or change capacity assumptions based on user input.

#### Step 9: Apply the Plan

**Only after the user explicitly approves the plan.** Stay in plan mode while applying.

For each issue in the approved plan:

1. **Set the cycle** — explicitly set the cycle to the target cycle number using the `cycle` field on `save_issue`.
2. **Set the state** — minimum `todo`. Rules:
   - If current state is `triage` or `backlog` → change to `todo`.
   - If current state is `todo`, `in progress`, or any state beyond `todo` → **do not change the state**. Preserve the current state.
   - **NEVER downgrade** an issue's state (e.g., never move `in progress` back to `todo`).
3. Use parallel tool calls to batch updates where possible.
4. Report results as changes are applied.

### Key Rules

- **Never exit plan mode.**
- **Never apply changes without user approval.**
- **Never change issue state downward** — only promote `triage`/`backlog` to `todo`. Everything else stays as-is.
- **Always explicitly set the cycle number** — do not rely on defaults or implicit assignment.
- **Respect dependency order** — if issue A blocks issue B, both can be in the cycle but A should be prioritized.
- **Be realistic about capacity** — use historical data, not optimistic estimates. It is better to under-commit and over-deliver.
- **Multi-cycle awareness** — for projects spanning multiple cycles, only pull in what makes sense for the target cycle. Do not front-load everything.
- **User is the authority** — if the user disagrees with the plan, adjust without argument.
