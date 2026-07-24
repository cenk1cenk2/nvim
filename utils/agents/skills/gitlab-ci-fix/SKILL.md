---
name: gitlab-ci-fix
description: 'gitlab-ci-fix Diagnose failing GitLab CI pipelines on the current branch, research errors, and propose fixes. Use for "pipeline is failing", "fix the GitLab CI". Do NOT use for creating pipelines (gitlab-ci-create), GitHub failures (github-ci-fix), or MR descriptions (gitlab-mr-create).'
disable-model-invocation: true
references:
  - ../references/scm-ci-fix.md
  - ../references/present-first.md
  - ../references/scm-gitlab.md
---

## GitLab Failed CI: Diagnose and Fix Failing Pipelines

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `scm-ci-fix` reference for the shared CI-diagnosis workflow and key principles.
> Read the `scm-gitlab` reference for GitLab MCP tools, local git (raw `git` CLI), CLI fallback, and platform detection.

## Platform specifics

- **List failing pipelines:** Get the current branch via `git status`, then list recent pipelines for the branch ref with `gitlab__list_pipelines`. Identify pipelines with `failed` status.
- **Fetch failing logs:** Use `gitlab__list_pipeline_jobs` to get the job list and identify failed jobs, then `glab ci trace <job-id>` to extract the relevant job logs.
- **CI definitions** live in `.gitlab-ci.yml`.

## Related Skills

- **`gitlab-ci-create`** — for creating or modifying GitLab CI pipelines. Auto-invoke when the fix requires pipeline changes rather than code changes.
