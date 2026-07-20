---
name: github-pr-create
description: Analyze and write GitHub pull request titles and descriptions. Use when user says "write a PR description", "create a PR", "improve the PR", or "describe what this branch does". Do NOT use for GitLab MRs (gitlab-mr-create), CI workflows (github-ci-create), or CI failures (github-ci-fix).
references:
  - ../references/scm-create-description.md
  - ../references/present-first.md
  - ../references/scm-github.md
  - ../references/commit-trailers.md
  - ../references/output-diff.md
  - ../references/linear-state-transitions.md
---

## GitHub PR Description Workflow

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `scm-create-description` reference for the shared description/title workflow, format templates, and writing style.
> Read the `scm-github` reference for GitHub MCP tools, local git (raw `git` CLI), CLI fallback, and platform detection.
> Read the `commit-trailers` reference for Linear/GitHub issue trailer selection. Use `closes <Linear-id>` for the single/final PR that should close a Linear issue; use `refs <Linear-id>` for partial, related, multi-PR, or unclear completion work.
> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.
> Read the `linear-state-transitions` reference for the auto-advance rules (target state, never-downgrade guard, id extraction, silent-with-report contract). Applied after the PR update succeeds.

## Platform specifics

- **Find the PR** (when not given): get the current branch via `git status`, extract owner/repo from the remote, then `github__list_pull_requests` with a `head` filter (format `owner:branch`) and `state: open`. See "Branch reuse" in the `scm-create-description` reference. If no open PR exists, ask the user before creating one via `github__create_pull_request` (fall back to `gh pr create` if MCP creation is unavailable).
- **Preserve multi-commit history.** If the branch carries multiple meaningful commits (e.g. grouped by task), it should NOT be squash-merged — a merge or rebase merge keeps the separate commits. Squash-merge is fine only when the branch is a single logical change. GitHub picks the merge method at merge time, so call this out in the PR when it matters.
- **Analyze the PR:** read details via `github__pull_request_read` (method `get`), the full diff via `github__pull_request_read` (method `get_diff`), and commit history via `github__list_commits` filtered to the PR branch. Note the existing title and body (may contain a template or prior content).
- **Discover the repository PR template** (before drafting from scratch): if the existing PR body already contains a template (sections with `## ` headers or `<!-- -->` markers), use it. Otherwise **ALWAYS** look for a template with `github__get_file_contents` on the PR's base branch, trying these paths in order and stopping at the first match:
  1. `.github/PULL_REQUEST_TEMPLATE.md`
  2. `.github/pull_request_template.md`
  3. `.github/PULL_REQUEST_TEMPLATE/` (directory — list contents; if multiple templates exist, ask the user which one to use)
  4. `PULL_REQUEST_TEMPLATE.md` (repo root)
  5. `pull_request_template.md` (repo root)
  6. `docs/PULL_REQUEST_TEMPLATE.md`
  7. `docs/pull_request_template.md`
  If a template is found, announce the path (e.g., "Found template at `.github/PULL_REQUEST_TEMPLATE.md`") and use it as the starting scaffold. If none is found, fall back to the standard description format in the reference.
- **Update the PR** (only after approval): update both `title` (if changed) and `body` via `github__update_pull_request`, then confirm success.
- **Transition linked Linear issues to `In Review`:** after the PR update succeeds, follow the `linear-state-transitions` reference — extract Linear ids from the PR body (`refs K-xxx` / `closes K-xxx` trailers) and the branch's commit messages, fetch each id's current `statusType`, and call `save_issue` with `state: "In Review"` (skip when already `Done` / `Canceled` or already `In Review`; never downgrade). Report one line per issue touched: `Linear state: moved K-xxx → In Review (was Todo).` Silent-with-report — no prompt; the user opts out by saying "don't move the Linear state" in the PR-create request. Skip entirely when zero Linear ids are found.
