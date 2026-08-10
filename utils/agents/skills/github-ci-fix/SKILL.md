---
name: github-ci-fix
description: github-ci-fix Diagnose failing GitHub Actions on the current branch, research the errors, and propose fixes. Use on "CI is failing", "why is the check red". Not for authoring workflows, for GitLab pipeline failures, or for PR descriptions.
disableModelInvocation: true
references:
  - ../references/scm-detect.md
  - ../references/scm-ci-fix.md
  - ../references/scm-github.md
argumentHint: '[optional: workflow or job name]'
---

## GitHub Failed CI: Diagnose and Fix Failing Actions

Run the CI-diagnosis workflow per `scm-ci-fix`, with GitHub MCP tools, local git (raw `git` CLI), CLI fallback, and platform detection per `scm-detect` and `scm-github`.

## Platform specifics

- **List failing runs:** Get the current branch via `git status`, then list recent workflow runs with `gh run list --branch <branch>` (or the github MCP). Identify runs with `failure` or `error` status.
- **Fetch failing logs:** Use `gh run view <run-id>` for the summary, then `gh run view <run-id> --log-failed` to extract the relevant error logs.
- **CI definitions** live under `.github/workflows/`.

## Related Skills

- **`github-ci-create`** — for creating or modifying GitHub Actions workflows. Auto-invoke when the fix requires workflow changes rather than code changes.
