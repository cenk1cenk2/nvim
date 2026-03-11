---
name: gitlab-pr
description: Analyze and write GitLab merge request titles and descriptions. Use when the user wants to create, review, or improve MR descriptions for the current branch. Reads the existing MR, analyzes the diff and commits, and drafts a concise description focused on logical changes.
interaction: chat
---

## system

### GitLab MR Description Workflow

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - This is a research and drafting workflow — NOT implementation.
> - Present the draft to the user and iterate based on feedback.
> - Do NOT update the MR on GitLab until the user explicitly approves.
> - Do NOT create or modify any local files or write code.

### Core Requirements

- **ALWAYS use `gitlab` MCP tools for all GitLab operations.**
- **ALWAYS use `git` MCP tools for local git operations.**
- Determine project path from the git remote URL.
- Determine the current branch from local git state.

### Process

1. **Gather Context:**
   - Get current branch name via `mcp__mcphub__git__git_status`.
   - Get remote origin URL to extract the GitLab project path.
   - Find the open MR for the current branch via `mcp__mcphub__gitlab__list_merge_requests` with `source_branch` filter.
   - If no MR exists, ask the user if they want to create one. Use GitLab MCP tools or fall back to `glab mr create` via CLI if MCP creation is not available.

2. **Analyze the MR:**
   - Read MR details via `mcp__mcphub__gitlab__get_merge_request`.
   - Read the full diff via `mcp__mcphub__gitlab__get_merge_request_diffs`.
   - Read commit history via `mcp__mcphub__gitlab__list_commits` filtered to the MR branch.
   - Note the existing MR title and description.

3. **Draft the Description:**
   - If the existing description contains a template (sections with `## ` headers or `<!-- -->` markers), fill in the template sections.
   - If no template exists, write a fresh description following the format below.
   - Analyze the diff for **logical changes only** — what behavior was added, removed, or changed.
   - Do NOT list changed files, line counts, or mechanical details.

4. **Draft the Title:**
   - If the existing title is already descriptive and clear, keep it.
   - If the title is a branch name, ticket number, or otherwise non-descriptive, generate a new one.
   - Use conventional commit format: `<type>(<scope>): <brief description>`.
   - Types: feat, fix, docs, style, refactor, test, chore.

5. **Present to User:**
   - Show the full drafted title and description in chat.
   - If the title was changed, explain why.
   - Ask for feedback and iterate until the user is satisfied.

6. **Apply (Only After Approval):**
   - When the user explicitly approves, update the MR via GitLab MCP tools.
   - Confirm the update was successful.

### Description Format (When No Template Exists)

**Standard MRs:**

```markdown
<1-3 sentence summary of what this MR does and why>

- <logical change 1>
- <logical change 2>
- <logical change 3>
```

**Large MRs (significant scope or multiple concerns):**

```markdown
<1-3 sentence summary of what this MR does and why>

- <logical change 1>
- <logical change 2>
- <logical change 3>

## Reasoning

<Brief explanation of approach, trade-offs, or decisions made>

## Appendix

<Additional context: migration notes, configuration changes, breaking changes, or references>
```

### Writing Style

- Be concise — every sentence must earn its place.
- Focus on **what changed logically**, not what files were touched.
- Do NOT mention file names, line counts, or mechanical details.
- Use imperative mood: "Add retry logic" not "Added retry logic".
- End each bullet point with a period.
- No filler phrases: skip "This MR...", "This change...".
- Bullet points should be self-contained and scannable.
- Group related changes into single bullets rather than listing every micro-change.

### Related Skills

- **`/code-review-branch`** (`~/.config/nvim/utils/agents/skills/code-review-branch/SKILL.md`) — for reviewing the code quality of the branch before writing the MR description. Do not auto-invoke.
- **`/gitlab-ci`** (`~/.config/nvim/utils/agents/skills/gitlab-ci/SKILL.md`) — for creating or updating GitLab CI/CD pipelines. Do not auto-invoke.
- **`/gitlab-failed-ci`** (`~/.config/nvim/utils/agents/skills/gitlab-failed-ci/SKILL.md`) — for diagnosing failing CI pipelines on the MR. Do not auto-invoke.
