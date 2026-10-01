---
name: command-wt
description: command-wt Worktrunk (wt) owns creating, listing and removing git worktrees, with raw git worktree as the fallback. Load before running `wt` or `git worktree`, or before creating a worktree for any task. Not for creating a plain branch without a worktree.
references:
  - ../references/agent/agent-worktrees.md
---

## Route

- **`wt` owns every worktree operation — create, list, remove — whether or not an `agent-*` skill is loaded.**
- **Raw `git worktree` is the fallback** when `command -v wt` finds nothing or `wt` cannot reach the repository. It leaves the branch behind on removal, so delete that branch yourself.
- Say which form you used when you report a path.
- Placement, naming, flags, verification and cleanup per `agent-worktrees`.

## Commands

| Job | `wt` | Fallback |
|---|---|---|
| Create | `wt switch --create <branch> --base <base> --no-cd` | `git branch <branch>` then `git worktree add <dir> <branch>` |
| List | `wt list --format=json` | `git worktree list` |
| Remove | `wt remove <branch>` | `git worktree remove <path>` then `git branch -d <branch>` |

## Failure Modes

- **No `--base`** — `wt switch --create` branches from the default branch, not `HEAD`; always name the base (`@` is the current branch).
- **Unmerged branch on remove** — `wt remove` keeps it; `-D` deletes it and is a destructive action that needs its own approval.
- **Removal fails on uncommitted changes** — surface it; force (`-f`) only on the user's word.
- **A dev server or watcher runs in the tree** — `wt remove --reap` stops processes under it.
- **`wt` not on `PATH`** — resolve it per `AGENTS.md` §IV mise before taking the fallback.
