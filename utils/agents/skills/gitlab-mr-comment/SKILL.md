---
name: gitlab-mr-comment
description: Post a companion skill's output as a comment on the current GitLab MR. Use when user says "comment on the MR", "post this to the MR", or invokes alongside another skill to comment its output on GitLab. Do NOT use for MR descriptions (gitlab-mr-create), GitHub PR comments (github-pr-comment), or issue comments (use GitLab MCP directly).
disable-model-invocation: true
argument-hint: "[companion-skill] [MR number or URL]"
references:
  - ../references/present-first.md
  - ../references/scm-comment-poster.md
  - ../references/scm-gitlab.md
  - ../references/output-diff.md
---

## GitLab MR Comment Poster

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `scm-comment-poster` reference for the full draft-and-post workflow and key principles.
> Read the `scm-gitlab` reference for GitLab MCP tools, git MCP tools, and platform detection.
> Read the `output-diff` reference for presenting the comment before posting.

## Platform specifics

- **Find the MR** (when not given): `git status` for the branch, extract the project path from the remote, then `gitlab__list_merge_requests` with `source_branch` filter and `state: opened`.
- **Post the comment:** `gitlab__mr_discussions` with the project path, MR IID, and comment body.
