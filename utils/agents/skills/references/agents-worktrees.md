# Agent Worktree Convention

All worktrees created by any `agents-*` skill MUST live inside `.claude/worktrees/` within the current project. This is an absolute rule — no agent worktree is allowed to exist anywhere else in the filesystem.

## Why `.claude/worktrees/`

- **Harness convention.** Claude Code's built-in `EnterWorktree` tool creates worktrees here by default; co-locating agent worktrees keeps everything in one place.
- **Inside the repo.** Worktrees live under the project root, making them easy to find, list (`ls .claude/worktrees/`), and prune.
- **Gitignored.** Assuming `.claude/` (or `.claude/worktrees/`) is in `.gitignore`, the worktrees don't pollute `git status` on the parent repo.
- **Predictable for scripts.** Tooling that cleans up stale worktrees, measures disk usage, or reports status knows exactly where to look.

## Naming

Format: `<role>-<short-id>`

- `role`: short description of what the agent does (`worker-1`, `task-02`, `review-fix`, `delegate`).
- `short-id`: 3-6 char random/hash suffix to avoid collisions across parallel runs (`a3f`, `b91c`, `c47`).

Examples: `worker-1-a3f`, `task-02-b91`, `review-fix-c47`, `delegate-d12`.

Keep names ≤ 64 chars total (matches `EnterWorktree`'s constraint) and use only letters, digits, dots, underscores, dashes.

## Verification (mandatory after dispatch)

When the `Agent` tool returns a worktree path, verify it:

1. Is absolute.
2. Starts with `<project_root>/.claude/worktrees/`.

If verification fails, treat it as an error:

- Do NOT proceed with merge or review.
- Surface the unexpected path to the user.
- Manually recreate the worktree at the correct location (see Manual Fallback) and re-dispatch with the manual path.

## Manual Fallback

If `isolation: "worktree"` on the `Agent` tool returns a non-conforming path (or is unavailable for some reason):

1. Create the worktree yourself:
   ```
   git__git_create_branch <branch-name>
   ```
   then via Bash:
   ```
   git worktree add .claude/worktrees/<name> <branch-name>
   ```
2. Dispatch the agent WITHOUT `isolation: "worktree"`. Include the absolute worktree path in the prompt under a `## Workspace` section and instruct the agent to `cd` into it before any file operations.
3. Track the path yourself for later merge and cleanup.

## Cleanup

Once the agent's work is merged back to the original branch (or discarded):

```
git worktree remove .claude/worktrees/<name>
```

For `agents-anonymous` and `agents-team`, cleanup happens during the merge step. For `agents-sequential`, cleanup is optional (user-chosen). For `agents-delegate`, cleanup happens after the user's completion-handoff choice.

On `git worktree remove` failure (uncommitted changes, for example), surface the error to the user and let them decide whether to force-remove (`--force`) or keep the worktree for manual recovery.

## Gitignore

Ensure `.claude/` or `.claude/worktrees/` is in the project's `.gitignore`. If not, the worktrees will pollute `git status`. This is a user-level concern — the skill should NOT modify `.gitignore` automatically, but MAY warn the user if `.claude/worktrees/` is not gitignored when a worktree is first created.

## Key Rule

**If a worktree is about to be created anywhere other than `.claude/worktrees/`, STOP.** This is non-negotiable. The rule exists to keep agent work contained and predictable. Every agent skill follows it.
