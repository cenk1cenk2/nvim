---
name: agent-pickup
description: 'agent-pickup Pick up Linear projects, project slices, or issues and execute them with the lead and agents as appropriate. Use on "agents pick up this project", "work these Linear issues", "pick up K-123". Do NOT use for read-only project refreshes or choosing the next task only.'
disableModelInvocation: true
argumentHint: "[Linear project, project slice, issue id(s), or URL] [optional: agent/direct/sequential/parallel/confirm]"
references:
  - ../references/present-first.md
  - ../references/linear-prerequisite.md
  - ../references/linear-pickup-execution.md
  - ../references/linear-state-transitions.md
  - ../references/linear-project-documents.md
  - ../references/linear-chunk-issues.md
  - ../references/agent-delegate.md
  - ../references/agent-conventions.md
  - ../references/agent-plan-split.md
  - ../references/scm-detect.md
  - ../references/sourcebot-discovery.md
  - ../references/project-tooling.md
  - ../references/output-diff.md
---

## Agent Linear Pickup Orchestrator

Posture: `present-first`.
> **PREREQUISITE:** A Linear workspace skill MUST be active before this skill runs — workspace detection per `linear-prerequisite`.

The pickup lifecycle runs per `linear-pickup-execution`. Present every write to Linear, GitHub, or GitLab per `output-diff`.

## Purpose

This skill carries Linear work from pickup to review. It can implement directly, delegate to agents, or mix both. The goal is not "agents for everything"; the goal is to choose the cheapest reliable execution model for the work in front of us.

## Process

1. **Resolve the target.**
   - Accept a Linear project, project slice, multiple issues, one issue, or URL.
   - Compose with `linear-project-pickup` (load it as defined in `load-skills`) for project or slice inputs — do not re-implement its preparation logic.
   - Compose with `linear-issue-pickup` (load it as defined in `load-skills`) for issue inputs — do not re-implement its preparation logic.
   - If the prompt can mean more than one scope, ask one focused question immediately.

2. **Explore before implementation.**
   - Fetch Linear issues, project documents, relations, comments, blockers, and linked PRs/MRs.
   - Inspect target repository state and origin provider per `scm-detect`.
   - Discover verification commands per `project-tooling`.
   - Use `sourcebot-discovery` when pickup needs broad repository/code discovery before GitLab-specific metadata.
   - Use a cheap/default `agent-delegate` Explore agent when the unclear details are broad enough to benefit from parallel reconnaissance.
   - Ask early when details are not finalized, stale, contradictory, or missing.

3. **Plan the execution schedule.**
   - Run an `agent-plan` style split per `agent-plan-split` with file collision checks, prerequisites, and dependency layers; align task boundaries with Linear issues per `linear-chunk-issues`.
   - Decide per task: lead implementation, delegated single agent, parallel layer, or sequential layer. Tier choice and self-contained agent prompts per `agent-delegate`.
   - Use `agent-review` for a cheap collision/prerequisite review when the task set is complicated or the user asks for deeper research.

4. **Report before starting tasks.**
   - Present what will be done, who will do it, sequential/parallel shape, target repos, planned branch strategy, verification commands, and open questions.
   - If the user asked for feedback or confirmation, stop and wait. Do not continue into implementation.

5. **Implement.**
   - Move picked-up issues to `In Progress` per `linear-state-transitions`.
   - Use `git-branch` before implementation unless intentionally continuing a branch.
   - Apply `agent-conventions` to every implementation, direct or delegated — pickup work lands in existing repos and must read as though the repo's own authors wrote it.
   - Implement directly and/or dispatch agents with focused prompts, each carrying the `agent-conventions` block with concrete pattern-reference files.
   - Keep branches current with known merges at convenient checkpoints.
   - Run local verification equivalent to the PR/MR pipeline.

6. **Commit and open review.**
   - Use `git-commit` for logical commits and Linear trailers.
   - Use `github-pr-create` or `gitlab-mr-create` based on origin provider.
   - Ensure linked issues move to `In Review`.
   - Run `agent-review` before finalizing non-trivial or agent-produced PRs/MRs, with an independent review prompt focused on the goals, risks, and alternatives considered.
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
   - Update project documents per `linear-project-documents` when deviations or findings are shared across issues — attach them with the `linear-document` skill, one tightly focused concern per document.
   - Reconcile issue states with current PR/MR reality.
   - If all project issues are done, complete the project by default unless there is a reason to leave it open.
   - Report final status, PR/MR links, pipeline status, verification evidence, deviations, findings, and remaining work.

## Key Principles

- **Explore first, then execute.** Never start coding from a stale Linear description.
- **Ask early, not often.** Ask only for blocking intent or unclear requirements.
- **Agents are a tool, not a default.** Direct implementation is fine for small, serial, or high-context work.
- **Keep tasks issue-aligned.** This keeps Linear states, commits, and PR/MR descriptions clean.
- **Document deviations where future agents will read them.** Use issue comments for local deviations and, for shared findings — investigations, solved problems, plans, deviations — attach a tightly focused document per concern via the `linear-document` skill (issue- or project-scoped by reach).
- **Verify locally before review.** The branch should pass the equivalent of the PR/MR pipeline before opening review when possible.
