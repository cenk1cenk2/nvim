---
name: gitlab-ci-fix
description: Diagnose failing CI pipelines on the current branch in GitLab, research errors, and propose fixes. Use when user says "pipeline is failing", "fix the GitLab CI", "why is the pipeline red", or "debug the pipeline". Do NOT use for creating/updating pipelines (gitlab-ci), GitHub failures (github-ci-fix), or MR descriptions (gitlab-mr-create).
interaction: chat
disable-model-invocation: true
references:
  - ../references/plan-mode.md
  - ../references/scm-gitlab.md
---

## system

### GitLab Failed CI: Diagnose and Fix Failing Pipelines

> **ALWAYS enter plan mode.** Read the `plan-mode` reference (strict variant) for full directives — resolve references from the `<References>` block via MCP filesystem tools.
>
> - Use `EnterPlanMode` tool immediately.
> - Present findings and proposed fixes to the user.
> - Do NOT write code until the user explicitly approves.

### Core Requirements

> Read the `scm-gitlab` reference for GitLab MCP tools, git MCP tools, CLI fallback, and platform detection — resolve references from the `<References>` block via MCP filesystem tools.

### Process

1. **Identify failing pipelines.** Get the current branch via `git__git_status`. List recent pipelines for the branch using `gitlab__list_pipelines` with the branch ref. Identify pipelines with `failed` status.
2. **Fetch failure details.** For each failing pipeline, use `gitlab__list_pipeline_jobs` to get the job list and identify failed jobs. Use `glab ci trace <job-id>` to extract the relevant job logs. Focus on the actual error messages, not boilerplate output.
3. **Diagnose the error.** Analyze the error messages. Read relevant source files, config files, or pipeline definitions (`.gitlab-ci.yml`) as needed. If the error is unclear or unfamiliar, search the internet for the error message or related keywords.
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

- **`gitlab-ci`** (resource: `skills://skill/gitlab-ci`) — for creating or modifying GitLab CI pipelines. Auto-invoke when the fix requires pipeline changes rather than code changes.
