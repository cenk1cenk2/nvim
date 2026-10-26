---
name: agent-ahead
description: agent-ahead Toggleable mode that preps every next step ahead of time - branches, commits, pushes, drafted PR bodies, staged commands - and holds anything whose trigger would run against a dependency not yet landed. Use on "prep ahead", "stay ahead", "prep things ahead automatically". Not for pushing work through blockers or for firing gated steps.
disableModelInvocation: true
argumentHint: '[scope to stay ahead on]'
references:
  - ../references/mode-toggle.md
  - ../references/long-running-work.md
  - ../references/agent/agent-watchers.md
  - ../references/agent-owned.md
---

## Toggle

On/off mechanics per `mode-toggle`; state that spans turns is written durably per `long-running-work`.

- **On:** `/agent-ahead`, "prep ahead", "stay ahead", "prep things ahead automatically", "get ahead of it".
- **Off:** "stop prepping ahead", "drop ahead", "normal mode", any park signal, or the stated scope completing.
- **Survives disengage:** prepped branches, pushed branches without a PR, and the prep board. Say what is left staged.

## Layering

Ahead has no goal of its own and adds no blessing. It rides on whatever is driving — a plain task, `agent-bohrhammer`, `agent-bulldozer`, `agent-coordinator` — and changes one thing: the next steps are already built when their gate clears. The driving posture keeps its scope, plan and gates.

## The Ready Line

Every next step splits into prep, which runs now, and its trigger, which waits for the step's dependencies to land.

**Prep — always, without asking:**

- Worktree and branch, cut from the right base (stacked on an open prerequisite where the change needs its code).
- The change itself, committed, with the project's format, lint and validate passing.
- The PR/MR title and body drafted, the commit message written, the Linear trailer chosen.
- **Push the branch** when the push itself triggers nothing that reads the missing dependency.
- Verification commands, test Pods, watcher commands and the captain's runnable blocks, staged.
- Read-only lookups the next step needs: ids, ARNs, run ids, current versions.

**Hold — until the dependency has landed:**

- **Opening the PR/MR** when its CI, plan or preview reads something not yet merged, applied, written or released. A plan against an empty secret, a build pinned to an unpublished module version, a test against an undeployed service — each fails, and a failed check on an open PR misleads the reviewer.
- **Pushing**, on a repository where a branch push runs that pipeline itself (GitLab branch pipelines, a push-triggered workflow). Check the repository's CI rules before the first push; keep the branch local when they fire on push.
- Marking a draft ready, requesting review, retargeting a stack onto trunk, applying, merging, any external write.

**Landed means verified, not reported.** A merged PR whose apply has not finished has not landed; a secret with no `AWSCURRENT` version has not landed. Re-check the real state before releasing a hold.

## Process

1. **Map the dependencies.** For the scope, list each next step and what it reads that does not exist yet. State it in one line per item, and ask once when a dependency is unclear.
2. **Prep everything to its ready line.** Independent items in parallel; each in its own worktree per `agent-owned`.
3. **Arm a watcher on every hold** per `agent-watchers` — the merge, apply, release or write the item waits on. A hold with no watcher is a hold nobody will notice clearing.
4. **On wake, verify and release.** Re-check the dependency, rebase the prepped branch if its base moved, then fire the held trigger when the request already covers it (the user asked for the PR, the posture blessed it). Otherwise report it ready to fire in one line.
5. **Keep the board current** every turn something moves.

## The Prep Board

| Prepped | How far | Held on | Clears when | Fires |
|---|---|---|---|---|
| PR for [K-934 — Copy the credentials](<url>) | committed, pushed, no PR | [K-933 — Write the values](<url>) | the secret has an `AWSCURRENT` version (watcher armed) | open the PR, review its plan |
| label change | committed locally | apply of [#12267](<url>) | the apply run finishes | push, open the PR as ready |

- **How far** is honest: committed, pushed, drafted, diagnosed-only.
- **Held on** names the concrete dependency, and whether a machine or the captain clears it. A captain gate is asked now, not parked in the table.
- **Fires** is the exact action, so it lands without re-deriving anything.

## Example

**Trigger:** "/agent-ahead" while a global secret store PR is in review and its value is still unwritten.

1. Map: the dev general copy reads the global secret, so its plan fails until the value exists. The rewrite prefix needs the cache rule the copy creates.
2. Prep: branch and commit the general-stack copy, validate it, draft its PR body. Push it (GitHub runs nothing on a branch push); hold the PR. Commit the prefix change on its own branch; hold it locally.
3. Arm watchers on the store PR's merge and on the secret gaining a version.
4. The value lands: re-check `AWSCURRENT`, rebase onto main, open the PR, hand its plan to review.

**Result:** every step was built before its gate cleared, and no PR opened onto a check that was bound to fail.

## Key Principles

- Prep is free and reversible; firing early corrupts or misleads. Build right up to the line, never across it.
- A trigger is held while anything it reads has not landed — verified, not assumed.
- Push freely only where a push fires nothing.
- Every hold has a watcher; every prepped item is on the board.
- Ahead adds momentum to preparation only. It is never a blessing to open, apply or merge.
