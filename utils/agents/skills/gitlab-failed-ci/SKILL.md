---
name: gitlab-failed-ci
description: Diagnose failing CI pipelines on the current branch in GitLab, research errors, and propose fixes. Use when GitLab CI/CD pipelines are failing and the user wants help understanding and resolving the failures.
interaction: chat
disable-model-invocation: true
---

## system

### GitLab Failed CI: Diagnose and Fix Failing Pipelines

> **IMPORTANT: ALWAYS enter plan mode when this prompt is invoked.**
>
> - Use `EnterPlanMode` tool immediately.
> - Present findings and proposed fixes to the user.
> - Iterate based on feedback.
> - Do NOT write code until the user explicitly approves.
>
> **ABSOLUTE RULE: NEVER EXIT PLAN MODE. NEVER USE `ExitPlanMode`.**
>
> - You MUST stay in plan mode for the ENTIRE duration of this skill.
> - Only the user saying the EXACT words "fix it", "implement this", "start coding", "write the code", or an equally explicit and unambiguous direct instruction should cause you to exit plan mode.
> - If you are unsure whether the user wants you to fix it, ASK — do not assume.
> - **When in doubt, STAY in plan mode.**

### Core Requirements

- **ALWAYS use `gitlab` MCP tools for all GitLab operations.**
- **ALWAYS use `git` MCP tools for local git operations.**
- Use `glab` CLI as fallback when MCP tools lack the needed capability (e.g., `glab ci trace` for job logs).
- Determine project path from the git remote URL.
- Determine the current branch from local git state.

### Process

1. **Identify failing pipelines.** Get the current branch via `mcp__mcphub__git__git_status`. List recent pipelines for the branch using `mcp__mcphub__gitlab__list_pipelines` with the branch ref. Identify pipelines with `failed` status.
2. **Fetch failure details.** For each failing pipeline, use `mcp__mcphub__gitlab__list_pipeline_jobs` to get the job list and identify failed jobs. Use `glab ci trace <job-id>` to extract the relevant job logs. Focus on the actual error messages, not boilerplate output.
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

- **`/gitlab-ci`** (`~/.config/nvim/utils/agents/skills/gitlab-ci/SKILL.md`) — for creating or modifying GitLab CI pipelines. Auto-invoke when the fix requires pipeline changes rather than code changes.
