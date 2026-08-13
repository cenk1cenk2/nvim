---
name: linear-pickup
description: linear-pickup Prepare Linear work for implementation - a project or slice, a parent issue with its sub-issues, or one or more issues - context, blockers, documents, execution shape - then wait for an explicit go. Use on "pick up this project", "pick up K-123", or a Linear URL. Not for execution by subagents, a read-only refresh, or choosing what to work on next.
argumentHint: '[project, parent issue, issue id(s), or URL] [optional: slice or filter]'
references:
  - ../references/long-running-work.md
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear/linear-prerequisite.md
  - ../references/linear/linear-pickup-execution.md
  - ../references/linear/linear-project-documents.md
  - ../references/linear/linear-scm-discovery.md
  - ../references/linear/linear-chunk-issues.md
  - ../references/linear/linear-state-transitions.md
  - ../references/output-diff.md
  - ../references/linear/linear-issue-philosophy.md
  - ../references/identifier-legibility.md
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## Linear Pickup

State that spans turns must be written durably per `long-running-work` — posture, armed watchers, and artifact truth do not survive a compaction or a handoff on their own.

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

> **THE RECORD IS A TEMPLATE. THE USER IS THE SOURCE OF TRUTH.** Record vs conversation authority per `linear-issue-philosophy`, applied before treating a project, a parent, or an issue as requirements. Records go stale — written before the work started, by someone who did not yet know what implementation would reveal. The user may skip, reorder, add, or override anything in them; never push back with "but the issue says…".

Scope resolution, early questions, issue selection, state updates, and handoff to `agent-pickup` follow `linear-pickup-execution`; apply `linear-state-transitions` before moving selected issues to `In Progress`, and `output-diff` before writing to Linear.

Load `linear-structure-agent` before implementation — picking up is one of its two modes; it owns the shape and record rules throughout, whether or not this tree was shaped with it.

## Purpose

This skill turns a scope of Linear work into an execution-ready issue set. It does not have to implement by itself; by default it hands the prepared context to `agent-pickup`, and a small single issue can be implemented directly by the lead.

## Scope

| Scope | Members | Resolve it with |
|---|---|---|
| Project or slice | the issues the slice selects | `list_issues` with the `project` parameter, plus `list_documents` filtered by project |
| Issue group | the parent's sub-issues | `get_issue` on the parent, then its sub-issues |
| Issue(s) | the ids or URLs given | `get_issue` per id |

- **Resolve the scope first and name which one you resolved.** An id carrying sub-issues is an issue group — the parent frames the work and the children are the execution set.
- **If the slice is ambiguous, ask one focused question before continuing.**
- **Never use `get_project` or `list_projects`** — they hit complexity limits.

## Process

1. **Resolve the scope.**
   - Parse the project name, slug, URL, user-provided slice, or issue ids.
   - Fetch the members per the Scope table.
   - Fetch documents for the owning project per `linear-project-documents`.

2. **Filter and classify.**
   - Include issues explicitly requested by the user.
   - For a project- or group-wide pickup, include actionable `Todo`, `Backlog`, and existing `In Progress` issues unless the user narrows scope.
   - Treat `In Review` blockers as mostly complete, but verify linked PR/MR status when a dependent task is about to start.
   - Exclude `Done` and `Canceled` unless the user asks for reconciliation, and flag terminal or already-done issues before doing work on them.
   - Inspect `blockedBy`, parent/sub-issues, and related issues for readiness.

3. **Read context.**
   - Read descriptions, comments, relations, labels, estimates, and priorities for the selected issues.
   - Read project documents that carry agent instructions, migration guides, candidate matrices, or shared verification commands, handled per `linear-project-documents` — including propagating investigations, solved problems, and deviations as tightly focused documents via the `linear-document` skill.
   - When the user explicitly asks to enrich pickup context from GitHub/GitLab, discover repositories, or produce agent-ready implementation guidance, use SCM discovery per `linear-scm-discovery` to enrich repository inventory, implementation guidance, prior art, file boundaries, and verification expectations — its Discovery Ladder picks the tools from what the active profile carries.

4. **Detect stale scope.**
   - Compare descriptions, comments, project documents, and the user's prompt against each other.
   - If a record says details are unfinished, or comments contradict the description, ask early.
   - If a description is too stale or misleading, plan an update through `linear-issue-update` or `linear-project-update`.
   - Identify missing details and project documentation that needs updates.

5. **Prepare the execution set.**
   - Map the selected issues to executable tasks per `linear-chunk-issues`.
   - Group by repository, concern, and dependency.
   - Identify direct implementation candidates, agent candidates, sequential prerequisites, and parallel-safe groups.
   - Note likely branch and PR/MR boundaries, target repos, origin provider, and likely verification commands.
   - Preserve issue boundaries unless there is a strong reason to merge or split.
   - Ask early for unresolved scope or intent.

6. **State update and handoff.**
   - Move actionable picked-up issues to `In Progress` per `linear-state-transitions`, unless suppressed by the user, and report the transitions.
   - **Prepare only by default — do NOT begin implementing.** Present the pickup summary per `output-diff` and wait for an explicit go (`go`, "implement", "start") before writing any code.
   - When the user already asked to implement in the same request, or gives the go, hand off to `agent-pickup` for execution — or implement directly when the scope is a small single issue.

## Output Shape

```markdown
## Pickup: <project | issue group | issue(s)> — <name>

### Selected Scope
- <issue-id>: <title> — <why included, status/readiness>

### Shared Context
- Repo: <path/url>
- Project document: <title> — <what agents must read>
- Blockers: <blocked-by status>

### Execution Shape
- Direct: <issues/tasks>
- Agents: <issues/tasks and recommended tier>
- Sequential prerequisites: <issue chain>
- Parallel candidates: <issue group>

### Questions / Risks
- <blocking question or stale information>

### Next
- Hand off to `agent-pickup` with <N> tasks.
```

## Key Principles

- **Prepare, then wait.** Gather context and stop. Do not start implementing until the user explicitly confirms — unless the pickup request itself said to implement or go.
- **Pickup is not refresh.** For a read-only survey, use `linear-read`.
- **Records are inputs, not truth.** The user's prompt and recent comments can supersede them.
- **Move state when work starts.** `In Progress` for picked-up issues, respecting the never-downgrade guard.
- **Do not duplicate project docs into every issue.** Reference shared documents instead.
- **Ask early when scope is not final.** Do not let agents discover missing intent mid-implementation.
- **Use issue comments for deviations and findings that matter to future agents.**
