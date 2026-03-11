---
name: code-pull
description: Pull changes from a reference GitHub/GitLab repository and adapt them to the current repository. Always manually invoked. Do NOT use for code review (/code-review-branch), debugging (/code-debug), or PR descriptions (/github-pr, /gitlab-pr).
interaction: chat
disable-model-invocation: true
references: ../references/plan-mode.md, ../references/scm-detect.md, ../references/scm-github.md, ../references/scm-gitlab.md
argument-hint: "[github/gitlab repo URL or path] [branch/PR/MR/commit refs]"
---

## system

### Code Pull: Adapt Changes from a Reference Repository

> **ALWAYS enter plan mode.** Read the `plan-mode` reference (strict variant) for full directives — resolve references from the `<References>` block via MCP filesystem tools.
>
> - Use `EnterPlanMode` tool immediately.
> - Analyze the reference changes and plan how to adapt them before writing any code.
> - Present findings and proposed changes to the user.
> - Do NOT write code until the user explicitly approves.

### Core Requirements

> Read the `scm-detect` reference to detect the SCM platform and access local git MCP tools — resolve references from the `<References>` block via MCP filesystem tools. Then read the matching platform reference (`scm-github` or `scm-gitlab`) for provider-specific tools.

- Determine the source platform (GitHub or GitLab) from the provided URL or remote origin.
- The current repository and the reference repository are similar but NOT identical. Changes must be adapted, not blindly copied.

### Process

1. **Clarify the source.** Determine what to pull from the reference repository. Ask the user if any of the following is ambiguous:
   - Which repository? (URL or project path.)
   - Which changes? A PR/MR, a branch, or specific commits.
   - If no specific commits or PR/MR are given and the reference is the default branch, ask which commits to look at.
2. **Fetch reference changes.** Based on what the user specified:
   - **PR/MR:** Read the diff and commit list via `github__pull_request_read` (method `get_diff`) or `gitlab__get_merge_request_diffs`.
   - **Specific commits:** Read each commit via `github__get_commit` or `gitlab__get_commit_diff`.
   - **Branch:** List recent commits via `github__list_commits` or `gitlab__list_commits` and read relevant diffs.
3. **Understand the reference changes.** Read the full diff and affected files in the reference repository. Summarize what each change does logically — not just file-by-file, but the intent behind the changes.
4. **Analyze the current repository.** Read the corresponding files in the current repository. Identify structural differences: naming conventions, file layout, framework differences, language idioms, existing patterns.
5. **Plan the adaptation.** For each reference change, determine how it maps to the current repository:
   - Direct applicability — the change maps cleanly.
   - Deviation needed — the change requires a different approach. Explain why.
   - Not applicable — the change does not apply to this repository. Explain why.
6. **Present the plan.** Output the full plan in chat:
   - List each reference change and its corresponding adaptation.
   - Clearly list all deviations with rationale.
   - Highlight anything that does not apply and why.
   - Ask the user to review and approve.
7. **Iterate.** Refine the plan based on user feedback until approved.
8. **Apply changes.** After explicit approval, exit plan mode and implement the adapted changes in the current repository.

### Key Principles

- **Never blindly copy.** The repositories are similar but not identical. Every change must be evaluated for fit.
- **List all deviations.** If a change needs a different approach in the current repository, explain what differs and why the adaptation is necessary.
- **Ask when ambiguous.** If the user's intent is unclear — which commits, which files, which approach — ask before proceeding.
- **Preserve local conventions.** The current repository's patterns, naming, and structure take priority over the reference repository's style.
- **Be thorough in analysis.** Read both the reference and local files before proposing any changes. Do not assume files are identical.

### Related Skills

- **`/code-review-branch`** (`~/.config/nvim/utils/agents/skills/code-review-branch/SKILL.md`) — for reviewing the adapted changes after applying them. Do not auto-invoke.
