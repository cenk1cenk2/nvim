---
name: linear-issue-pickup
description: 'linear-issue-pickup Pick up one or more Linear issues and prep them for implementation - fetch details, comments, relations, docs, and repo context, then wait for an explicit go. Triggers: "pick up K-123", "work on this issue", issue URLs. Do NOT use for read-only refreshes (linear-issue-read) or choosing the next task (linear-next-task).'
argumentHint: "[issue id(s) or URL(s)]"
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear-prerequisite.md
  - ../references/linear-pickup-execution.md
  - ../references/linear-project-documents.md
  - ../references/linear-scm-discovery.md
  - ../references/sourcebot-discovery.md
  - ../references/linear-state-transitions.md
  - ../references/output-diff.md
  - ../references/linear-issue-philosophy.md
---

## Linear Issue Pickup

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill must be active first — detection rules in `linear-prerequisite`.

> **THE ISSUE IS A TEMPLATE. THE USER IS THE SOURCE OF TRUTH.** Issues go stale — written before the work started, by someone who did not yet know what implementation would reveal. The user may skip, reorder, add, or override anything in it; never push back with "but the issue says…". Full rationale in `linear-issue-philosophy`.

Pickup, early questions, Linear state updates, implementation handoff, and final reporting per `linear-pickup-execution`.

## Purpose

This skill prepares one or more issues for real work. It can hand off to `agent-pickup` for execution, or support a direct lead implementation when the task is small.

## Process

1. **Resolve issues.**
   - Parse issue IDs or URLs.
   - Fetch each issue, full description, comments, relations, project field, labels, estimate, priority, status, and links.
   - If an issue belongs to a project, fetch relevant project documents per `linear-project-documents`.

2. **Check readiness.**
   - Inspect `blockedBy`, parent/sub-issues, and related issues.
   - Treat `In Review` blockers as mostly complete, but verify linked PR/MR status when this task depends on them.
   - Flag terminal, canceled, or already-done issues before doing work.

3. **Detect stale scope.**
   - Compare description, comments, project documents, and user prompt.
   - If the issue says details are unfinished, or comments contradict the description, ask early.
   - If the description is too stale or misleading, plan an update through `linear-issue-update`.

4. **Prepare implementation context.**
   - Identify target repo(s), branch boundaries, origin provider, likely verification commands, and linked PR/MR history.
   - If explicitly requested, enrich repository context, prior art, likely file boundaries, and agent instructions per `linear-scm-discovery`, using `sourcebot-discovery` through that workflow for broad or unknown-repo searches when available.
   - Decide whether implementation should be direct, delegated, sequential, or parallel.
   - For multiple issues, preserve issue boundaries where possible.

5. **State update and handoff.**
   - Move actionable picked-up issues to `In Progress` per `linear-state-transitions`, unless suppressed by the user.
   - Report state transitions.
   - **Prepare only by default — do NOT begin implementing.** Present the pickup summary per `output-diff` and wait for an explicit go (`go`, "implement", "start") before writing any code.
   - When the user already asked to implement in the same request (or gives the go), hand off to `agent-pickup` for execution, or implement directly for a small single issue.

## Output Shape

```markdown
## Issue Pickup

### Issues
- <issue-id>: <title> — <status/readiness>

### Context
- Repo: <path/url>
- Project docs: <docs read or needed>
- Blockers: <blocked-by status>

### Execution Recommendation
- <direct or agent, sequential or parallel, tier if delegated>

### Questions / Deviations
- <blocking question or stale issue content>
```

## Key Principles

- **Prepare, then wait.** Gather context and stop. Do not start implementing until the user explicitly confirms — unless the pickup request itself said to implement/go.
- **Issue descriptions are inputs, not truth.** User prompt and recent comments can supersede them.
- **Move state when work starts.** Use `In Progress` for picked-up issues, respecting the never-downgrade guard.
- **Ask before implementation when intent is incomplete.**
- **Use issue comments for deviations and findings that matter to future agents.**
