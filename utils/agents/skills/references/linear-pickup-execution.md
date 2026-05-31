# Linear Pickup Execution

Shared execution workflow for picking up Linear projects, project slices, multiple issues, or one issue and carrying them through implementation with the lead and/or subagents.

## Scope Resolution

Classify the user's target before implementation:

- **Project** — fetch all actionable project issues plus project documents.
- **Project slice** — apply the user's filter first, then fetch only matching issues and related blockers.
- **Multiple issues** — fetch each issue, relations, comments, project context, and shared documents.
- **Single issue** — fetch the issue, relations, comments, project context, and shared documents.

Use `linear-prerequisite` to select the workspace. If the target is unclear after reading the prompt and Linear context, ask one focused question before planning work.

## Initial Exploration Phase

Always do an initial exploration phase before starting implementation:

1. Fetch Linear issues, project documents, comments, relations, statuses, and linked PR/MR URLs.
2. Inspect the target repository or repositories enough to know current branch state, origin provider, default branch, existing open PRs/MRs, and likely verification commands.
3. Check prerequisites and blockers. Treat `In Review` blockers as mostly complete, but verify whether the linked PR/MR exists and is healthy when the next task depends on it.
4. Detect stale or out-of-whack descriptions. If the issue/project says details are not finalized, or comments contradict the description, ask early.
5. When explicitly requested, use `linear-scm-discovery` to enrich repository inventory, implementation guidance, prior art, file boundaries, and verification expectations. For broad or unknown-repo investigations, that discovery starts with Sourcebot when available and escalates to GitLab/GitHub for live SCM state.
6. Use `agents-delegate` with a cheap or default Explore agent for unclear project details when it materially reduces risk.
7. Use a private `plan-hard` style self-interview to resolve design branches, but do not enter plan mode solely because this reference is used.
8. Use `agents-review` for a cheap review of task splits, prerequisite assumptions, file collisions, and stale external claims when the task is complicated or the user requests deeper research.
9. After implementation and before calling work complete, use `agents-review` for an independent review when the diff is non-trivial, risky, or agent-produced.

## Pre-Implementation Report

After exploration and before tasks start, report:

- Target scope and issue IDs.
- What will be implemented and what is out of scope.
- Whether the lead will implement directly, delegate to agents, or mix both.
- Sequential vs parallel schedule, including prerequisites and collision notes.
- Target repositories and provider type for each (`GitHub` or `GitLab`).
- Planned branch names or branch naming basis.
- Verification commands that approximate the PR/MR pipeline locally.
- Open questions, stale information, deviations from Linear, and user decisions needed.

If the user asked for confirmation, feedback, or a plan-only pass, stop here. Ask only the blocking clarifications needed; do not continue into implementation.

## Scheduling and Delegation

Run an `agents-plan` style scheduling pass before implementation:

1. Map tasks to Linear issue boundaries when possible.
2. Decide whether each task is best done by the lead or an agent.
3. Split by repository, concern, and PR/MR boundary.
4. Build a dependency-aware layer schedule.
5. Run a cheap collision/prerequisite review when tasks might overlap files, depend on each other, or run across repositories.
6. Choose agent tier by task risk:
   - Cheap for mechanical, well-scoped changes.
   - Default for integration work.
   - Smart for architecture, broad refactors, risky debugging, or hard reviews.

Agent prompts must be self-contained. Use an extended handoff shape:

- Linear issue/project context and project document links.
- Exact repo path and origin provider.
- Branch and base expectations.
- Owned files or owned area.
- Relevant prior decisions, deviations, and constraints.
- Verification commands.
- Commit trailer expectations (`refs K-123` for partial work, `closes K-123` for the single/final deliverable that fully resolves the issue).
- Expected report format: status, changed behavior, verification evidence, PR/MR readiness, deviations, findings, and blockers.

## Linear State and Documentation

- Move each picked-up issue to `In Progress` before implementation starts, respecting `linear-state-transitions`.
- Use `linear-issue-status` for explicit or situational status changes outside the automatic pickup/PR/MR triggers.
- When an issue reaches `In Review` or `Done`, always try checklist reconciliation with `linear-issue-checklist`.
- In autonomous agent workflows, comment on the issue by default when there are deviations, decisions, blockers, findings, reviewer-driven scope changes, or non-obvious implementation notes. Keep comments short and factual.
- Prefer comments over description edits for normal deviations.
- Use `linear-issue-update` for description changes only when an autonomous agent workflow needs the updated description to keep future agents aligned, or when the issue requires a huge rewrite because the old description is materially out of whack.
- Use `linear-issue-checklist` to reflect completed or explicitly canceled checklist items.
- Update project documents via the workspace `save_document` tool when deviations or findings are shared across multiple issues.
- When PRs/MRs are opened, ensure referenced issues advance to `In Review` through the PR/MR skill or explicit state transition.
- At wrap-up, if all issues in a project are done, close or complete the project by default unless evidence says it should stay open.

## Git, Branching, Commits, and PRs

For every target repository:

1. Use `git-branch` before implementation unless continuing an existing branch is intentional.
2. Keep branches up to date with the default branch and known merged prerequisites at convenient checkpoints.
3. Implement directly or via agents.
4. Run local verification equivalent to the PR/MR pipeline before opening review.
5. Use `git-commit` for logical commits and include appropriate Linear trailers.
6. Use `github-pr-create` or `gitlab-mr-create` based on origin provider.
7. Report PR/MR links and transition Linear issues as needed.

If conflicts occur, use `git-conflict`. When conflicts involve another active issue or agent's work, do a cheap review of both sides and preserve the other work unless the current goal explicitly supersedes it.

## Pipelines, Reviews, and Drift

- Check PR/MR pipeline status when the user asks, when prerequisites depend on it, or at convenient points in sequential/parallel runs.
- In parallel runs, pipeline waiting can be deferred until a convenient synchronization point.
- In sequential runs, pipeline checks can be deferred after launching or finishing the next task if waiting would waste time.
- If pipeline failures are caused by the branch, fix them in the current workflow.
- If failures are external or unrelated, record the evidence and report it at the end.
- Use `github-ci-fix` or `gitlab-ci-fix` when CI diagnosis needs the dedicated workflow.
- If review feedback appears, use `github-pr-fix` or `gitlab-mr-fix` automatically when the feedback is clear and in scope. Ask the user for ambiguous, architectural, or conflicting feedback.
- Before finalizing a non-trivial PR/MR, run `agents-review` with a concise goal and enough context for an independent review. Give hints about decisions and alternatives considered, but do not force the reviewer to accept them.
- Re-check issue and PR/MR states between batches because work may be merged, reviewed, or superseded while agents are running.

## Final Report

Always report:

- Issues handled and their final states.
- What was implemented.
- PR/MR links and pipeline status.
- Local verification commands and results.
- Deviations from the original issue/project plan.
- Findings, blockers, and follow-up work.
- Project documentation or issue comments updated.
- Remaining issues or why the project was completed.
