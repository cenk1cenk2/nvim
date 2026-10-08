# Agent Worktree Convention

**Every agent worktree is created and removed through `command-wt` — Load it before the first worktree command.** It owns the commands, flags, fallback and gates; this reference owns how agents are placed in worktrees and how they share them.

**The runtime's own worktree isolation is not used.** Claude Code's `isolation: "worktree"`, OpenCode's workspace worktrees and Codex's `--worktree` each branch from a base of their choosing, place the tree where `wt` cannot see it, and only Claude Code can be redirected. One mechanism on every runtime keeps every tree in `wt list`, on the base you named, in the repository the task targets.

## Dispatching Into a Worktree

1. **Create the worktree in the TARGET repository** per `command-wt` — `-C <repo>` when that is not the session's repository, and `--base @` whenever the agent needs the current `HEAD`. Take the absolute path from the command's JSON output.
2. **Dispatch without the runtime's isolation flag.** Put the path in the prompt under a `## Workspace` section, tell the agent to `cd` there before any file operation, and name the repository the work belongs to.
3. **Track the branch and path yourself** for merge and cleanup.
4. **Verify after the agent reports** — the commits sit on the worktree's branch in the target repository (`wt list --format=json`, `git log <branch>`), not on the agent's account of it.

## One worktree, one LIVE agent

**Exclusivity is about concurrency, not ownership for life.** While an agent is working in a worktree that tree is its alone: no second agent pointed at it, no second unit started in it. Two writers in one tree clobber each other and neither reports it.

**Once its agent has delivered and been collected, the tree is free** — reuse it for the next unit, hand it to another agent, or remove it. A finished worktree held out of use is just a stale branch. The check before reuse is the roster per `agent-roster`, not the filesystem: reuse a tree whose agent's report is collected, never one whose row still reads running or uncollected.

**Reuse and re-steering pair naturally.** Where the agent that built the tree is still reachable, giving it the next unit in that same tree keeps both the worktree and the context that produced it.

## Naming

**The branch name is the identity** — `wt` derives the path from it, so name the branch and let `wt` place the directory.

Format: `<role>-<short-id>`

- `role`: short description of what the agent does (`worker-1`, `task-02`, `review-fix`, `delegate`).
- `short-id`: 3-6 char random/hash suffix to avoid collisions across parallel runs (`a3f`, `b91c`, `c47`).

Examples: `worker-1-a3f`, `task-02-b91`, `review-fix-c47`, `delegate-d12`.

Keep names ≤ 64 chars total and use only letters, digits, dots, underscores, dashes.

## Cleanup

Once the agent's work is merged back to the original branch (or discarded), remove the worktree per `command-wt`.

For `agent-plan`, cleanup happens during per-layer merges (both team and fire-and-forget modes). For `agent-delegate`, cleanup happens after the user's completion-handoff choice.

On removal failure (uncommitted changes, for example), surface the error to the user and let them decide whether to force-remove or keep the worktree for manual recovery.

## A Worktree You Did Not Create

A tree under a runtime's native location (per `provider-paths`) came from something outside this convention — a manual flag or a tool call. Report it with its branch and base, and let the captain decide whether to keep, merge or remove it; never adopt it as an agent workspace silently.

## Gitignore

The worktrees directory must be gitignored, or the worktrees pollute `git status`. This is a user-level concern — warn when it is not ignored on the first create; never edit `.gitignore` for it.
