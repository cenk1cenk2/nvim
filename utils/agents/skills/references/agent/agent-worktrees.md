# Agent Worktree Convention

**`wt` (worktrunk) is the preferred tool for any worktree an `agent-*` skill creates or removes itself.** It derives the path from a configured template, addresses worktrees by branch name, and removes the branch with the worktree. Raw `git worktree` is the fallback, for when `wt` is not on `PATH` or cannot reach the target repository. Check `command -v wt` once before creating anything, and say which form you used when you report a path.

**Two different things create agent worktrees, and only one of them is yours to place:**

| Creator | Tool | Location |
|---|---|---|
| A skill creating one itself | `wt switch --create` | whatever `wt` computes; never override it |
| The runtime's own isolation flag | the harness | harness-controlled — verify the path it returns |

For a harness-created worktree, and for the fallback form, the location is the active runtime's agent-worktrees directory per `provider-paths` (Claude Code: `<project>/.claude/worktrees/`; OpenCode: its native worktree dir; otherwise `<project>/.agents/worktrees/`). Never scatter agent worktrees elsewhere in the filesystem.

## Worktree isolation follows the SESSION's repo, not the task's repo

**`isolation: worktree` creates a worktree of the repository the session is running in — the cwd project — NOT the repository the delegated task targets.** In a multi-repo workspace those are frequently different, and then the agent lands in a worktree where **its target files do not exist**.

Concretely: a session running in `<repo-a>` delegates an edit that lives in `<repo-b>` and passes `isolation: worktree`. The agent is handed `<repo-a>/.claude/worktrees/agent-<id>/`, where none of its target paths exist. A careful agent reports the mismatch; a careless one edits the wrong tree or creates files that do not belong.

**So, before passing `isolation: worktree`:**

- **Confirm the task's repo IS the session's repo.** If it is not, do NOT rely on the flag.
- **For a cross-repo task, create the worktree yourself in the TARGET repo** per Creating a Worktree Yourself below, and pass its absolute path in the prompt under a `## Workspace` section telling the agent to `cd` there first. Dispatch without `isolation`.
- **Say which repo the work belongs to in the prompt**, explicitly. An agent that knows the target repo can recover from a wrong worktree; one that assumes will edit the wrong tree or create files that do not belong.
- **Verify after dispatch** where the branch and commit actually landed — check the target repo's `git worktree list` and `git branch`, not the agent's own account of it.

## Why a managed location

- **One tool owns the path.** `wt` computes it from a single configured template, so every worktree lands in the same shape without any skill hardcoding a directory.
- **Inside the repo.** Worktrees live under the project root, making them easy to find, list (`wt list`), and prune.
- **Gitignored.** Assuming the worktrees directory is in `.gitignore`, the worktrees don't pollute `git status` on the parent repo.
- **Predictable for scripts.** Tooling that cleans up stale worktrees, measures disk usage, or reports status knows exactly where to look — and `wt list --format=json` reports paths without parsing them out of prose.

## Naming

**Under `wt` the branch name is the identity** — the path derives from it, so name the branch and let `wt` place the directory.

Format: `<role>-<short-id>`

- `role`: short description of what the agent does (`worker-1`, `task-02`, `review-fix`, `delegate`).
- `short-id`: 3-6 char random/hash suffix to avoid collisions across parallel runs (`a3f`, `b91c`, `c47`).

Examples: `worker-1-a3f`, `task-02-b91`, `review-fix-c47`, `delegate-d12`.

Keep names ≤ 64 chars total and use only letters, digits, dots, underscores, dashes.

## Verification (mandatory after dispatch)

When your subagent-dispatch tool returns a worktree path, verify it:

1. Is absolute.
2. Is where its creating tool was meant to put it — `wt list` for a `wt`-created worktree, the runtime's agent-worktrees directory (per `provider-paths`) for a harness-created or fallback one.

If verification fails, treat it as an error:

- Do NOT proceed with merge or review.
- Surface the unexpected path to the user.
- Manually recreate the worktree at the correct location (see Creating a Worktree Yourself) and re-dispatch with the manual path.

## Creating a Worktree Yourself

When your runtime's worktree-isolation returns a non-conforming path, is unavailable, or the task targets a repository other than the session's:

1. Create the worktree.

   **Preferred:**
   ```
   wt switch --create <branch> --base @ --no-cd
   ```
   `--no-cd` leaves the calling shell where it is, which is what scripted creation wants; `wt list --format=json` reports the resulting path. **Name the base explicitly** — with no `--base`, `wt switch --create` branches from the default branch rather than current `HEAD`, silently discarding the state a dependent task needs. `@` is the shortcut for the current branch.

   **Fallback:**
   ```
   git branch <branch-name>
   git worktree add <agent-worktrees-dir>/<name> <branch-name>
   ```
2. Dispatch the agent WITHOUT worktree isolation. Include the absolute worktree path in the prompt under a `## Workspace` section and instruct the agent to `cd` into it before any file operations.
3. Track the path yourself for later merge and cleanup.

## Cleanup

Once the agent's work is merged back to the original branch (or discarded):

```
wt remove <branch>            # preferred
git worktree remove <path>    # fallback
```

`wt remove` deletes the branch **only if it is merged** — an abandoned branch survives unless you pass `-D`, and `--no-delete-branch` keeps one deliberately. The fallback removes the worktree alone, so delete the branch yourself when that matters.

For `agent-plan`, cleanup happens during per-layer merges (both team and fire-and-forget modes). For `agent-delegate`, cleanup happens after the user's completion-handoff choice.

On removal failure (uncommitted changes, for example), surface the error to the user and let them decide whether to force-remove (`-f`) or keep the worktree for manual recovery. When the worktree ran a dev server or watcher — a `post-start` hook commonly does — `wt remove --reap` terminates processes whose working directory is under it.

## Gitignore

Ensure the worktrees directory is in the project's `.gitignore` — `wt`'s configured path, `.agents/worktrees/`, or `.claude/worktrees/` on Claude Code, whichever applies. If not, the worktrees will pollute `git status`. This is a user-level concern — the skill should NOT modify `.gitignore` automatically, but MAY warn the user if the worktrees directory is not gitignored when a worktree is first created.

## Key Rule

**Create it with `wt` wherever `wt` is available, and never override where it places the result.** On the fallback path, a worktree about to be created anywhere other than the agent worktrees directory is a STOP. This is non-negotiable. The rule exists to keep agent work contained and predictable. Every agent skill follows it.
