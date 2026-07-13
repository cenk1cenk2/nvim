# Linear Issue Mandatory Fields

Every Linear issue MUST have these fields set. Do NOT create issues with missing fields — ask the user if unsure.

## Team

- **MANDATORY** — every issue MUST have a `team` set. The `team` field can NEVER be empty.
- Unless the user explicitly specifies a different team, ALWAYS use the current user's team (discovered during session initialization).
- If the user belongs to multiple teams and no team is specified, ASK which team to use.

## State

- **MANDATORY** — you MUST explicitly send `state` on EVERY `save_issue` call. The Linear API defaults to `Triage` which is WRONG.
- **Default for new issues:** `state: "Backlog"`. Ask the user about timing — if they want it in the current cycle, use `state: "Todo"`.
- **`Triage` is opt-in only** — never set it as a default or fallback. Use `Triage` ONLY when the user explicitly asks for it.
- **Field name:** Use `state`, NOT `status`.
- **Spelling:** `Canceled` (American, one 'l'). NOT `Cancelled`.
- **Valid values:** `Backlog`, `Todo`, `In Progress`, `In Review`, `Done`, `Canceled`.
- For state meanings and transition rules, see the `linear-issue-states` reference.

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

## Structural vs. Descriptive

**NEVER put relation information in issue descriptions.** Dependencies, blocking relationships, sub-issue links, and dependency chains belong in Linear's native fields — not in markdown.

| Information | Where to put it | Where NOT to put it |
|------------|-----------------|---------------------|
| "Issue A blocks Issue B" | `blocks` / `blockedBy` fields | ❌ "## Dependencies" section in description |
| "Issue A is a sub-issue of Issue B" | `parentId` field | ❌ "## Sub-issues" table in description |
| "Issue A is related to Issue B" | `relatedTo` field | ❌ "See also K-123" in description |
| Dependency chain ordering | `blockedBy` fields on each issue | ❌ "## Issue Order" or "## Dependency chain" in description |

The only exception is when a parent issue needs brief context about *why* sub-issues exist — not *what* they are or *how* they relate (Linear shows that natively). Use `## Thoughts` sections for rationale, not relation listings.

## Repository References

- When the repository is known, include it in the issue description (e.g., `**Repo:** path/to/repo`).
- When the repository has a Linear-connected GitLab or GitHub project, use `links` to attach the repo URL as a proper attachment instead of or in addition to inline text.
- Do NOT force a repo line when the repository is unknown or the issue spans manual work with no repo.
