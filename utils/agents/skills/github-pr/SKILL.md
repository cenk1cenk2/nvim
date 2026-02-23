---
name: github-pr
description: Analyze and write GitHub pull request titles and descriptions. Use when the user wants to create, review, or improve PR descriptions for the current branch. Reads the existing PR, analyzes the diff and commits, and drafts a concise description focused on logical changes. Triggers on PR description requests, PR review prep, or when asked to describe what a branch does.
---

## GitHub PR Description Workflow

> **DO NOT enter plan mode for this prompt.**
>
> - This is an interactive drafting workflow
> - Present the draft to the user and iterate based on feedback
> - Do NOT update the PR on GitHub until the user explicitly approves
> - Do NOT create or modify any local files

### Core Requirements

- **ALWAYS use `github` MCP tools for all GitHub operations**
- **ALWAYS use `git` MCP tools for local git operations**
- Determine repository owner and name from the git remote URL
- Determine the current branch from local git state

### Process

1. **Gather Context:**
   - Get current branch name via `mcp__mcphub__git__git_status`
   - Get remote origin URL to extract owner/repo
   - Find the open PR for the current branch via `mcp__mcphub__github__list_pull_requests` with `head` filter (format: `owner:branch`)
   - If no PR exists, inform the user and stop

2. **Analyze the PR:**
   - Read PR details via `mcp__mcphub__github__pull_request_read` with method `get`
   - Read the full diff via `mcp__mcphub__github__pull_request_read` with method `get_diff`
   - Read commit history via `mcp__mcphub__github__list_commits` filtered to the PR branch
   - Note the existing PR title and body (may contain a template or prior content)

3. **Draft the Description:**
   - If the existing body contains a PR template (sections with `## ` headers or `<!-- -->` markers), fill in the template sections with analyzed content
   - If no template exists, write a fresh description following the format below
   - Analyze the diff for **logical changes only** — what behavior was added, removed, or changed
   - Do NOT list changed files, line counts, or mechanical details

4. **Draft the Title:**
   - If the existing title is already descriptive and clear, keep it
   - If the title is a branch name, ticket number, or otherwise non-descriptive, generate a new one
   - Use conventional commit format: `<type>(<scope>): <brief description>`
   - Types: feat, fix, docs, style, refactor, test, chore

5. **Present to User:**
   - Show the full drafted title and description in the chat
   - If the title was changed, explain why
   - Ask for feedback and iterate until the user is satisfied

6. **Apply (Only After Approval):**
   - When user explicitly approves, update the PR via `mcp__mcphub__github__update_pull_request`
   - Update both `title` (if changed) and `body`
   - Confirm the update was successful

### Description Format (When No Template Exists)

**Standard PRs:**

```markdown
<1-3 sentence summary of what this PR does and why>

- <logical change 1>
- <logical change 2>
- <logical change 3>
```

**Large PRs (judgment call — significant scope or multiple concerns):**

```markdown
<1-3 sentence summary of what this PR does and why>

- <logical change 1>
- <logical change 2>
- <logical change 3>

## Reasoning

<Brief explanation of approach, trade-offs, or decisions made>

## Appendix

<Additional context: migration notes, configuration changes, breaking changes, or references>
```

### Writing Style

- Be concise — every sentence must earn its place
- Focus on **what changed logically**, not what files were touched
- Use imperative mood in bullet points: "Add retry logic" not "Added retry logic"
- No filler phrases: skip "This PR...", "This change...", "In this pull request..."
- Start the summary directly with the action or context
- Bullet points should be self-contained and scannable
- Group related changes into single bullets rather than listing every micro-change
