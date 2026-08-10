# Linear-Aligned Task Chunking

When the user provides Linear issues or a project as input to an agent workflow, align task splits with issue boundaries. This ensures each agent's commits can reference the correct Linear issue via commit trailers.

## Detection

Check the user's input for Linear context:

| Signal | Source | Action |
|--------|--------|--------|
| Issue IDs (`K-xxx`, `CLOUD-xxx`) | Direct mention, URLs, branch name. | Fetch each issue via the appropriate Linear MCP tool. |
| Project URL or name | User provides a Linear project. | Fetch project via `linear_*__get_project`, then list its issues via `linear_*__list_issues` (filter by project). |
| Multiple issues | User lists several issue IDs or URLs. | Fetch all issues. |

Use the `linear-prerequisite` reference deduction rules to determine the workspace (`linear-kilic` vs `linear-laravel`).

If no Linear context is detected, skip this reference entirely.

## Chunking Rules

### One issue → one task (default)

Map each Linear issue to exactly one agent task. This is the cleanest path — each agent commits with a trailer referencing its issue.

- Read each issue's title and description to understand scope.
- Use the issue scope to define the task's file boundaries.
- Include the issue ID in the agent's prompt (see Agent Prompt Addition below).
- If the task will create the single PR/MR that fully completes the issue, the final commit and PR/MR description should use `closes <ID>`.

### One issue → multiple tasks (large issue)

When a single issue is too large for one agent:

- Split into multiple tasks but assign the same issue ID to all of them.
- Each task's commits use `refs <ID>` (contributing, not closing).
- The final task's last commit uses `closes <ID>` only if all work for that issue is complete.
- Note in the task split table which tasks share an issue.

### Multiple issues → one task (small issues)

When several issues are small enough for a single agent:

- Group them into one task.
- Include all issue IDs in the agent's prompt.
- The agent commits per issue group — stage files related to one issue, commit with its trailer, then the next.
- If the changes are too intertwined to commit separately, use multiple trailers on a single commit.

### Project-level input

When the user provides a Linear project instead of individual issues:

1. Fetch the project and its issues.
2. Filter to actionable issues (`Todo`, `In Progress`, or `Backlog` if explicitly requested).
3. Present the issue list to the user — ask which issues to include and whether to add/remove any.
4. Apply the chunking rules above to the confirmed issue set.

## Agent Prompt Addition

Add a `## Linear Issue` section to each agent's prompt:

```
## Linear Issue

This task implements Linear issue <ID>: "<issue title>".
- Use `refs <ID>` in commit trailers for partial progress.
- Use `closes <ID>` in the final commit and PR/MR description when this is the single/final deliverable that fully resolves the issue.
- Do NOT use `#` prefix — write `refs K-219`, not `refs #K-219`.
```

For tasks with multiple issues:

```
## Linear Issues

This task covers multiple Linear issues:
- <ID-1>: "<title-1>"
- <ID-2>: "<title-2>"

Commit per issue where possible. Use `refs <ID>` for partial progress, `closes <ID>` only when this task or PR/MR fully resolves that issue.
```

## Task Split Table

Add an **Issue** column to the standard task split table:

| Agent | Task | Files (write) | Issue | Dependencies |
|-------|------|---------------|-------|-------------|
| 1 | Add token refresh | `src/auth/*` | K-219 | none |
| 2 | Update config parser | `src/config/*` | K-220 | none |
| 3 | Fix rate limiter | `src/api/rate.*` | K-221, K-222 | none |

## Completion Handoff

During the completion handoff (agent-completion reference):

- If all issues are resolved, each commit should already have the correct trailers from the agents.
- If the orchestrator creates a final combined commit instead, include trailers for all issues.
- When creating a PR/MR, include Linear trailers in the description: `closes <ID>` for issues fully resolved by that PR/MR, and `refs <ID>` for partial or related work.
