---
name: github-pr-read
description: 'github-pr-read Read the full state of a GitHub PR - description, comments, review threads, diff. Informational only. Use for "read this PR", "summarize this PR". Do NOT use for reviewing (github-pr-review), fixing threads (github-pr-fix), or descriptions (github-pr-create).'
disableModelInvocation: true
argumentHint: "[PR number or URL]"
references:
  - ../references/present-first.md
  - ../references/scm-read-summary.md
  - ../references/scm-github.md
  - ../references/scm-detect.md
---

## GitHub PR Read

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `scm-read-summary` reference for the full read/summarize workflow and key principles.
> Read the `scm-github` reference for GitHub MCP tools and local git (raw `git` CLI).
> Read the `scm-detect` reference for platform detection and local git operations.

## Platform specifics

- **Find the PR** (when not given): `git status` for the branch, extract owner/repo from the remote, then `github__list_pull_requests` with `head: "owner:branch"` and `state: open`.
- **Read metadata:** `github__pull_request_read` (method `get`) — title, body/description, author, state (open/closed/merged), labels, assignees, requested reviewers, base/head branches, mergeable status, created/updated timestamps.
- **Read the diff:** `github__pull_request_read` (method `get_diff`).
- **Read comments:** `github__pull_request_read` (method `get_comments`) for general PR comments (top-level discussion, not inline review comments). Note bot comments (CI reports, Spacelift, etc.).
- **Read review threads:** `github__pull_request_read` (method `get_review_comments`) for inline review comments and threads — file:line, resolved/unresolved status (if available), full conversation, pending suggestions.
- **Read commits:** `github__list_commits` for the PR.
- **Summary template:** header line `### PR #N: <title>`; use `#### Comments (<count>)` for the discussion section and `#### Review Threads` for the threads section.
