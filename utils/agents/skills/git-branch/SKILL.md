---
name: git-branch
description: Create a new git branch following repository naming conventions. Use when user says "create a branch", "new branch", "branch off", "start a branch", "make a branch", or "cut a branch". Discovers the repo's prefix convention, fast-forwards the default branch, creates the new branch from it, and switches to it. Do NOT use for commits (git-commit), conflict resolution (git-conflict), pulling reference changes (code-pull), or PRs (github-pr-create, gitlab-mr-create).
argument-hint: "[optional: branch name, prefix, or base branch]"
references:
  - ../references/present-first.md
  - ../references/scm-detect.md
  - ../references/output-diff.md
---

## Git Branch

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `scm-detect` reference for SCM platform detection and raw `git` CLI usage.

> Read the `output-diff` reference for presenting the proposed branch plan before creating it.

## Process

1. **Discover the current state.**
   - Use `git status` to get the current branch and working tree state.
   - Determine the default branch — try `git symbolic-ref refs/remotes/origin/HEAD` via CLI first, or list branches with `git branch` and check which of `main`, `master`, `rolling`, `develop`, `trunk` exists.

2. **Discover the naming convention.**
   - List local branches with `git branch`.
   - List remote branches with `git branch -r`.
   - Infer the repo's prefix convention from the branch set. Common patterns:
     - `feature/*`, `feat/*` — features.
     - `fix/*`, `hotfix/*`, `bugfix/*` — fixes.
     - `chore/*`, `docs/*`, `refactor/*` — maintenance.
     - `release/*` — semantic release branches (do NOT use as a sticky style).
     - Flat `<name>` — no prefix convention.
   - Apply priority, highest first:
     1. **Explicit user input** — if the user provided a full branch name or explicit prefix, use it verbatim.
     2. **Sticky style** — if earlier in this conversation you already created a branch for the same piece of work (e.g., the user is splitting one feature across multiple branches), reuse that prefix and casing. Does NOT apply when the user moves to unrelated work, and never inherit semantic prefixes like `release/*`.
     3. **Current branch prefix** — if the user is on a work branch like `feat/x` and is chaining more related work, prefer that prefix.
     4. **Repo-wide convention** — if the repo consistently uses a prefix, match it.
     5. **Default** — `feature/<kebab-case>` for new work, `hotfix/<kebab-case>` when the user's wording indicates a fix/hotfix (keywords: "fix", "hotfix", "bug", "bugfix", "patch").

3. **Determine the branch name.**
   - Descriptive partial is **always kebab-case** (lowercase words joined by `-`, no spaces, no underscores).
   - If the user gave a descriptive hint (e.g., "token refresh logic"), convert it to kebab-case (`token-refresh-logic`).
   - Combine prefix + descriptive partial: `feature/token-refresh-logic`.
   - **Flat kebab-case override** — when the user explicitly asks for a kebab-case-only name (e.g., "kebab-case only", "no slashes", "flat name", "single segment"), drop the `/` separator and flatten with `-`: `feature-token-refresh-logic`. Apply the same flattening to the repo-detected convention when the repo itself uses flat kebab-case names (no `/` seen in existing branches).

4. **Determine the base branch.**
   - Default to the repository's default branch.
   - Override when the user explicitly specifies a base (e.g., "branch off `feat/x`", "from `develop`").

5. **Present the plan.**
   - Use the `output-diff` presentation format with a single chunk covering the full branching plan:
     - Reasoning: 1-2 sentences on prefix choice (what convention was detected and why).
     - Content block listing: `branch`, `base`, `fast-forward` (yes/no), and any notes (e.g., uncommitted changes present).
   - Wait for explicit user approval before any write.

6. **Fast-forward the default branch (unless opted out).**
   - Default behavior: checkout the default branch via `git checkout`, then fast-forward via `git pull --ff-only` (CLI; no MCP pull tool).
   - Skip this step only when the user explicitly opts out (e.g., "don't fast-forward", "skip pull", "branch as-is").
   - **On any blocker — never auto-resolve. Ask the user.** Blockers include:
     - Uncommitted changes that would block checkout.
     - Local commits ahead of origin (non-fast-forward).
     - Pull failure (network, auth, diverged history).
   - Present the specific situation and offer options (stash, abort, skip FF, rebase onto remote, commit first, etc.). Wait for instruction.

7. **Create the branch.**
   - Create it with `git branch <name> <base>` from the chosen base.

8. **Switch to the new branch.**
   - `git branch` does NOT switch — always follow with `git checkout <new-branch>`.
   - CLI fallback: `git checkout <new-branch>` (or `git switch <new-branch>`).

9. **Confirm.**
   - Report the new branch name, the base it was created from, and whether the default was fast-forwarded.
   - Remind the user that the branch is **not pushed** to origin. They can ask explicitly when ready.

## Composing with Other Skills

This skill is composable — other skills can delegate branch creation to it as a prerequisite step.

- **Calling skill responsibilities:** pass a descriptive hint or explicit name/prefix through the conversation context (e.g., Linear issue title, feature summary).
- **This skill:** runs the process above, confirms with the user, and hands control back to the calling skill after the new branch is checked out.
- **Never mix responsibilities.** This skill does not commit, push, or open PRs. Those stay with the calling skill or with the dedicated skills (`git-commit`, `github-pr-create`, `gitlab-mr-create`).

## Key Principles

- **Repo convention beats default format.** Always inspect existing branches before proposing a name.
- **Sticky style only for related chained branching.** Within one conversation, reuse the style of earlier branches when splitting the same work. Do not inherit styles across unrelated work or from semantic prefixes (`release/*`).
- **Kebab-case always** for the descriptive partial. When the user asks for kebab-case-only names, flatten `prefix/descriptive` to `prefix-descriptive` (drop the `/`).
- **Default branch unless told otherwise** — never branch from a random HEAD silently.
- **Fast-forward default unless told otherwise.** On any blocker, ask the user — never auto-resolve.
- **Never push automatically.** Branch creation is local-only until the user explicitly asks to push.

## Examples

**User says:** "create a branch for token refresh logic"

1. Current branch: `rolling`. Default branch: `rolling`. Repo uses `feature/*` and `fix/*`.
2. No sticky style, not on a work branch, repo uses `feature/*`. Intent is new work.
3. Propose plan:

   > Repo uses `feature/*` for new work. Branching off `rolling` after fast-forward.
   >
   > ```
   > branch:        feature/token-refresh-logic
   > base:          rolling
   > fast-forward:  yes
   > ```

4. User approves.
5. Checkout `rolling`, `git pull --ff-only` succeeds.
6. `git branch feature/token-refresh-logic` → `git checkout feature/token-refresh-logic`.
7. Confirm: "Created and switched to `feature/token-refresh-logic` from `rolling`. Not pushed."

---

**User says:** "new branch called auth-bug-fix, don't pull"

1. Current branch: `main`. Default branch: `main`. Repo uses `feat/*` and `fix/*`.
2. User gave explicit descriptive name `auth-bug-fix`. Wording ("bug", "fix") indicates a fix. Repo uses `fix/*`.
3. Propose plan:

   > Explicit name provided. Repo uses `fix/*` for fixes. Skipping fast-forward per request.
   >
   > ```
   > branch:        fix/auth-bug-fix
   > base:          main
   > fast-forward:  no (user opted out)
   > ```

4. User approves.
5. Skip FF.
6. Create and switch to `fix/auth-bug-fix` from `main`.
7. Confirm.

---

**User says:** "branch off my current one for a follow-up on the same feature"

1. Current branch: `feat/payment-retry`. User wants a related follow-up.
2. Sticky style applies — continue `feat/*`. Base from current branch, not default.
3. Propose plan:

   > Follow-up on the same feature — sticky style, branching from `feat/payment-retry` instead of default. Skipping fast-forward because base is not the default branch.
   >
   > ```
   > branch:        feat/payment-retry-cleanup
   > base:          feat/payment-retry
   > fast-forward:  no (base is not default)
   > ```

4. User approves.
5. Create `feat/payment-retry-cleanup` from `feat/payment-retry` → checkout.
6. Confirm.

---

**User says:** "new branch for the onboarding redesign, kebab-case only"

1. Current branch: `main`. Default branch: `main`. Repo uses `feature/*`.
2. User explicitly asked for kebab-case-only — flatten `/` to `-`.
3. Propose plan:

   > User asked for kebab-case-only. Applying repo's `feature` prefix flattened with `-` instead of `/`.
   >
   > ```
   > branch:        feature-onboarding-redesign
   > base:          main
   > fast-forward:  yes
   > ```

4. User approves → fast-forward, create, checkout, confirm.

---

**User says:** "new branch for jwt work" (working tree has uncommitted changes)

1. `git status` shows 3 modified files. Default branch: `main`.
2. Propose plan (note the blocker):

   > Repo uses `feature/*`. Working tree has uncommitted changes — fast-forward will fail on checkout. Need your call before proceeding.
   >
   > ```
   > branch:        feature/jwt-work
   > base:          main
   > fast-forward:  yes (pending)
   > notes:         3 files modified; choose stash / commit-first / skip-FF / abort
   > ```

3. User: "stash".
4. `git stash`, checkout `main`, `git pull --ff-only`, create `feature/jwt-work`, checkout, `git stash pop`.
5. Confirm.
