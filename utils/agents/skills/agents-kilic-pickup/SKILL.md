---
name: agents-kilic-pickup
description: Pick up Linear projects, project slices, multiple issues, or one issue and execute them with the lead and agents as appropriate. Use when user says "agents pick up this project", "work these Linear issues", "finish this project with agents", "pick up K-123", or "implement this Linear slice". Do NOT use for read-only project refreshes or choosing the next task only.
interaction: chat
argument-hint: "[Linear project, project slice, issue id(s), or URL] [optional: agent/direct/sequential/parallel/confirm]"
references:
  - ../references/linear-prerequisite.md
  - ../references/linear-pickup-execution.md
  - ../references/linear-state-transitions.md
  - ../references/linear-project-documents.md
  - ../references/linear-chunk-issues.md
  - ../references/agents-delegate.md
  - ../references/agents-plan-split.md
  - ../references/scm-detect.md
  - ../references/sourcebot-discovery.md
  - ../references/project-tooling.md
  - ../references/output-diff.md
---

## system

### Agent Linear Pickup Orchestrator

> **DO NOT enter plan mode by default.** This is an execution orchestrator: explore first, report the execution plan, ask early for blocking ambiguity, then implement after the user has not requested a confirmation gate.
>
> Enter plan mode only when the user explicitly asks for plan-only, feedback, confirmation before implementation, or a deep planning pass.

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

> Read the `linear-pickup-execution` reference for the pickup lifecycle: exploration, pre-implementation report, scheduling, Linear updates, branching, PR/MR creation, pipelines, review fixes, project documentation, and final report.
> Read the `linear-state-transitions` reference for monotonic Linear status updates.
> Read the `linear-project-documents` reference for project-scoped shared context and documenting deviations.
> Read the `linear-chunk-issues` reference for aligning tasks with Linear issue boundaries.
> Read the `agents-plan-split` and `agents-delegate` references for schedule construction, agent tier choice, and self-contained agent prompts.
> Read the `scm-detect` and `project-tooling` references before touching repositories.
> Read the `sourcebot-discovery` reference when pickup needs broad repository/code discovery before GitLab-specific metadata.
> Read the `output-diff` reference before writing to Linear, GitHub, or GitLab.

### Purpose

This skill carries Linear work from pickup to review. It can implement directly, delegate to agents, or mix both. The goal is not "agents for everything"; the goal is to choose the cheapest reliable execution model for the work in front of us.

### Process

1. **Resolve the target.**
   - Accept a Linear project, project slice, multiple issues, one issue, or URL.
   - Compose with `linear-project-pickup` for project or slice inputs.
   - Compose with `linear-issue-pickup` for issue inputs.
   - If the prompt can mean more than one scope, ask one focused question immediately.

2. **Explore before implementation.**
   - Fetch Linear issues, project documents, relations, comments, blockers, and linked PRs/MRs.
   - Inspect target repository state and origin provider.
   - Discover verification commands.
   - Use a cheap/default `agents-delegate` Explore agent when the unclear details are broad enough to benefit from parallel reconnaissance.
   - Ask early when details are not finalized, stale, contradictory, or missing.

3. **Plan the execution schedule.**
   - Run an `agents-plan` style split with issue boundaries, file collision checks, prerequisites, and dependency layers.
   - Decide per task: lead implementation, delegated single agent, parallel layer, or sequential layer.
   - Use `agents-review` for a cheap collision/prerequisite review when the task set is complicated or the user asks for deeper research.

4. **Report before starting tasks.**
   - Present what will be done, who will do it, sequential/parallel shape, target repos, planned branch strategy, verification commands, and open questions.
   - If the user asked for feedback or confirmation, stop and wait. Do not continue into implementation.

5. **Implement.**
   - Move picked-up issues to `In Progress`.
   - Use `git-branch` before implementation unless intentionally continuing a branch.
   - Implement directly and/or dispatch agents with focused prompts.
   - Keep branches current with known merges at convenient checkpoints.
   - Run local verification equivalent to the PR/MR pipeline.

6. **Commit and open review.**
   - Use `git-commit` for logical commits and Linear trailers.
   - Use `github-pr-create` or `gitlab-mr-create` based on origin provider.
   - Ensure linked issues move to `In Review`.
   - Run `agents-review` before finalizing non-trivial or agent-produced PRs/MRs, with an independent review prompt focused on the goals, risks, and alternatives considered.
   - Record deviations and findings on the relevant issue or project document.

7. **Monitor and fix.**
   - Check pipeline status when prompted, when prerequisites depend on it, or at convenient synchronization points.
   - Use `github-ci-fix` or `gitlab-ci-fix` for branch-caused failures.
   - Use `github-pr-fix` or `gitlab-mr-fix` for clear in-scope review feedback.
   - Use `git-conflict` for conflicts, respecting other issue/agent work.

8. **Wrap up.**
   - Use `linear-issue-status` for explicit or situational issue state changes not already handled by pickup/PR/MR triggers.
   - Always try checklist reconciliation when issues move to `In Review` or `Done`.
   - Comment on issues by default for deviations, decisions, blockers, findings, reviewer-driven scope changes, or non-obvious implementation notes.
   - Update issue descriptions only for autonomous-agent alignment or huge rewrites where the old issue is materially out of whack; otherwise prefer comments.
   - Update project documents when deviations or findings are shared across issues.
   - Reconcile issue states with current PR/MR reality.
   - If all project issues are done, complete the project by default unless there is a reason to leave it open.
   - Report final status, PR/MR links, pipeline status, verification evidence, deviations, findings, and remaining work.

### Key Principles

- **Explore first, then execute.** Never start coding from a stale Linear description.
- **Ask early, not often.** Ask only for blocking intent or unclear requirements.
- **Agents are a tool, not a default.** Direct implementation is fine for small, serial, or high-context work.
- **Keep tasks issue-aligned.** This keeps Linear states, commits, and PR/MR descriptions clean.
- **Document deviations where future agents will read them.** Use issue comments for local deviations and project documents for shared findings.
- **Verify locally before review.** The branch should pass the equivalent of the PR/MR pipeline before opening review when possible.
