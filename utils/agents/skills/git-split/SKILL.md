---
name: git-split
description: 'git-split Break a large change set - uncommitted tree, branch commits, or an open PR/MR - into smaller focused pieces, each on its own branch/commit with optional push and PR/MR. Triggers: "split this PR/MR/branch", "break into smaller PRs", "smaller chunks". Do NOT use to commit as-is (git-commit), create a single branch (git-branch), or rewrite a PR/MR description (github-pr-create, gitlab-mr-create).'
disableModelInvocation: true
argumentHint: "[optional: slicing hint — e.g., 'by feature', 'separate refactor and feature', 'by file']"
references:
  - ../references/scm-detect.md
  - ../references/output-diff.md
---

## Git Break

## Context

`git-split` is a **delegation orchestrator**. It does not create branches, commit, push, or open PRs/MRs itself — it plans the split and then delegates each step to the dedicated skills:

| Slice action | Delegated skill |
|---|---|
| Create branch | `git-branch` |
| Stage + commit | `git-commit` |
| Push branch | `git-push` |
| Open PR/MR | `github-pr-create` / `gitlab-mr-create` |

The skill handles three input modes — uncommitted tree, branch commits ahead of base, open PR/MR — and any combination of them.

## Process

1. **Detect input mode and SCM platform.**
   - `git status` for current branch and working-tree state.
   - Detect the default/base branch (try `git symbolic-ref refs/remotes/origin/HEAD` via CLI; fall back to common names: `main`, `master`, `rolling`, `develop`, `trunk`).
   - `git log <base>..HEAD` to enumerate commits ahead of base.
   - Detect the SCM platform and run local git per `scm-detect`, then look up an open PR/MR for the current branch (`github__list_pull_requests` with `head: owner:branch, state: open` or `gitlab__list_merge_requests` with `source_branch, state: opened`).
   - Categorize: `dirty-tree`, `commits-ahead`, `open-pr-mr`, or a combination. Record commit SHAs and changed-file paths.

2. **Surface the state and ask for split intent.**
   - Report what was found (branch, base, commit count, modified file count, PR/MR if any) in a short summary.
   - Ask the user for the slicing axis if not given via `argumentHint`. Common axes:
     - **By concern** — refactor / feature / tests / docs / fix.
     - **By feature area** — auth / api / config / ui / etc.
     - **By commit groups** — pick which commits belong together.
     - **By file area** — group by directory/module.
   - Keep this conversation short — one round of clarification, then proceed.

3. **Read diffs and group changes.**
   - For tree-based input: `git diff`, `git diff --staged`.
   - For commit-based input: `git diff <base>..HEAD` and `git show <sha>` per commit when needed.
   - For PR/MR input: `github__pull_request_read` (`get_diff`) or `gitlab__get_merge_request_diffs`.
   - Group changes per the chosen axis. Order slices by dependency (refactors before features, tests after the feature they exercise).

4. **Draft the split plan.**
   - For each slice produce:
     - `name` — kebab-case description (`git-branch` will pick the prefix).
     - `base` — default to the original base branch (parallel, independently mergeable). Stack only if the user explicitly asks.
     - `source` — for commit-based input: list of commit SHAs. For tree-based input: list of file paths or hunk ranges. Note any file that requires partial splitting.
     - `summary` — one line describing the slice.
     - `actions` — `branch` (always), `commit` (always), and optional `push`, `pr-mr` based on user opt-in.
   - Ask once globally during this step whether to push all slices and whether to draft PRs/MRs for all slices. The user can override per slice during iteration.

5. **Present the split plan.**
   - Present per `output-diff` — one chunk per slice with reasoning + a content block listing the slice metadata.
   - Single approval gate covers the entire plan.

   Example chunk:

   > Auth refactor lands first — extracts the token validator so the feature slice has a clean seam to land on.
   >
   > ```
   > slice 1/3:
   > name:    refactor-token-validator
   > base:    main
   > source:  src/auth/validator.ts, src/auth/types.ts
   > summary: extract token validator into its own module
   > actions: branch, commit, push, pr
   > ```

6. **Iterate** based on user feedback. Adjust slices, change order, drop or merge slices. Do NOT proceed to step 7 until the user explicitly approves.

7. **Pre-flight safety.**
   - Record the original branch's HEAD SHA so the user can recover (`git rev-parse HEAD`).
   - If the working tree is dirty AND the input includes commits-ahead, stash before any branch creation; restore between slices as needed.
   - Verify slice coverage: diff the union of all slice contents against the original change set. If anything is unaccounted for, flag and ask before proceeding.

8. **Execute per slice in dependency order.**
   - **Branch** — delegate to `git-branch`. Pass the slice name and base. Sticky-style applies — slices share a prefix across the run.
   - **Apply content:**
     - Commit-based input → cherry-pick the slice's commit SHAs onto the new branch.
     - Tree-based input → checkout slice files from the source branch (`git checkout <source-branch> -- <paths>`) or apply hunks via a saved patch (`git apply`). Partial-file splits use targeted patches built from the diff analysis.
   - **Commit** — delegate to `git-commit`. For cherry-pick paths where messages already exist, reuse them and skip the draft step unless the user requested a rewrite.
   - **Push** — delegate to `git-push` only when the slice opted in.
   - **PR/MR** — delegate to `github-pr-create` / `gitlab-mr-create` only when the slice opted in. Platform is routed via `scm-detect`.
   - After each slice, return to the original branch (or stay on the slice if the user wanted a stack).

9. **Final report.**
   - List each slice branch with: name, base, commit count, pushed (y/n), PR/MR URL (if created).
   - Print the original branch HEAD SHA in case the user wants to discard or reset the original.
   - Suggest follow-up actions on the original PR/MR when one exists (mark draft, close, supersede). Do NOT execute these actions — the user decides.

## Key Principles

- **One concern per slice.** A "refactor + feature" PR becomes two slices.
- **Slices stand alone.** Each should compile and pass tests independently when possible.
- **Default to parallel branches off the original base.** Stacking is opt-in only.
- **Preserve the original.** Never reset, force-push, or delete the source branch automatically. The original PR/MR stays untouched unless the user explicitly asks otherwise.
- **Push and PR/MR are opt-in.** Defaults are branch + commit only. Ask once globally; allow per-slice overrides.
- **Coverage check is mandatory.** Before executing, verify the union of slices equals the original change set.
- **Delegate, don't duplicate.** All branch / commit / push / PR / MR work goes through the dedicated skills.

## Composing with Other Skills

This skill is the **caller** in a delegation chain. The composed skills run their full workflows (analyze → draft → approve → act) for each slice.

- **`git-branch`** — branch creation per slice. Sticky prefix carries across slices.
- **`git-commit`** — commit drafting per slice. Reuse cherry-picked messages where applicable.
- **`git-push`** — push per slice (opt-in).
- **`github-pr-create` / `gitlab-mr-create`** — draft PR/MR per slice (opt-in). Platform selected via `scm-detect`.

**Conflict with `git-manual`.** `git-manual` suppresses branch / commit / push / PR-MR creation — the exact opposite of this skill's purpose. If `git-manual` is active when `git-split` is invoked, surface the conflict and ask the user before proceeding. Do NOT silently override.

## Examples

**User says:** "break this up" (working tree has 6 modified files spanning `src/auth/`, `config/`, and `test/`)

1. Detect: clean commit history, dirty tree, no PR. Branch `main`.
2. Surface state: "6 modified files: 3 in `src/auth/`, 2 in `config/`, 1 in `test/`. No commits ahead. No open PR. Slice axis?"
3. User: "by concern".
4. Group: auth feature (3 files) → config cleanup (2 files) → tests-for-auth (1 file).
5. Present plan with 3 chunks. Ask: "push + PR all?" User: "branch and commit only".
6. User approves.
7. Pre-flight: stash unsaved hunks, record HEAD SHA.
8. Slice 1: `git-branch feature/auth-token-refresh` from `main`, checkout 3 auth files, `git-commit` (drafted message). Return to original.
9. Slice 2: `git-branch chore/config-cleanup` from `main`, checkout 2 config files, `git-commit`. Return.
10. Slice 3: `git-branch test/auth-token-refresh` from `main`, checkout test file, `git-commit`. Return.
11. Final report: 3 branches + 3 commits, no pushes, no PRs. Original HEAD SHA listed.

---

**User says:** "split this branch by concern, push everything" (8 commits ahead of `main`, no PR)

1. Detect: 8 commits ahead, clean tree, no PR.
2. Surface state. User confirms axis: by concern.
3. Read each commit via `git show`. Group: 3 commits = refactor → 4 commits = feature → 1 commit = docs.
4. Present 3 slices. User opts in for `push` globally, declines PRs. Approve.
5. Slice 1: `git-branch refactor/extract-token-validator` from `main`, cherry-pick 3 commits, reuse messages, `git-push`.
6. Slice 2: `git-branch feat/token-refresh` from `main`, cherry-pick 4 commits, `git-push`.
7. Slice 3: `git-branch docs/auth-token-flow` from `main`, cherry-pick 1 commit, `git-push`.
8. Final report: 3 branches pushed. Original branch untouched. Suggest deleting the original branch when ready.

---

**User says:** "split this PR into 3, draft PRs for each" (open GitHub PR with mixed refactor + feature + tests)

1. Detect: GitHub, open PR #142, 12 commits, 14 files.
2. Read PR diff via `github__pull_request_read get_diff`. Surface state.
3. User confirms 3-way split by concern.
4. Group commits and files into 3 slices, ordered: refactor → feature → tests.
5. Present plan. User opts in for push + PR globally. Approve.
6. Slice 1: `git-branch` → cherry-pick refactor commits → `git-commit` (reuse messages) → `git-push` → `github-pr-create` (drafts and presents title + description, user approves, PR created).
7. Slice 2: same flow for the feature.
8. Slice 3: same flow for tests.
9. Final report: 3 new PRs with URLs. PR #142 left untouched. Suggest marking #142 as draft or closing it as superseded.
