# SCM CI Fix

Shared workflow for diagnosing failing CI on the current branch, researching the errors, and proposing fixes. Used by `github-ci-fix` (GitHub) and `gitlab-ci-fix` (GitLab). The platform reference (`scm-github` / `scm-gitlab`) supplies the exact tools for listing failed runs/pipelines and fetching failing logs; each skill lists them under its own "Platform specifics".

## Pickup Workflow Notes

When composed from `agents-pickup`:

- Distinguish branch-caused failures from external or unrelated CI failures.
- Fix branch-caused failures in the current branch and report the verification evidence.
- For external or unrelated failures, capture the evidence and return it to the pickup workflow instead of widening scope silently.
- If the diagnosis changes the issue scope or creates follow-up work, tell the caller so it can update Linear comments or project documents.

## Process

1. **Identify failing CI.** Get the current branch via `git status`. List recent runs/pipelines for the branch and identify the failing ones (see the skill's "Platform specifics").
2. **Fetch failure details.** For each failing run/pipeline, fetch the summary and extract the relevant failing logs (see the skill's "Platform specifics"). Focus on the actual error messages, not boilerplate output.
3. **Diagnose the error.** Analyze the error messages. Read relevant source files, config files, or CI definitions as needed. If the error is unclear or unfamiliar, search the internet for the error message or related keywords.
4. **Propose a fix.** Present findings to the user: what failed, why it failed, and how to fix it. Be specific — reference file paths, line numbers, and exact changes needed.
5. **Ask to implement.** Ask the user: "Would you like me to fix this, or would you prefer to do it yourself?"
   - If the user approves → implement the fix.
   - If the user declines → provide a detailed step-by-step guide the user can follow to fix it manually. Include exact commands, file edits, and verification steps.

## Key Principles

- **Diagnose before proposing.** Never suggest a fix without understanding the root cause.
- **Search when stuck.** If the error is unfamiliar, use web search — do not guess.
- **Be specific.** Vague advice like "check your config" is not acceptable. Point to exact files, lines, and values.
- **Respect user choice.** If the user wants to fix it themselves, give them everything they need to succeed.
