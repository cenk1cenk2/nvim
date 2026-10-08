---
name: command-wt
description: command-wt Worktrunk (wt) is the default for creating, opening, listing, removing and pruning git worktrees, with raw git worktree as the fallback. Load before running `wt` or `git worktree`, or before creating or cleaning up a worktree for any task. Not for a plain branch without a worktree, or for committing, pushing or merging.
references:
  - ../references/agent/agent-worktrees.md
---

## Route

- **`wt` owns every worktree operation — create, open, list, remove, prune — whether or not an `agent-*` skill is loaded.**
- **`wt` owns the worktree lifecycle only.** Commits, pushes and merges go through `git-commit`, `git-push` and the platform's PR/MR skill; `wt merge` and `wt step commit|squash|rebase|push` stay the captain's tools.
- **`wt` places the tree** from the configured `worktree-path` template (`wt config show`). Address worktrees by branch and never pass a path.
- **Another repository is `wt -C <repo> …`**, never a `cd`. Cross-repo dispatch per `agent-worktrees`.
- **Read the path from the command's own `--format=json` output**, not from a follow-up listing.
- **Raw `git worktree` is the fallback** when `wt` does not resolve or cannot reach the repository; place the tree where the `worktree-path` template in `~/.config/worktrunk/config.toml` would, so `wt` finds it later. Say which form you used when you report a path.

## Commands

| Job | `wt` | Fallback |
|---|---|---|
| New branch and tree | `wt switch --create <branch> --base <base> --no-cd --format=json` | `git worktree add -b <branch> <dir> <base>` |
| Tree for an existing branch | `wt switch <branch> --no-cd --format=json` | `git worktree add <dir> <branch>` |
| Tree for a PR/MR | `wt switch pr:<N> --no-cd --format=json` (`mr:<N>` on GitLab) | fetch the head ref, then add |
| List | `wt list --format=json` (`--branches` adds tree-less branches) | `git worktree list --porcelain` |
| Remove | `wt remove <branch> --foreground --format=json` | `git worktree remove <path>` then `git branch -d <branch>` |
| Prune merged | `wt step prune --dry-run --format=json`, then `wt step prune --foreground` | `git worktree prune` (stale metadata only) |

## Gates

- **Reads never gate** — `list`, `config show`, a prune `--dry-run`.
- **Prune presents its dry-run first** and runs on approval — it removes trees and deletes branches in bulk.
- **Destructive flags need their own approval naming the target:** `-D` (unmerged branch), `-f` (dirty tree), `--clobber` (stale path at the target), and a lowered `--min-age`.
- **Project hooks run repository-supplied shell.** On an approval prompt or an `(approval required)` skip, show the commands and let the captain approve; `--yes`, `wt config approvals add` and `--no-hooks` only on their word.

## Failure Modes

- **No `--base`** — `--create` branches from the default branch, not `HEAD`. `@` is the current branch, `^` the default.
- **Background removal** — without `--foreground`, `wt remove` and `wt step prune` return before the tree is gone and failures land in `.git/wt/logs/`. Pass it whenever you verify or report.
- **Unmerged branch on remove** — kept; deleting it is `-D`, gated above.
- **Dirty tree on remove** — fails; surface it.
- **Processes in the tree** — `wt remove --reap` stops detached ones under it; terminal-holding processes are spared.
- **Prune skips a candidate** — younger than `--min-age` (default `1d`), dirty, locked, or awaiting hook approval. The age guard keeps a fresh tree that only looks merged; leave it.
- **`wt` not on `PATH`** — resolve it per `AGENTS.md` §IV mise before taking the fallback.
