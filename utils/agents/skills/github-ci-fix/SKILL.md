---
name: github-ci-fix
description: Diagnose failing CI actions on the current branch, research errors, and propose fixes. Use when user says "CI is failing", "fix the GitHub Actions", "why is the check red", or "debug the workflow". Do NOT use for creating/updating workflows (github-ci), GitLab failures (gitlab-ci-fix), or PR descriptions (github-pr).
interaction: chat
disable-model-invocation: true
references:
  - ../references/plan-mode.md
  - ../references/scm-github.md
---

## system

### GitHub Failed CI: Diagnose and Fix Failing Actions

> **ALWAYS enter plan mode.** Read the `plan-mode` reference (strict variant) for full directives
>
> - Use `EnterPlanMode` tool immediately.
> - Present findings and proposed fixes to the user.
> - Do NOT write code until the user explicitly approves.

### Core Requirements

> Read the `scm-github` reference for GitHub MCP tools, git MCP tools, CLI fallback, and platform detection

### Process

1. **Identify failing runs.** Get the current branch via `git status`. List recent workflow runs for the branch using `gh run list --branch <branch>`. Identify runs with `failure` or `error` status.
2. **Fetch failure details.** For each failing run, use `gh run view <run-id>` to get the summary. Use `gh run view <run-id> --log-failed` to extract the relevant error logs. Focus on the actual error messages, not boilerplate output.
3. **Diagnose the error.** Analyze the error messages. Read relevant source files, config files, or workflow definitions (`.github/workflows/`) as needed. If the error is unclear or unfamiliar, search the internet for the error message or related keywords.
4. **Propose a fix.** Present findings to the user: what failed, why it failed, and how to fix it. Be specific — reference file paths, line numbers, and exact changes needed.
5. **Ask to implement.** Ask the user: "Would you like me to fix this, or would you prefer to do it yourself?"
   - If the user approves → exit plan mode and implement the fix.
   - If the user declines → provide a detailed step-by-step guide the user can follow to fix it manually. Include exact commands, file edits, and verification steps.

### Key Principles

- **Diagnose before proposing.** Never suggest a fix without understanding the root cause.
- **Search when stuck.** If the error is unfamiliar, use web search — do not guess.
- **Be specific.** Vague advice like "check your config" is not acceptable. Point to exact files, lines, and values.
- **Respect user choice.** If the user wants to fix it themselves, give them everything they need to succeed.

### Related Skills

- **`github-ci`** (resource: `skills://skill/github-ci`) — for creating or modifying GitHub Actions workflows. Auto-invoke when the fix requires workflow changes rather than code changes.
