# Agent Worktree Convention

All worktrees created by any `agents-*` skill MUST live in the active runtime's designated agent-worktrees directory — see the `provider-paths` reference (Claude Code: `<project>/.claude/worktrees/`; OpenCode: its native worktree dir; otherwise `<project>/.agents/worktrees/`). This is an absolute rule — use the one known location for the runtime and never scatter agent worktrees elsewhere in the filesystem.

## ⛔ Worktree isolation follows the SESSION's repo, not the task's repo

**`isolation: worktree` creates a worktree of the repository the session is running in — the cwd project — NOT the repository the delegated task targets.** In a multi-repo workspace those are frequently different, and then the agent lands in a worktree where **its target files do not exist**.

Concretely: a session running in `<repo-a>` delegates an edit that lives in `<repo-b>` and passes `isolation: worktree`. The agent is handed `<repo-a>/.claude/worktrees/agent-<id>/`, where none of its target paths exist. A careful agent reports the mismatch; a careless one edits the wrong tree or creates files that do not belong.

**So, before passing `isolation: worktree`:**

- **Confirm the task's repo IS the session's repo.** If it is not, do NOT rely on the flag.
- **For a cross-repo task, create the worktree yourself in the TARGET repo** per the Manual Fallback below, and pass its absolute path in the prompt under a `## Workspace` section telling the agent to `cd` there first. Dispatch without `isolation`.
- **Say which repo the work belongs to in the prompt**, explicitly. An agent that knows the target repo can recover from a wrong worktree; one that assumes will edit the wrong tree or create files that do not belong.
- **Verify after dispatch** where the branch and commit actually landed — check the target repo's `git worktree list` and `git branch`, not the agent's own account of it.

## Why a fixed worktrees directory

- **Harness convention.** If your runtime has a built-in worktree-isolation feature, it creates worktrees under a known directory by default; co-locating all agent worktrees there keeps everything in one place.
- **Inside the repo.** Worktrees live under the project root, making them easy to find, list (`ls .agents/worktrees/`), and prune.
- **Gitignored.** Assuming the worktrees directory (`.agents/` or `.claude/`) is in `.gitignore`, the worktrees don't pollute `git status` on the parent repo.
- **Predictable for scripts.** Tooling that cleans up stale worktrees, measures disk usage, or reports status knows exactly where to look.

## Naming

Format: `<role>-<short-id>`

- `role`: short description of what the agent does (`worker-1`, `task-02`, `review-fix`, `delegate`).
- `short-id`: 3-6 char random/hash suffix to avoid collisions across parallel runs (`a3f`, `b91c`, `c47`).

Examples: `worker-1-a3f`, `task-02-b91`, `review-fix-c47`, `delegate-d12`.

Keep names ≤ 64 chars total and use only letters, digits, dots, underscores, dashes.

## Verification (mandatory after dispatch)

When your subagent-dispatch tool returns a worktree path, verify it:

1. Is absolute.
2. Is in the runtime's agent-worktrees directory (per the `provider-paths` reference).

If verification fails, treat it as an error:

- Do NOT proceed with merge or review.
- Surface the unexpected path to the user.
- Manually recreate the worktree at the correct location (see Manual Fallback) and re-dispatch with the manual path.

## Manual Fallback

If your runtime's worktree-isolation returns a non-conforming path (or is unavailable for some reason):

1. Create the worktree yourself:
   ```
   git branch <branch-name>
   ```
   then via Bash:
   ```
   git worktree add .agents/worktrees/<name> <branch-name>
   ```
2. Dispatch the agent WITHOUT worktree isolation. Include the absolute worktree path in the prompt under a `## Workspace` section and instruct the agent to `cd` into it before any file operations.
3. Track the path yourself for later merge and cleanup.

## Cleanup

Once the agent's work is merged back to the original branch (or discarded):

```
git worktree remove .agents/worktrees/<name>
```

For `agents-plan`, cleanup happens during per-layer merges (both team and fire-and-forget modes). For `agents-delegate`, cleanup happens after the user's completion-handoff choice.

On `git worktree remove` failure (uncommitted changes, for example), surface the error to the user and let them decide whether to force-remove (`--force`) or keep the worktree for manual recovery.

## Gitignore

Ensure the worktrees directory (`.agents/worktrees/`, or `.claude/worktrees/` on Claude Code) is in the project's `.gitignore`. If not, the worktrees will pollute `git status`. This is a user-level concern — the skill should NOT modify `.gitignore` automatically, but MAY warn the user if the worktrees directory is not gitignored when a worktree is first created.

## Key Rule

**If a worktree is about to be created anywhere other than the agent worktrees directory, STOP.** This is non-negotiable. The rule exists to keep agent work contained and predictable. Every agent skill follows it.
