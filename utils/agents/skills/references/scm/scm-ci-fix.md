# SCM CI Fix

Shared workflow for diagnosing failing CI on the current branch, researching the errors, and fixing what the branch caused. Used by `github-ci-fix` (GitHub) and `gitlab-ci-fix` (GitLab). The platform reference (`scm-github` / `scm-gitlab`) supplies the exact tools for listing failed runs/pipelines and fetching failing logs; each skill lists them under its own "Platform specifics".

## Pickup Workflow Notes

When composed from `agent-pickup`, return external or unrelated failures to the pickup workflow with their evidence, and tell the caller when the diagnosis changes the issue scope or creates follow-up work so it can update Linear comments or project documents.

## Process

1. **Identify failing CI.** Get the current branch via `git status`. List recent runs/pipelines for the branch and identify the failing ones (see the skill's "Platform specifics").
2. **Fetch failure details.** For each failing run/pipeline, fetch the summary and extract the relevant failing logs (see the skill's "Platform specifics"). Focus on the actual error messages, not boilerplate output.
3. **Diagnose the error.** Analyze the error messages. Read relevant source files, config files, or CI definitions as needed. If the error is unclear or unfamiliar, search the internet for the error message or related keywords.
4. **Classify the failure.** Branch-caused, or external and unrelated; a fast second opinion per `scm-ci-failure-kind`.
5. **Fix branch-caused failures** in the current branch, verify locally where the project allows, and report what failed, why, the change made (file paths and lines), and the verification evidence.
6. **Report external or unrelated failures** with their evidence and the likely owner; do not widen scope to fix them. When the user said they will fix it themselves, give a step-by-step guide with exact commands, file edits, and verification steps instead of changing files.

## Key Principles

- **Diagnose before fixing.** Never change anything without understanding the root cause.
- **Search when stuck.** If the error is unfamiliar, use web search — do not guess.
- **Be specific.** Vague advice like "check your config" is not acceptable. Point to exact files, lines, and values.
