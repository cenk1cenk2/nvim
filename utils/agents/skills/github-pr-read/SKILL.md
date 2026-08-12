---
name: github-pr-read
description: github-pr-read Read the full state of a GitHub PR - description, comments, review threads, diff. Informational only, writes nothing. Use on "read this PR", "summarise this PR". Not for producing a review, applying thread fixes, or writing the description.
disableModelInvocation: true
argumentHint: '[PR number or URL]'
references:
  - ../references/scm/scm-read-summary.md
  - ../references/scm/scm-github.md
  - ../references/scm/scm-detect.md
  - ../references/identifier-legibility.md
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## GitHub PR Read

Run the read/summarize workflow per `scm-read-summary`, with GitHub MCP tools per `scm-github` and platform detection plus local git (raw `git` CLI) per `scm-detect`.

## Platform specifics

- **Find the PR** (when not given): `git status` for the branch, extract owner/repo from the remote, then `github__list_pull_requests` with `head: "owner:branch"` and `state: open`.
- **Read metadata:** `github__pull_request_read` (method `get`) — title, body/description, author, state (open/closed/merged), labels, assignees, requested reviewers, base/head branches, mergeable status, created/updated timestamps.
- **Read the diff:** `github__pull_request_read` (method `get_diff`).
- **Read comments:** `github__pull_request_read` (method `get_comments`) for general PR comments (top-level discussion, not inline review comments). Note bot comments (CI reports, Spacelift, etc.).
- **Read review threads:** `github__pull_request_read` (method `get_review_comments`) for inline review comments and threads — file:line, resolved/unresolved status (if available), full conversation, pending suggestions.
- **Read commits:** `github__list_commits` for the PR.
- **Summary template:** header line `### PR #N: <title>`; use `#### Comments (<count>)` for the discussion section and `#### Review Threads` for the threads section.
