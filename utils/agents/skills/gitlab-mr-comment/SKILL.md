---
name: gitlab-mr-comment
description: 'gitlab-mr-comment Post a companion skill''s output as a comment on the current GitLab MR. Use for "comment on the MR", "post this to the MR". Do NOT use for MR descriptions (gitlab-mr-create), GitHub PR comments (github-pr-comment), or issue comments (GitLab MCP directly).'
disableModelInvocation: true
argumentHint: "[companion-skill] [MR number or URL]"
references:
  - ../references/scm-comment-poster.md
  - ../references/scm-gitlab.md
  - ../references/output-diff.md
---

## GitLab MR Comment Poster

Draft-and-post workflow per `scm-comment-poster`. Present the comment per `output-diff` before posting. GitLab tooling, local git, and platform detection per `scm-gitlab`.

## Platform specifics

- **Find the MR** (when not given): `git status` for the branch, extract the project path from the remote, then `gitlab__list_merge_requests` with `source_branch` filter and `state: opened`.
- **Post the comment:** `gitlab__mr_discussions` with the project path, MR IID, and comment body.
