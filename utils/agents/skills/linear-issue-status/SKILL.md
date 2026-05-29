---
name: linear-issue-status
description: Quickly update a Linear issue status from explicit user wording or clear workflow context. Use when user says "mark K-123 done", "move this to in review", "set the issue to in progress", "cancel this issue", or when composing status changes with issue creation/checklist work. Do NOT use for full issue edits or project reconciliation.
interaction: chat
argument-hint: "[issue-id or URL] [status]"
references:
  - ../references/linear-prerequisite.md
  - ../references/linear-issue-states.md
  - ../references/linear-state-transitions.md
  - ../references/output-diff.md
---

## system

### Linear Issue Status Update

> **DO NOT enter plan mode.** This is a lightweight status update workflow.

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

> Read the `linear-issue-states` reference for state semantics and the never-downgrade rule.
> Read the `linear-state-transitions` reference for monotonic transition reporting and opt-out wording.
> Read the `output-diff` reference when presenting non-obvious or inferred status changes before writing.

### Purpose

This skill changes issue status only. It is meant to compose verbally and situationally with `linear-issue-create`, `linear-issue-checklist`, PR/MR creation, merged PR/MR close-out, and pickup workflows.

### Process

1. **Identify the issue.**
   - Parse an issue ID or Linear URL from the prompt or active context.
   - Fetch the issue, current state, status type, title, description, and checklist.
   - If no issue is identifiable, ask for the issue ID.

2. **Resolve the target status.**
   - Use explicit user wording first:
     - "backlog", "park for later" → `Backlog`.
     - "todo", "next", "ready" → `Todo`.
     - "start", "working", "in progress", "picked up" → `In Progress`.
     - "review", "PR open", "MR open", "awaiting review" → `In Review`.
     - "done", "complete", "merged", "shipped" → `Done`.
     - "cancel", "drop", "won't do", "not needed" → `Canceled`.
   - If the status is only inferred from situation, apply monotonic workflow transitions (`In Progress`, `In Review`, `Done`) when evidence is clear; otherwise ask.
   - Never set `Triage`.

3. **Apply guardrails.**
   - Respect the never-downgrade rule by default.
   - If the user explicitly asks for a downgrade, explain the rule and ask for confirmation before writing.
   - `Canceled` is terminal: require explicit user wording or confirmation.
   - Skip terminal issues already `Done` or `Canceled` unless the user explicitly requests a supported change.

4. **Update status.**
   - If the user explicitly requested the status, update directly and report.
   - If the status was inferred, present the proposed change and apply only when the evidence is clear or the user confirms.
   - Report with the state-transition format: `Linear state: moved K-123 → In Review (was In Progress).`

5. **Checklist follow-up for review/done.**
   - When moving an issue to `In Review` or `Done`, always inspect the checklist.
   - If checklist items are clearly completed by the current work, compose with `linear-issue-checklist` to mark them done.
   - If the issue is marked `Done` and remaining checklist items are implementation acceptance criteria with no contrary evidence, mark them done unless the user says not to.
   - Leave ambiguous, canceled, or out-of-scope items untouched and report them.
   - Never silently cancel checklist items; cancellation requires explicit user wording.

### Key Rules

- **Fast path for explicit status.** If the user says exactly what state to use, do it without a planning detour.
- **Ask for ambiguity.** If the issue, target state, or terminal/cancel semantics are unclear, ask one focused question.
- **Checklist is part of close-out.** Always try checklist reconciliation when moving to `In Review` or `Done`.
- **Status only.** For title, description, labels, priority, or estimate changes, use `linear-issue-update`.

### Related Skills

- **`linear-issue-checklist`** — checklist reconciliation, especially when moving issues to `In Review` or `Done`.
- **`linear-issue-comment`** — deviations and findings comments.
- **`linear-issue-update`** — description or field edits.
- **`linear-project-match`** — project-wide state reconciliation from external evidence.
