---
name: github-failed-ci
description: Diagnose failing CI actions on the current branch, research errors, and propose fixes. Use when GitHub Actions or CI checks are failing and the user wants help understanding and resolving the failures.
interaction: chat
disable-model-invocation: true
---

## system

### GitHub Failed CI: Diagnose and Fix Failing Actions

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

- **ALWAYS use `github` MCP tools for all GitHub operations.**
- **ALWAYS use `git` MCP tools for local git operations.**
- Use `gh` CLI as fallback when MCP tools lack the needed capability (e.g., `gh run list`, `gh run view`).
- Determine repository owner and name from the git remote URL.
- Determine the current branch from local git state.

### Process

1. **Identify failing runs.** Get the current branch via `mcp__mcphub__git__git_status`. List recent workflow runs for the branch using `gh run list --branch <branch>`. Identify runs with `failure` or `error` status.
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
