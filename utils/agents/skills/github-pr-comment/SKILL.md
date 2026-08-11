---
name: github-pr-comment
description: github-pr-comment Post a companion skill's output as a comment on a GitHub PR. Use on "comment on the PR", "post this to the PR". Not for the PR description itself, for GitLab merge requests, or for issue comments.
disableModelInvocation: true
argumentHint: '[companion-skill] [PR number or URL]'
references:
  - ../references/scm/scm-detect.md
  - ../references/present-first.md
  - ../references/scm/scm-comment-poster.md
  - ../references/scm/scm-github.md
  - ../references/output-diff.md
---

## GitHub PR Comment Poster

Posture: `present-first`.
Run the draft-and-post workflow per `scm-comment-poster`, with GitHub MCP tools, local git (raw `git` CLI), and platform detection per `scm-detect` and `scm-github`. Present the comment per `output-diff` before posting.

## Platform specifics

- **Find the PR** (when not given): `git status` for the branch, extract owner/repo from the remote, then `github__list_pull_requests` with `head: "owner:branch"` and `state: open`.
- **Post the comment:** `github__add_issue_comment` with `owner`, `repo`, `issue_number` (the PR number), and `body`.
