# Linear Issue Mandatory Fields

Every Linear issue MUST have these fields set. Do NOT create issues with missing fields — ask the user if unsure.

## Team

- **MANDATORY** — every issue MUST have a `team` set. The `team` field can NEVER be empty.
- Unless the user explicitly specifies a different team, ALWAYS use the current user's team (discovered during session initialization).
- If the user belongs to multiple teams and no team is specified, ASK which team to use.

## State

- **MANDATORY — ALWAYS `backlog`** — EVERY issue MUST be created with `{"state": "backlog"}`.
- The Linear API defaults to `triage` which is WRONG. You MUST explicitly send `"state": "backlog"` on EVERY `save_issue` call.
- The ONLY exception is if the user EXPLICITLY says to use a different state (e.g., "put this in triage").
- If the user says nothing about state, it is `backlog`. NO EXCEPTIONS.

## Labels, Estimate, Priority

- **MANDATORY** — every issue MUST have `labels`, `estimate`, and `priority` set.
- `priority`: 0=None, 1=Urgent, 2=High, 3=Normal, 4=Low.
- `estimate`: Use the team's estimation scale.
- `labels`: At minimum one label categorizing the issue type. **MUST be from the fetched label list — NEVER invent labels.**

## Assignee

- Always assign issues to the current user unless the user specifies otherwise.

## Relations

When creating multiple related issues or working with projects, ALWAYS set proper relations:

- Use `blocks` / `blockedBy` to express dependency order between issues.
- Use `relatedTo` for issues that are connected but not blocking each other.
- Use `parentId` for sub-issues that belong to a parent issue.
- When creating a set of issues for a project, think through the dependency graph and set blocking relations so the work order is clear.
