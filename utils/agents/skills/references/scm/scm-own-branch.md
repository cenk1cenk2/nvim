# Own Branch

A standing exception the captain scoped: an agent rewrites and cleans up its own branches, worktrees and data without asking. It is the per-scope exception the central destructive-action gate allows, and it covers nothing outside the scope below.

## What counts as own

All of these hold:

- **Created by this agent, or by an agent in the same run** (a delegate, a plan layer), for the current work.
- **Not protected** — not the default branch, and not `main`, `master`, `rolling`, `develop` or `trunk`.
- **The remote carries no one else's commits** — `git log HEAD..@{u} --format='%an %ae'` shows only the agent's or the captain's commits, or nothing.

Data follows the same test: a worktree, scratch file or build output the agent created for this work.

Any condition fails, or you cannot tell, and it is not own — the normal gate applies.

## Free, no confirmation

- **Rewrite history** — rebase onto a moved base or trunk, `rebase --onto` to repair a stack, amend, squash fixups.
- **Resolve the conflicts a rebase raises**, keeping both sides' intent, then run the project's checks before pushing.
- **Push the rewrite with `--force-with-lease`** and report what it replaced: the old and the new head.
- **Clean up once the work is merged and finished** — remove the worktree, delete the branch locally and on the remote (`-D` included, since a squash merge leaves it looking unmerged to git), and delete the scratch data. Merged means its PR/MR merged; finished means its agent delivered and was collected.

## Still gated

- **Plain `--force`.** Never.
- **A conflict whose resolution is a design choice** — stop and present both sides.
- **Discarding uncommitted work** — a dirty-tree force-remove, `reset --hard` over local changes.
- **Deleting an own branch or its data before its PR/MR merged** — still open, closed unmerged, or never opened.
- **A bulk cleanup that also reaches what is not own** — present the dry-run.
