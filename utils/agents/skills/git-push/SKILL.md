---
name: git-push
description: Push the current branch to remote. Use when user says "push", "git push", "push this branch", "push my commits", or "push to origin". Verifies local state, reports what will be pushed, and pushes immediately (no extra approval — invoking the skill is the approval). Asks only on real blockers (diverged, behind, force, protected branches). Do NOT use for committing (git-commit), branch creation (git-branch), or opening PRs (github-pr-create, gitlab-mr-create).
argument-hint: "[optional: remote name or safety flag — e.g., 'upstream', '--force-with-lease']"
references:
  - ../references/present-first.md
  - ../references/scm-detect.md
---

## Git Push

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `scm-detect` reference for git MCP tools and CLI fallbacks

## Process

1. **Assess local state.**
   - Use `git status` to get the current branch.
   - Detect the upstream via the built-in `Bash` tool (there is no git MCP tool for this): `git rev-parse --abbrev-ref --symbolic-full-name @{u}`. A non-zero exit means the branch has no upstream yet.
   - If the working tree is dirty, note it in the report — `git push` carries only committed history. Do NOT prompt on this; just report. **Skip this note when invoked immediately after `git-commit` in the same turn** (see "Composing with Other Skills").

2. **Determine the remote target.**
   - Default to `origin`.
   - Honor an explicit user override (e.g., "push to upstream", "push to fork").
   - If multiple remotes exist and none is specified, confirm `origin` with the user before proceeding.

3. **Inspect divergence against the upstream.**
   - **No upstream (new branch):** plan a first push with `-u <remote> <branch>`. No extra confirmation needed.
   - **Ahead only:** plan a fast-forward push. No extra confirmation needed.
   - **Behind only:** **stop and ask.** The local branch is behind remote — pushing would fail. Tell the user to pull first (suggest `code-pull`). Do NOT auto-pull.
   - **Diverged (ahead + behind):** **stop and ask.** Offer options: rebase, merge, abort, `--force-with-lease` (only if the user explicitly asks).
   - **Up to date:** inform the user there is nothing to push and stop.

4. **List pending commits.**
   - Use `git log` to list commits between the upstream (or, for a new branch, an inferred base like the default branch) and `HEAD`.
   - Include commit count and subject lines in the final report.

5. **Safety checks (only these gate the push).**
   - **Refuse `--force` outright.** If the user asks for `--force`, push back and offer `--force-with-lease` instead.
   - **`--force-with-lease`** is used only when the user explicitly asks. Stop and confirm once before executing, with a one-line note on what gets overwritten.
   - **Protected-branch guard:** if the target branch is `main`, `master`, `rolling`, `develop`, or `trunk`, **stop and ask** for an explicit ack before pushing. This is the one mandatory confirmation on a branch that would otherwise be a happy-path push.

6. **Report and execute in a single step.**
   - On the happy path (no blocker, no protected branch, no force), print a short report block and immediately run the push:

     ```
     branch:    <current-branch>
     remote:    <remote>
     upstream:  <yes | set on push>
     commits:   <N>
                - <subject-1>
                - <subject-2>
     flags:     <none | -u>
     ```

   - Run `git push [flags] <remote> <branch>` via the built-in `Bash` tool (no tmux needed — the push is a quick operation with no long-running output to observe). On first push, include `-u` to set the upstream.
   - Capture the command output. On success, report the pushed ref and any hints printed by git (e.g., a GitHub/GitLab "create PR" URL). On failure, report the exact git error and stop — do not retry with different flags on your own.

7. **Confirm and suggest.**
   - One-line confirmation: what was pushed, where.
   - Passively mention follow-up skills when relevant: `github-pr-create` / `gitlab-mr-create` for opening a PR/MR. Do NOT auto-invoke them.

## Composing with Other Skills

This skill is composable — other skills can hand off to it once their work is done.

- **After `git-commit`:** when the user chains both (e.g., "commit and push", "git-commit git-push"), `git-commit` runs its full workflow (analyze → draft → approve → commit). On successful commit, control hands off to this skill, which starts at step 1 with the post-commit state. No shared tool state is required — this skill re-inspects the tree.
- **Skip the dirty-tree note in step 1** when called immediately after `git-commit` in the same turn — leftover untracked or deliberately-unstaged files are expected.
- **Never mix responsibilities.** This skill does not stage, commit, resolve conflicts, pull, or open PRs. Those stay with the dedicated skills (`git-commit`, `git-conflict`, `code-pull`, `github-pr-create`, `gitlab-mr-create`).

## Key Principles

- **Invoking the skill is the approval.** Do NOT ask for a separate "are you sure?" on the happy path — just report and push.
- **Ask only on real blockers.** Behind, diverged, `--force-with-lease`, protected-branch pushes. Everything else is automatic.
- **Never `--force`.** Only `--force-with-lease` on explicit user request.
- **Always list pending commits** in the report so the user sees what landed on remote.
- **Never auto-pull, auto-rebase, or auto-merge.** On divergence, ask.
- **Push only — no PR creation.** Suggest a PR skill after success; never auto-invoke.

## Examples

**User says:** "push"

1. `git status` → branch `feat/token-refresh-logic`, clean tree. Upstream is `origin/feat/token-refresh-logic`. Branch is 2 commits ahead, 0 behind.
2. Default remote: `origin`. No divergence blocker. No protected branch.
3. Report + execute in one go:

   > Pushing `feat/token-refresh-logic` → `origin` (fast-forward, 2 commits).
   >
   > ```
   > branch:    feat/token-refresh-logic
   > remote:    origin
   > upstream:  yes
   > commits:   2
   >            - feat(auth): add refresh token rotation
   >            - test(auth): cover refresh edge cases
   > flags:     none
   > ```

4. Run `git push origin feat/token-refresh-logic` via `Bash`. Success.
5. Confirm: "Pushed 2 commits to `origin/feat/token-refresh-logic`. Want to open a PR? (`github-pr-create`)"

---

**User says:** "push this, it's a new branch"

1. No upstream detected. Branch is 4 commits ahead of `origin/main`.
2. Report + execute:

   > First push — setting upstream to `origin/feat/webhook-retries`.
   >
   > ```
   > branch:    feat/webhook-retries
   > remote:    origin
   > upstream:  set on push
   > commits:   4
   >            - feat(webhooks): add retry queue
   >            - feat(webhooks): expose retry metrics
   >            - test(webhooks): cover retry backoff
   >            - docs(webhooks): document retry semantics
   > flags:     -u
   > ```

3. Run `git push -u origin feat/webhook-retries` via `Bash`. Success.
4. Confirm: "Pushed and set upstream. 4 commits on `origin/feat/webhook-retries`."

---

**User says:** "push, my branch diverged"

1. Branch is 2 ahead and 3 behind. **Blocker — stop and ask.**
2. Report without executing:

   > Branch is 2 commits ahead and 3 commits behind `origin/fix/auth-boundary`. A plain push will fail. How would you like to proceed?
   >
   > - **Rebase onto remote** — replay your commits on top, then push.
   > - **Merge remote in** — merge `origin/fix/auth-boundary` into your branch, then push.
   > - **`--force-with-lease`** — overwrite remote with your local branch (destroys the 3 remote commits).
   > - **Abort** — do nothing.

3. Wait for user choice. If rebase/merge, note this skill does not rebase/merge — ask the user to do it locally and invoke `git-push` again. If `--force-with-lease`, confirm once (safety check), then execute with the flag.

---

**User says:** "push to main" (protected branch)

1. Current branch is `main`. Clean tree. Ahead by 1 commit. **Protected-branch guard — stop and ask.**
2. Ask:

   > Current branch is `main` (protected). Push 1 commit directly?
   >
   > ```
   > branch:    main
   > remote:    origin
   > commits:   1
   >            - fix: patch critical typo in README
   > ```

3. User confirms → execute push via `Bash` → confirm.

---

**User says:** "commit and push this"

1. Both `git-commit` and `git-push` load.
2. `git-commit` runs its full workflow: status check → stage → diff analysis → draft message → approve → commit.
3. After `git-commit` reports the new commit hash, control hands off.
4. `git-push` starts at step 1. Skips the dirty-tree note (same turn as commit). No blockers.
5. Report + execute in one go (no separate approval — the initial "commit and push" already said push).
6. Confirm: "Committed and pushed. 1 commit on `origin/<branch>`."
