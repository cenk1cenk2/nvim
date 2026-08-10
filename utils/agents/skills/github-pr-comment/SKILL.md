---
name: github-pr-comment
description: 'github-pr-comment Post a companion skill''s output as a comment on the current GitHub PR. Triggers: "comment on the PR", "post this to the PR". Do NOT use for PR descriptions (github-pr-create), GitLab MR comments (gitlab-mr-comment), or issue comments (use GitHub MCP directly).'
disableModelInvocation: true
argumentHint: "[companion-skill] [PR number or URL]"
references:
  - ../references/scm-comment-poster.md
  - ../references/scm-github.md
  - ../references/output-diff.md
---

## GitHub PR Comment Poster

Run the draft-and-post workflow per `scm-comment-poster`, with GitHub MCP tools, local git (raw `git` CLI), and platform detection per `scm-github`. Present the comment per `output-diff` before posting.

## Platform specifics

- **Find the PR** (when not given): `git status` for the branch, extract owner/repo from the remote, then `github__list_pull_requests` with `head: "owner:branch"` and `state: open`.
- **Post the comment:** `github__add_issue_comment` with `owner`, `repo`, `issue_number` (the PR number), and `body`.
