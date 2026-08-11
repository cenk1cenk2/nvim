---
name: linear-next-task
description: linear-next-task Weigh Linear projects and issues and recommend what to work on next. Use on "what should I work on", "pick the next task". Not for picking up an issue you already chose, or for planning a whole cycle.
argumentHint: '[optional: project or URL - omit to weigh everything]'
references:
  - ../references/reconcile-state.md
  - ../references/linear-prerequisite.md
  - ../references/linear-issue-states.md
  - ../references/linear-pickup-execution.md
  - ../references/linear-issue-philosophy.md
  - ../references/identifier-legibility.md
---

Issues, MRs and PRs are never listed as bare identifiers - carry a title, and the repository or parent scope when more than one is in play, per `identifier-legibility`.

## Linear Pick Next Task

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

State meanings, transition rules, and dependency resolution semantics: `linear-issue-states`.

Per `linear-issue-philosophy`, records go stale — rank on what the user knows now, not only on what Linear shows. Where a timestamp suggests the record predates the user's latest work, surface the gap instead of ranking on it silently.

## Project Discovery (IMPORTANT)

**DO NOT use `list_projects` or `get_project`** — these tools have complexity limits and lookup issues.

**ALWAYS use `list_issues` with the `project` parameter** to fetch issues directly:

```
project parameter accepts:
- Project name (e.g., "renovate-operator-migration")
- Project slug from URL (e.g., "1e710cd45ccd")
- Partial project name matches
```

If user provides a Linear URL like `https://linear.app/kilic-dev/project/renovate-operator-migration-1e710cd45ccd/issues`:

- Extract the project name: `renovate-operator-migration`
- Use `list_issues` with `project: "renovate-operator-migration"`

## Process

### Step 1: Determine Scope

If a project was provided (name or URL), extract the project identifier and skip to Step 3.

If no project was specified, ask the user:

- **"Should I look across all your projects, or do you have a specific project in mind?"**
- If the user names a project or provides a URL, use that. If they want a broad view, proceed to Step 2.

### Step 2: Cross-Project Analysis (all projects)

1. **Fetch issues from all projects** using `list_issues` with broad query terms (e.g., user's name or team).
2. Group issues by project from the response.
3. **Rank projects** by urgency — consider: project deadlines/milestones, number of blocked chains waiting, issues already in progress that need follow-up, overall project priority.
4. **Present the project overview** to the user with a recommendation of which project to focus on.
5. Wait for the user to confirm a project before proceeding to Step 3.

### Step 3: Issue Analysis (within a project)

1. **Fetch all issues** using `list_issues` with `project` parameter.
2. **Separate issues by status:**
   - **Active work:** status "In Review" or "In Progress" — these are already being worked on. Note: "In Review" means the work is essentially complete, so dependent issues CAN proceed.
   - **Actionable:** status "Backlog" or "Todo" and all `blockedBy` issues are either "Done" or "In Review".
   - **Blocked:** status "Backlog" or "Todo" but has `blockedBy` issues in "Todo" or "In Progress" (not yet ready).
   - **Completed:** status "Done" or "Cancelled" — exclude from recommendations.
3. **For each actionable issue, check:**
   - **Prerequisites met?** — are all `blockedBy` issues either "Done" or "In Review"? If blocked by "Todo" or "In Progress", the issue is not yet actionable.
   - **Is it a blocker?** — does this issue block other issues? Blockers should be prioritized.
   - **Priority level** — respect the existing priority assignment.
   - **Estimate** — note the size for session planning.
4. **Build a dependency-aware ranking:**
   - First tier: issues with all prerequisites met that block other issues (unblocks the most work).
   - Second tier: issues with all prerequisites met, ordered by priority then estimate.
   - Third tier: issues with unmet prerequisites — note what needs to happen first.
5. **Present the ranked list** to the user with reasoning for the ordering.

### Step 4: Choose Work Type

Ask the user:

- **"What would you like to work on?"**
  - **Continue active work** — pick an issue that's already "In Review" or "In Progress" (ongoing work)
  - **Pick a new issue** — start a fresh issue from "Backlog" or "Todo" (note: "In Review" blockers are considered complete, so dependents CAN be picked)
  - **Let me decide** — recommend based on what's most urgent

If the user chooses to continue active work:

1. Focus on issues in "In Review" or "In Progress" status.
2. If there's only one active issue, offer to open it.
3. If there are multiple, present them and ask which to continue.

If the user chooses to pick a new issue:

1. Focus on "Ready to Pick Up" issues from Step 3.
2. Remember: issues blocked by "In Review" are actionable — "In Review" means the work is essentially complete.
3. Apply the dependency-aware ranking from Step 3.

If the user lets you decide:

1. If there's active work that needs attention (e.g., failing CI, awaiting review), highlight it.
2. Otherwise, recommend the highest-priority actionable issue from "Ready to Pick Up".

### Step 5: Open in Browser (Optional)

If the user asks to open the issue:

- Use `hyprpilot__open` with the issue URL: `https://linear.app/<workspace>/issue/<identifier>`
- If opening multiple issues, ask the user which one to open first.

### Step 6: Session Planning

Ask the user:

- **"How much time do you have — a quick session or a longer block?"**
- Based on the answer, recommend either a single issue or a set of issues that fit the session.
- For multi-issue sessions, respect dependency order — if issue A blocks issue B, both can be in the session but A comes first.

### Step 7: Confirm and Move Issues

Once the user agrees on the selection:

1. **Confirm the status transitions** — present exactly what will change:
   - `backlog → todo` for issues planned for the session.
   - `backlog → in progress` or `todo → in progress` for the immediate task.
2. **Wait for explicit approval** before making any changes.
3. **Apply status changes** using parallel tool calls where possible.
4. **Execution handoff** — if the user wants the selected work picked up immediately, follow `linear-pickup-execution` and hand off to `linear-issue-pickup` for specific issues or `agent-pickup` for a project slice/multiple issues.

## Recommendation Format

```
## Project: <name>

### Active Work (In Review / In Progress)
- <issue-id>: <title> — already being worked on, complete this first if applicable

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

## Key Rules

- **Never move issues without user approval.** Draft and present the transitions before writing; apply only after approval.
- **Prerequisites are hard constraints for "Todo" and "In Progress" blockers** — but "In Review" blockers are considered complete. Issues blocked by "In Review" work CAN be picked up.
- **Blockers first** — issues that unblock other work take priority over isolated tasks.
- **Show active work separately** — "In Review" and "In Progress" issues appear in an "Active Work" section. When picking a new issue, these are NOT blockers since "In Review" means essentially complete.
- **Ask, don't assume** — if the user's availability or focus area is unclear, ask before recommending.
- **Respect user overrides** — if the user wants to pick something different from the recommendation, accept it.
- **Recommendation is not execution** — only hand off to pickup skills when the user asks to start work.
