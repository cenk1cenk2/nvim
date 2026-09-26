---
name: gitlab-ci-fix
description: gitlab-ci-fix Diagnose failing GitLab pipelines on the current branch, research the errors, and propose fixes. Use on "the pipeline is failing", "fix the CI". Not for authoring pipelines, for GitHub Actions failures, or for MR descriptions.
disableModelInvocation: true
references:
  - ../references/scm/scm-detect.md
  - ../references/scm/scm-ci-fix.md
  - ../references/scm/scm-gitlab.md
  - ../references/kilic/kilic-ci-pipelines.md
  - ../references/identifier-legibility.md
argumentHint: '[optional: pipeline or job name]'
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## GitLab Failed CI: Diagnose and Fix Failing Pipelines

Diagnosis workflow per `scm-ci-fix`. GitLab tooling, local git, CLI fallback, and platform detection per `scm-detect` and `scm-gitlab`.

## Platform specifics

- **List failing pipelines:** Get the current branch via `git status`, then list recent pipelines for the branch ref with `gitlab__list_pipelines`. Identify pipelines with `failed` status.
- **Fetch failing logs:** Use `gitlab__list_pipeline_jobs` to get the job list and identify failed jobs, then `glab ci trace <job-id>` to extract the relevant job logs.
- **CI definitions** live in `.gitlab-ci.yml`. Nearly every job extends a `devops/pipelines` template and runs a `devops/pipes` CLI. Trace a failing job from its template to the pipe command that produced the error, and decide which layer the fix belongs in, per `kilic-ci-pipelines`. A fix in `devops/pipelines` or `devops/pipes` is its own MR, and the consumer only picks it up once it bumps its tag.
- **A deploy job that never ran is not a failure.** `terraform/deploy` and `pulumi/up` wait for a manual trigger on the default branch and on tags.

## Related Skills

- **`gitlab-ci-create`** — for creating or modifying GitLab CI pipelines. Suggest it when the fix requires pipeline changes rather than code changes.
