---
name: gitlab-mr-comment
description: gitlab-mr-comment Post a companion skill's output as a comment on a GitLab MR. Use on "comment on the MR", "post this to the MR". Not for the MR description itself, for GitHub pull requests, or for issue comments.
disableModelInvocation: true
argumentHint: '[companion-skill] [MR number or URL]'
references:
  - ../references/scm/scm-detect.md
  - ../references/present-first.md
  - ../references/scm/scm-comment-poster.md
  - ../references/scm/scm-gitlab.md
  - ../references/output-diff.md
  - ../references/identifier-legibility.md
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## GitLab MR Comment Poster

Posture: `present-first`.
Draft-and-post workflow per `scm-comment-poster`. Present the comment per `output-diff` before posting. GitLab tooling, local git, and platform detection per `scm-detect` and `scm-gitlab`.

## Platform specifics

- **Find the MR** (when not given): `git status` for the branch, extract the project path from the remote, then `gitlab__list_merge_requests` with `source_branch` filter and `state: opened`.
- **Post the comment:** `gitlab__mr_discussions` with the project path, MR IID, and comment body.
