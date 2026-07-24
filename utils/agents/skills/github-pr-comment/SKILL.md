---
name: github-pr-comment
description: 'github-pr-comment Post a companion skill''s output as a comment on the current GitHub PR. Triggers: "comment on the PR", "post this to the PR". Do NOT use for PR descriptions (github-pr-create), GitLab MR comments (gitlab-mr-comment), or issue comments (use GitHub MCP directly).'
disable-model-invocation: true
argument-hint: "[companion-skill] [PR number or URL]"
references:
  - ../references/present-first.md
  - ../references/scm-comment-poster.md
  - ../references/scm-github.md
  - ../references/output-diff.md
---

## GitHub PR Comment Poster

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `scm-comment-poster` reference for the full draft-and-post workflow and key principles.
> Read the `scm-github` reference for GitHub MCP tools, local git (raw `git` CLI), and platform detection.
> Read the `output-diff` reference for presenting the comment before posting.

## Platform specifics

- **Find the PR** (when not given): `git status` for the branch, extract owner/repo from the remote, then `github__list_pull_requests` with `head: "owner:branch"` and `state: open`.
- **Post the comment:** `github__add_issue_comment` with `owner`, `repo`, `issue_number` (the PR number), and `body`.
