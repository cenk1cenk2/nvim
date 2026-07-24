---
name: github-ci-fix
description: 'github-ci-fix Diagnose failing GitHub Actions on the current branch, research errors, and propose fixes. Triggers: "CI is failing", "why is the check red", "debug the workflow". Do NOT use for creating/updating workflows (github-ci-create), GitLab failures (gitlab-ci-fix), or PR descriptions (github-pr-create).'
disableModelInvocation: true
references:
  - ../references/scm-ci-fix.md
  - ../references/present-first.md
  - ../references/scm-github.md
---

## GitHub Failed CI: Diagnose and Fix Failing Actions

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `scm-ci-fix` reference for the shared CI-diagnosis workflow and key principles.
> Read the `scm-github` reference for GitHub MCP tools, local git (raw `git` CLI), CLI fallback, and platform detection.

## Platform specifics

- **List failing runs:** Get the current branch via `git status`, then list recent workflow runs with `gh run list --branch <branch>` (or the github MCP). Identify runs with `failure` or `error` status.
- **Fetch failing logs:** Use `gh run view <run-id>` for the summary, then `gh run view <run-id> --log-failed` to extract the relevant error logs.
- **CI definitions** live under `.github/workflows/`.

## Related Skills

- **`github-ci-create`** — for creating or modifying GitHub Actions workflows. Auto-invoke when the fix requires workflow changes rather than code changes.
