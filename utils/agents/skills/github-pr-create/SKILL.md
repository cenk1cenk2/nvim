---
name: github-pr-create
description: 'github-pr-create Analyze and write GitHub PR titles and descriptions. Use for "write a PR description", "create a PR", "improve the PR". Do NOT use for GitLab MRs (gitlab-mr-create) or CI workflows/failures (github-ci-create, github-ci-fix).'
references:
  - ../references/reconcile-state.md
  - ../references/scm-detect.md
  - ../references/present-first.md
  - ../references/scm-create-description.md
  - ../references/scm-github.md
  - ../references/commit-trailers.md
  - ../references/output-diff.md
  - ../references/linear-state-transitions.md
  - ../references/release-convention.md
---

## GitHub PR Description Workflow

When the work deviates from what this artifact claims, reconcile it per `reconcile-state` — on by default, ask when it is a judgement call.

Posture: `present-first`.
Draft the description and title per `scm-create-description`, with GitHub MCP tools, local git (raw `git` CLI), CLI fallback, and platform detection per `scm-detect` and `scm-github`.

> **Open when ready.** Default communication is opening the PR in the browser once it's ready to look at — skip only on explicit opt-out ("just the link", "don't open").

## Platform specifics

- **Find the PR** (when not given): get the current branch via `git status`, extract owner/repo from the remote, then `github__list_pull_requests` with a `head` filter (format `owner:branch`) and `state: open`. See "Branch reuse" in `scm-create-description`. If no open PR exists, ask the user before creating one via `github__create_pull_request` (fall back to `gh pr create` if MCP creation is unavailable).
- **Issue trailers**, per `commit-trailers`. **If this PR closes the issue, write `closes` — do not hedge to `refs`.** `refs` is only for genuinely partial work: another PR is still pending on the same issue. **Several issues in one PR:** GitHub native issues repeat the keyword (`closes #10, closes #12`); **Linear takes one keyword and a comma-separated list** — `Closes K-879, K-881` — never one trailer per Linear id.
- **⛔ Put the Linear ids in the title as a suffix** — `fix(scope): subject (K-879, K-881)`. A bare id in the title is a link Linear resolves on its own, and it stays clickable in the PR list and survives into the squash commit. The description trailer is what guarantees the close on merge; use **both**.
- **⛔ Linear ignores commit messages entirely.** The title and the description are the only surfaces that link a Linear issue. A branch whose every commit names the id still leaves it open on merge. Give each linked issue its own description section per `scm-create-description`.
- **Preserve multi-commit history.** If the branch carries multiple meaningful commits (e.g. grouped by task), it should NOT be squash-merged — a merge or rebase merge keeps the separate commits. Squash-merge is fine only when the branch is a single logical change. GitHub picks the merge method at merge time, so call this out in the PR when it matters.
- **Match the release automation.** Detect the repo's release method per `release-convention`. If it is commit-driven (release-please / semantic-release) and the repo squash-merges, the PR title becomes the release commit — make it a valid Conventional Commit with the correct type and, for breaking changes, `type(scope)!:` plus a `BREAKING CHANGE:` footer in the body. If the repo uses changesets, ensure the branch includes a changeset file before merge (offer to add one).
- **Analyze the PR:** read details via `github__pull_request_read` (method `get`), the full diff via `github__pull_request_read` (method `get_diff`), and commit history via `github__list_commits` filtered to the PR branch. Note the existing title and body (may contain a template or prior content).
- **Discover the repository PR template** (before drafting from scratch): if the existing PR body already contains a template (sections with `## ` headers or `<!-- -->` markers), use it. Otherwise **ALWAYS** look for a template with `github__get_file_contents` on the PR's base branch, trying these paths in order and stopping at the first match:
  1. `.github/PULL_REQUEST_TEMPLATE.md`
  2. `.github/pull_request_template.md`
  3. `.github/PULL_REQUEST_TEMPLATE/` (directory — list contents; if multiple templates exist, ask the user which one to use)
  4. `PULL_REQUEST_TEMPLATE.md` (repo root)
  5. `pull_request_template.md` (repo root)
  6. `docs/PULL_REQUEST_TEMPLATE.md`
  7. `docs/pull_request_template.md`
  If a template is found, announce the path (e.g., "Found template at `.github/PULL_REQUEST_TEMPLATE.md`") and use it as the starting scaffold. If none is found, fall back to the standard description format in `scm-create-description`.
- **Update the PR** (only after approval): present the drafted title and body per `output-diff`, then update both `title` (if changed) and `body` via `github__update_pull_request` and confirm success. Once the PR is created/updated and ready to look at, by default open its web URL in the browser (e.g. via `hyprpilot__open`) — skip only if the user explicitly said not to ("just give me the link", "don't open it", "no browser").
- **Transition linked Linear issues to `In Review`:** after the PR update succeeds, follow `linear-state-transitions` — extract Linear ids from the PR body (`refs K-xxx` / `closes K-xxx` trailers) and the branch's commit messages, fetch each id's current `statusType`, and call `save_issue` with `state: "In Review"` (skip when already `Done` / `Canceled` or already `In Review`; never downgrade). Report one line per issue touched: `Linear state: moved K-xxx → In Review (was Todo).` Silent-with-report — no prompt; the user opts out by saying "don't move the Linear state" in the PR-create request. Skip entirely when zero Linear ids are found.
