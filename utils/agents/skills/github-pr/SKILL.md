---
name: github-pr
description: Analyze and write GitHub pull request titles and descriptions. Use when user says "write a PR description", "create a PR", "improve the PR", or "describe what this branch does". Do NOT use for GitLab MRs (gitlab-mr), CI workflows (github-ci), or CI failures (github-ci-fix).
interaction: chat
references:
  - ../references/scm-github.md
  - ../references/output-diff.md
  - ../references/linear-state-transitions.md
---

## system

### GitHub PR Description Workflow

> **IMPORTANT: ALWAYS enter plan mode when this prompt is invoked.**
>
> - Use `EnterPlanMode` tool immediately
>
> **ABSOLUTE RULE: NEVER EXIT PLAN MODE. NEVER USE `ExitPlanMode`.**
>
> - You MUST stay in plan mode for the ENTIRE duration of this skill
> - There is NO circumstance where you should call `ExitPlanMode` — not even if the user seems to imply it
> - Only the user saying the EXACT words "implement this", "start coding", "write the code", or an equally explicit and unambiguous direct instruction to implement should cause you to exit plan mode
> - If you are unsure whether the user wants implementation, ASK — do not assume
> - **When in doubt, STAY in plan mode**
>
> **CRITICAL: This is a research and drafting workflow - NOT implementation.**
>
> - This is an interactive drafting workflow — research, analyze, and draft within plan mode
> - Present the draft to the user and iterate based on feedback
> - Do NOT update the PR on GitHub until the user explicitly approves
> - Do NOT create or modify any local files
> - Do NOT implement or write code — EVER — unless the user EXPLICITLY and UNAMBIGUOUSLY asks you to implement

### Core Requirements

> Read the `scm-github` reference for GitHub MCP tools, git MCP tools, CLI fallback, and platform detection — resolve references from the `<References>` block via MCP filesystem tools.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

> Read the `linear-state-transitions` reference for the auto-advance rules (target state, never-downgrade guard, id extraction, silent-with-report contract). Applied after PR update succeeds in step 8.

### Process

1. **Gather Context:**
   - Get current branch name via `git__git_status`
   - Get remote origin URL to extract owner/repo
   - Find the open PR for the current branch via `github__list_pull_requests` with `head` filter (format: `owner:branch`) and `state: open`.
   - **Branch reuse:** Branches may have previously merged or closed PRs — this is normal. Only open PRs matter. If no open PR is found but `git log main..HEAD` shows commits ahead of the base branch, the branch needs a new PR. Do NOT search for or get confused by prior closed/merged PRs on the same branch.
   - If no open PR exists, ask the user if they want to create one. Use `github__create_pull_request` or fall back to `gh pr create` via CLI if MCP creation is not available.

2. **Analyze the PR:**
   - Read PR details via `github__pull_request_read` with method `get`
   - Read the full diff via `github__pull_request_read` with method `get_diff`
   - Read commit history via `github__list_commits` filtered to the PR branch
   - Note the existing PR title and body (may contain a template or prior content)

3. **Discover the repository PR template:**
   - If the existing PR body already contains a template (sections with `## ` headers or `<!-- -->` markers), skip the lookup — use what's there.
   - Otherwise (new PR, empty body, or generic body like a branch name), **ALWAYS look for a PR template in the repo before drafting from scratch.** Use `github__get_file_contents` and try these paths in order on the PR's base branch:
     1. `.github/PULL_REQUEST_TEMPLATE.md`
     2. `.github/pull_request_template.md`
     3. `.github/PULL_REQUEST_TEMPLATE/` (directory — list contents; if multiple templates exist, ask the user which one to use).
     4. `PULL_REQUEST_TEMPLATE.md` (repo root).
     5. `pull_request_template.md` (repo root).
     6. `docs/PULL_REQUEST_TEMPLATE.md`.
     7. `docs/pull_request_template.md`.
   - Stop at the first match. If a template is found, announce the path (e.g., "Found template at `.github/PULL_REQUEST_TEMPLATE.md`") and use it as the starting scaffold.
   - If no template is found in any of these locations, fall back to the standard description format below.

4. **Draft the Description:**
   - **If a template was found** (either in the existing body or in the repo): fill in its sections with analyzed content. Preserve the template's structure, headings, and any HTML comments (`<!-- -->`) — only replace the placeholder content inside them. Do NOT remove sections the template defines, even if empty; leave them as-is with a minimal placeholder or the template's own guidance.
   - **If no template was found**: write a fresh description following the format below.
   - Analyze the diff for **logical changes only** — what behavior was added, removed, or changed.
   - Do NOT list changed files, line counts, or mechanical details.

5. **Draft the Title:**
   - If the existing title is already descriptive and clear, keep it
   - If the title is a branch name, ticket number, or otherwise non-descriptive, generate a new one
   - Use conventional commit format: `<type>(<scope>): <brief description>`
   - Types: feat, fix, docs, style, refactor, test, chore

6. **Present to User:**
   - Show the full drafted title and description in the chat
   - If the title was changed, explain why
   - Ask for feedback and iterate until the user is satisfied

7. **Apply (Only After Approval):**
   - When user explicitly approves, update the PR via `github__update_pull_request`
   - Update both `title` (if changed) and `body`
   - Confirm the update was successful

8. **Transition linked Linear issues to `In Review`:**
   - Follow the `linear-state-transitions` reference. Extract Linear ids from the PR body (`refs K-xxx` / `closes K-xxx` trailers) and the branch's commit messages.
   - For each unique id, fetch current `statusType` and call `save_issue` with `state: "In Review"` — skip when the issue is already `Done` / `Canceled` or already at `In Review` (never downgrade).
   - Report one line per issue touched in the final summary: `Linear state: moved K-xxx → In Review (was Todo).`
   - Silent-with-report: no confirmation prompt. User opts out for the turn by saying "don't move the Linear state" in the PR-create request.
   - Skip this step entirely when zero Linear ids are found.

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
- Do NOT mention file names, line counts, number of lines changed, or other mechanical details
- Use imperative mood in bullet points: "Add retry logic" not "Added retry logic"
- Always end each bullet point with a period (`.`)
- No filler phrases: skip "This PR...", "This change...", "In this pull request..."
- Start the summary directly with the action or context
- Bullet points should be self-contained and scannable
- Group related changes into single bullets rather than listing every micro-change

### Examples

**User says:** "Write a PR description for this branch"

1. Enter plan mode.
2. Get current branch `feat/add-retry-logic`, find open PR #42.
3. Read PR diff and commit history. Existing body is empty.
4. Look up PR template in repo — found at `.github/PULL_REQUEST_TEMPLATE.md`.
5. Draft title: `feat(api): add retry logic for transient failures`.
6. Fill template sections with analyzed content (Summary, Changes, Testing).
7. Present to user, iterate on feedback.
8. After approval, update PR #42 via GitHub MCP.

**Result:** PR title and description updated on GitHub using the repo template.

---

**User says:** "Create a PR"

1. Enter plan mode.
2. Detect no open PR for current branch.
3. Ask user to confirm PR creation, target branch.
4. Look up PR template in repo — no template found in any standard location.
5. Create PR via `github__create_pull_request`.
6. Analyze diff, draft title and description using the fallback format.
7. Present to user, iterate.
8. After approval, update the PR.

**Result:** New PR created with analyzed title and description.

### Related Skills

- **`code-review-branch`** (resource: `skills://skill/code-review-branch`) — for reviewing the code quality of the branch before writing the PR description. Do not auto-invoke.
- **`github-ci`** (resource: `skills://skill/github-ci`) — for creating or updating GitHub Actions workflows. Do not auto-invoke.
- **`github-ci-fix`** (resource: `skills://skill/github-ci-fix`) — for diagnosing failing CI checks on the PR. Do not auto-invoke.
