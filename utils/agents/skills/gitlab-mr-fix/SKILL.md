---
name: gitlab-mr-fix
description: 'gitlab-mr-fix Fix all open review conversations on a GitLab MR by applying the requested code changes. Use for "fix the MR comments", "address MR feedback". Do NOT use for reviewing (gitlab-mr-review), MR descriptions (gitlab-mr-create), or GitHub PRs (github-pr-fix).'
disableModelInvocation: true
argumentHint: "[MR number or URL]"
references:
  - ../references/reconcile-state.md
  - ../references/scm-fix-threads.md
  - ../references/scm-gitlab.md
  - ../references/scm-detect.md
---

## GitLab MR Fix

When the work deviates from what this artifact claims, reconcile it per `reconcile-state` — on by default, ask when it is a judgement call.

Thread-fixing workflow per `scm-fix-threads`. GitLab tooling and local git per `scm-gitlab`; platform detection per `scm-detect`.

## Platform specifics

- **Identify the MR** (when not given): use `git status` for the current branch, extract the project path from the remote URL, then `gitlab__list_merge_requests` with `source_branch` filter and `state: opened`. If none is open, inform the user and stop. Read MR metadata via `gitlab__get_merge_request`.
- **List open threads:** read all discussion threads on the MR via `gitlab__mr_discussions`, filtering to **unresolved** threads only. The file path and line range come from the diff position. Pending suggestions are GitLab `suggestion` blocks.
- **Reply to a thread:** add a note to the discussion via `gitlab__mr_discussions`.
- **Resolve a thread:** use `gitlab__mr_discussions` with the `resolved: true` parameter on the discussion.
