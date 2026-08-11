---
name: git-commit
description: git-commit Commit current changes as conventional commits, or split them into scoped commits on this branch; analyses the diff and commits after approval, amending its own unshared commits where right. Use on "commit this", "split into commits". Not for splitting work across separate branches or PRs, writing a PR/MR description, or resolving conflicts.
argumentHint: '[optional: type or message hint - e.g. ''fix'', ''feat: add retry'']'
references:
  - ../references/present-first.md
  - ../references/scm/scm-detect.md
  - ../references/scm/commit-style.md
  - ../references/scm/commit-trailers.md
  - ../references/scm/commit-trailers-github.md
  - ../references/scm/commit-trailers-gitlab.md
  - ../references/scm/commit-trailers-linear.md
  - ../references/output-diff.md
  - ../references/scm/release-convention.md
---

## Git Commit

Posture: `present-first`.
## Process

1. **Assess the working tree.**
   - Detect the platform and branch, and run local git, per `scm-detect`.
   - Use `git status` to check staged, unstaged, and untracked files.
   - If nothing is staged and nothing is modified, inform the user and stop.

2. **Handle staging.**
   - If changes are already staged — proceed to step 3.
   - If nothing is staged but there are unstaged/untracked changes:
     - **Default (no grouping requested):** stage everything with `git add` using path `.`. No need to list or confirm individual files.
     - **Grouped commits requested:** skip to step 2a instead.
   - Stage files via `git add` (path `.` for default, or individual paths for grouped commits).
   - After staging, re-check with `git diff --staged` to confirm what will be committed.

2a. **Grouped commits (multi-commit workflow).**
    - Triggered when the user explicitly asks to split changes into multiple commits (e.g., "commit these separately", "group into multiple commits", "split this into commits by concern").
    - **Different tasks are different commits.** Changes serving unrelated concerns belong in separate commits, not one blob — group by task/concern and give each its own conventional message.
    - Analyze all unstaged/untracked changes and propose logical groups based on:
      - File proximity (same directory or module).
      - Change purpose (feature vs fix vs refactor).
      - User-provided grouping hints.
    - Present the proposed groups to the user for approval. Adjust grouping based on feedback.
    - For each approved group:
      1. Stage only that group's files via `git add` with individual file paths.
      2. Continue to step 3 (analyze) → step 4 (draft message) → step 5 (present) → step 6 (commit).
      3. After committing, return here for the next group.
    - Repeat until all groups are committed.

3. **Analyze the staged changes.**
   - Read the staged diff via `git diff --staged`.
   - Read recent commit history via `git log` (last 5-10 commits) to understand context and match existing message style.
   - If the diff is large, read the changed files for surrounding context to understand the intent.

4. **Draft the commit message.**
   - Determine the commit **type** per `commit-style`, based on the nature of the changes:
     - `feat` — new feature or capability.
     - `fix` — bug fix or correction of wrong behavior.
     - `refactor` — restructuring without behavior change.
     - `perf` — performance improvement.
     - `docs` — documentation only.
     - `test` — adding or updating tests.
     - `chore` — maintenance, dependency updates, tooling.
     - `build` — build system or external dependency changes.
     - `ci` — CI/CD pipeline changes.
     - `style` — formatting, whitespace, missing semicolons (no logic change).
     - `revert` — reverting a previous commit.
   - If the user provided a hint (e.g., "fix" or "feat: add retry"), use it as a starting point.
   - **Release automation (when detected).** Per `release-convention`, if the repo releases from commits (release-please / semantic-release), the **type drives the bump** — `feat` (minor) vs `fix`/`perf` (patch) vs other (no release) — so choose it deliberately. If the repo uses changesets, the commit does not set the version — remind the user a `.changeset/*.md` is needed and offer to add one.
   - Determine the **scope** (optional) — the area of the codebase affected (e.g., `auth`, `api`, `config`).
   - Write the **subject line** — imperative mood, ≤50 chars preferred, 72 hard cap, no trailing period.
   - **Body** — by default, draft a subject-only commit. Add a body only when:
     - The user explicitly requests a description/body (e.g., "commit with description", "add details", "verbose commit").
     - The change is a security fix, data migration, or revert (per `commit-style`).
     - The user explicitly flags a breaking change (see below).
   - **Breaking changes** — include when the user explicitly says so (e.g., "breaking change", "this is breaking", "commit with breaking change"), or when the repo has commit-driven release automation and the change is genuinely breaking (flag it and propose the markers — an unmarked breaking change ships as a wrong version bump). When flagged:
     - Append `!` after the scope in the subject line: `feat(api)!: rename /v1/orders to /v1/checkout`.
     - Add a `BREAKING CHANGE:` trailer in the footer describing what breaks and the migration path.
     - Always include a body explaining the breaking change even if the user didn't request a verbose commit.
   - **Issue/PR references** — when the user provides an issue URL, issue ID, or the branch name matches an issue pattern:
     - Shared `closes` versus `refs` policy: `commit-trailers`. Then fetch only the platform in play — `commit-trailers-github`, `commit-trailers-gitlab`, or `commit-trailers-linear` — for that platform's keywords, syntax, and detection.
     - Fetch the issue via the appropriate MCP tool to understand context.
     - **Linear ignores commit messages entirely** — a `closes K-123` in a commit links nothing, moves nothing, closes nothing. Put the id in the commit only as a human-readable note if the repo does that, and never rely on it. The link and the close come from the **PR/MR title and description** (`github-pr-create` / `gitlab-mr-create`).
     - GitHub and GitLab **native** issues DO close from commit messages — `closes #42` there works. Do not generalise either way.
     - If the user also requested an extended description, weave relevant issue context into the body.
   - **NEVER add `Co-authored-by:` trailers.** This is forbidden — no exceptions.

5. **Present the draft to the user.**
   - Show the full commit message per `output-diff`:
     - Reasoning: brief explanation of why you chose this type, scope, and message.
     - Content: the full commit message in a fenced code block.
   - Ask for approval or feedback.
   - Iterate until the user is satisfied.

6. **Commit.**
   - After explicit user approval, commit via `git commit` with the approved message.
   - **Amend (your own branch only):** if the change is a fixup to the commit you just made, or the user asks to amend, use `git commit --amend` instead of a new commit — present the updated message first, and note that pushing the rewrite needs `--force-with-lease` via `git-push`. Never amend a commit that is already shared or on a protected branch.
   - Confirm success by reporting the commit hash from the output.
   - Do NOT push. If the user wants to push, hand off to the `git-push` skill (invoked separately or as a compose step like "commit and push").

## Key Principles

- **One logical change per commit.** If the staged changes span multiple unrelated concerns, suggest splitting into separate commits.
- **The subject tells what, the body tells why.** Never restate the diff in the body — the commit content already shows what changed.
- **Match the project.** Read recent commits to match the project's capitalization, scope conventions, and style.
- **No AI attribution.** Never include "Generated with Claude" or similar.
- **No Co-authored-by.** Never add `Co-authored-by:` trailers under any circumstances.
- **Never push automatically.** Commit only. The user decides when to push.
- **New commits by default; amend your own work when it fits.** Default to a fresh commit (and separate commits for separate concerns). Amend or rewrite only your own commits on your own branch — a fixup to the commit you just made, or tidying unshared history — or when the user asks; pushing the rewrite uses `--force-with-lease` via `git-push`. Never amend or rewrite shared or protected-branch history.
- **Different tasks → different commits.** Don't collapse unrelated work into one commit. A branch that carries several meaningful commits should keep them: squash can be applied later at merge time, but when the branch holds multiple distinct commits keep squash OFF on the PR/MR so the history survives (see `github-pr-create` / `gitlab-mr-create`).

## Composing with Other Skills

This skill is composable — the commit step is a single, focused responsibility that other skills build on.

- **Followed by `git-push`:** when the user chains both (e.g., "commit and push", "git-commit git-push"), this skill runs to completion (analyze → draft → approve → commit), then control hands off to `git-push`. Never push from within this skill.
- **Never mix responsibilities.** This skill does not push, branch, pull, or open PRs. Those stay with the dedicated skills (`git-push`, `git-branch`, `code-pull`, `github-pr-create`, `gitlab-mr-create`).

## Examples

**User says:** "commit this"

1. Check status — 3 files staged.
2. Read staged diff — adds retry logic to API client.
3. Draft: `feat(api): add retry logic for transient failures`.
4. Present to user with reasoning.
5. User approves → commit.

**User says:** "commit" (nothing staged, 2 files modified)

1. Check status — nothing staged, 2 files modified.
2. Stage all with `.`.
3. Read staged diff — fixes typo in config parsing.
4. Draft: `fix(config): correct typo in parser validation`.
5. Present to user → approve → commit.

**User says:** "commit fix"

1. Check status — changes staged.
2. Read staged diff — corrects off-by-one in pagination.
3. Draft: `fix(pagination): correct off-by-one in page offset calculation`.
4. Present to user → approve → commit.

**User says:** "commit with description"

1. Check status — 4 files staged.
2. Read staged diff — replaces session auth with JWT tokens.
3. Draft subject + body:
   ```
   feat(auth): replace session auth with JWT tokens

   Mobile clients need stateless authentication for offline-first support.
   Access tokens expire after 15 minutes; refresh tokens are stored in
   httpOnly cookies with 7-day TTL.
   ```
4. Present to user → iterate → approve → commit.

**User says:** "commit with description, closes https://github.com/org/repo/issues/42"

1. Check status — 3 files staged.
2. Fetch issue #42 via `github__issue_read` — "Token expiry check off by one".
3. Read staged diff — fixes boundary condition in token validation.
4. Draft subject + body + trailer:
   ```
   fix(auth): reject expired tokens at boundary

   Token expiry check used < instead of <=, allowing a 1-second window
   where expired tokens passed validation.

   Closes #42
   ```
5. Present to user → iterate → approve → commit.

**User says:** "commit this, breaking change"

1. Check status — 2 files staged.
2. Read staged diff — renames `/v1/orders` to `/v1/checkout`.
3. Draft subject + body + trailer:
   ```
   feat(api)!: rename /v1/orders to /v1/checkout

   Consolidates order and payment flows under a single checkout endpoint.

   BREAKING CHANGE: clients on /v1/orders must migrate to /v1/checkout
   before 2026-06-01. Old route returns 410 after that date.
   ```
4. Present to user → iterate → approve → commit.

**User says:** "commit this" with `https://linear.app/kilic-dev/issue/K-219/...`

1. Check status — 6 files staged.
2. Detect `K-219` from URL, fetch via `linear-kilic__get_issue`.
3. Read staged diff — adds trojan-loki to inventory and caddy config.
4. Draft (the staged changes fully satisfy the issue):
   ```
   feat: provision trojan-loki

   closes K-219
   ```
5. Present to user → approve → commit.

**User says:** "commit these separately" (nothing staged, 6 files modified across auth and config)

1. Check status — nothing staged, 6 files modified.
2. Analyze changes — 3 files are auth-related, 3 are config cleanup.
3. Propose groups:
   - Group 1: `src/auth/token.ts`, `src/auth/middleware.ts`, `test/auth.test.ts` → auth changes.
   - Group 2: `config/app.yaml`, `config/routes.yaml`, `config/defaults.yaml` → config cleanup.
4. User approves grouping.
5. Stage group 1 files individually → draft: `feat(auth): add token refresh mechanism` → present → approve → commit.
6. Stage group 2 files individually → draft: `chore(config): clean up route and default configs` → present → approve → commit.
