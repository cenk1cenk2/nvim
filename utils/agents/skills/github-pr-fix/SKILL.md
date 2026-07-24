---
name: github-pr-fix
description: 'github-pr-fix Fix all open review conversations on a GitHub PR by applying the requested code changes. Use for "fix the PR comments", "address PR feedback". Do NOT use for reviewing (github-pr-review), PR descriptions (github-pr-create), or GitLab MRs (gitlab-mr-fix).'
disable-model-invocation: true
argument-hint: "[PR number or URL]"
references:
  - ../references/present-first.md
  - ../references/scm-fix-threads.md
  - ../references/scm-github.md
  - ../references/scm-detect.md
---

## GitHub PR Fix

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `scm-fix-threads` reference for the full thread-fixing workflow and key principles.
> Read the `scm-github` reference for GitHub MCP tools and local git (raw `git` CLI).
> Read the `scm-detect` reference for platform detection and local git operations.

## Platform specifics

- **Identify the PR** (when not given): use `git status` for the current branch, extract owner/repo from the remote URL, then `github__list_pull_requests` with `head: "owner:branch"` and `state: open`. If none is open, inform the user and stop. Read PR metadata via `github__pull_request_read` (method: `get`).
- **List open threads:** read all review comments and conversation threads on the PR, filtering to **unresolved/open** threads only. Pending suggestions are GitHub `suggestion` blocks.
- **Reply to a thread:** post the reply to the thread via the GitHub review-comment tools (see `scm-github`).
- **Resolve a thread — requires GraphQL** (the MCP tools do not expose this). Use `gh api graphql` as fallback:
  1. Get thread IDs: `gh api graphql -f query='query { repository(owner:"OWNER", name:"REPO") { pullRequest(number:N) { reviewThreads(first:50) { nodes { id isResolved comments(first:1) { nodes { body } } } } } } }'`
  2. Resolve each thread: `gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { isResolved } } }'`

  Batch all thread IDs when collecting open threads so you only need one query, then resolve after fixes are applied.
