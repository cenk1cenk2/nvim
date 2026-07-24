---
name: gitlab-mr-fix
description: 'gitlab-mr-fix Fix all open review conversations on a GitLab MR by applying the requested code changes. Use for "fix the MR comments", "address MR feedback". Do NOT use for reviewing (gitlab-mr-review), MR descriptions (gitlab-mr-create), or GitHub PRs (github-pr-fix).'
disableModelInvocation: true
argumentHint: "[MR number or URL]"
references:
  - ../references/present-first.md
  - ../references/scm-fix-threads.md
  - ../references/scm-gitlab.md
  - ../references/scm-detect.md
---

## GitLab MR Fix

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `scm-fix-threads` reference for the full thread-fixing workflow and key principles.
> Read the `scm-gitlab` reference for GitLab MCP tools and local git (raw `git` CLI).
> Read the `scm-detect` reference for platform detection and local git operations.

## Platform specifics

- **Identify the MR** (when not given): use `git status` for the current branch, extract the project path from the remote URL, then `gitlab__list_merge_requests` with `source_branch` filter and `state: opened`. If none is open, inform the user and stop. Read MR metadata via `gitlab__get_merge_request`.
- **List open threads:** read all discussion threads on the MR via `gitlab__mr_discussions`, filtering to **unresolved** threads only. The file path and line range come from the diff position. Pending suggestions are GitLab `suggestion` blocks.
- **Reply to a thread:** add a note to the discussion via `gitlab__mr_discussions`.
- **Resolve a thread:** use `gitlab__mr_discussions` with the `resolved: true` parameter on the discussion.
