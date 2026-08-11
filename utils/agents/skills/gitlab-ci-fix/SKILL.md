---
name: gitlab-ci-fix
description: gitlab-ci-fix Diagnose failing GitLab pipelines on the current branch, research the errors, and propose fixes. Use on "the pipeline is failing", "fix the CI". Not for authoring pipelines, for GitHub Actions failures, or for MR descriptions.
disableModelInvocation: true
references:
  - ../references/scm/scm-detect.md
  - ../references/scm/scm-ci-fix.md
  - ../references/scm/scm-gitlab.md
argumentHint: '[optional: pipeline or job name]'
---

## GitLab Failed CI: Diagnose and Fix Failing Pipelines

Diagnosis workflow per `scm-ci-fix`. GitLab tooling, local git, CLI fallback, and platform detection per `scm-detect` and `scm-gitlab`.

## Platform specifics

- **List failing pipelines:** Get the current branch via `git status`, then list recent pipelines for the branch ref with `gitlab__list_pipelines`. Identify pipelines with `failed` status.
- **Fetch failing logs:** Use `gitlab__list_pipeline_jobs` to get the job list and identify failed jobs, then `glab ci trace <job-id>` to extract the relevant job logs.
- **CI definitions** live in `.gitlab-ci.yml`.

## Related Skills

- **`gitlab-ci-create`** — for creating or modifying GitLab CI pipelines. Auto-invoke when the fix requires pipeline changes rather than code changes.
