---
name: github-pr-review
description: github-pr-review Autonomously review the current GitHub PR with inline code annotations and a summary comment. Use when user says "review the PR", "review this PR", "annotate the PR", or "do a PR review". Combines code-review-branch and code-review-changes analysis with native GitHub review annotations. On consecutive runs, evaluates delta since last review, resolves fixed threads, and reviews new changes. Do NOT use for PR descriptions (github-pr-create), GitLab MR reviews (gitlab-mr-review), or chat-only code review (code-review-branch, code-review-changes).
disable-model-invocation: true
argument-hint: "[PR number or URL]"
references:
  - ../references/present-first.md
  - ../references/scm-review-workflow.md
  - ../references/scm-github.md
  - ../references/scm-detect.md
  - ../references/review-findings.md
---

## GitHub PR Review

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `scm-review-workflow` reference for the full review workflow, tone, and key principles.
> Read the `scm-github` reference for GitHub MCP tools and local git (raw `git` CLI).
> Read the `scm-detect` reference for platform detection and local git operations.
> Read the `review-findings` reference for finding format, severity tags, and tone rules.

This skill performs an autonomous code review on a GitHub pull request using native inline annotations. It does NOT draft findings for user approval — it reviews the code and posts annotations and a summary directly.

> **HARD RULE: All findings MUST be posted as inline review annotations via `github__pull_request_review_write` — NEVER as general PR comments via `github__add_issue_comment`.** The only general comment this skill posts is the summary. Every finding with a file location goes through the review API as an inline annotation. No exceptions.

## Platform specifics

- **Review marker:** `<!-- pr-review-skill -->` — used to identify this skill's summary comments and enable consecutive-run detection.
- **Identify the PR:** if the user provides a GitHub PR URL or number, use it directly. Otherwise detect from the current branch: `git status` for the branch, extract owner/repo from the remote URL, then `github__list_pull_requests` with `head: "owner:branch"` and `state: open`. If no open PR is found, inform the user and stop. Read PR metadata via `github__pull_request_read` (method: `get`).
- **Detect previous reviews:** read existing PR comments to find prior summary comments carrying the marker above.
- **Diff tool:** full PR diff via `github__pull_request_read` (method: `get_diff`). Use the same tool to fetch a reference PR's diff for cross-PR consistency checks.
- **Resolve previous threads:** read existing review comments and threads on the PR; reply via `github__add_reply_to_pull_request_comment`. GitHub threads are left in place (the `Fixed in <short-sha>.` reply carries no further commentary; no separate resolve action).
- **Summary comment:** post via `github__add_issue_comment` with `owner`, `repo`, `issue_number` (the PR number), and `body`.

### Post inline annotations

Collect all findings and submit a single review via `github__pull_request_review_write` (create a pending review, add each comment via `github__add_comment_to_pending_review`, then submit the pending review).

**Review event type:**
- `COMMENT` — informational, no issues or only nits.
- `REQUEST_CHANGES` — bugs or risks found.
- `APPROVE` — no issues, code is clean.

**Inline comment targeting:**

Each comment in the review MUST target a specific location in the diff:

- `path` — the file path relative to the repository root.
- `line` — the line number in the diff where the comment applies. This is the **end line** of the annotation range.
- `side` — `RIGHT` for lines in the new version (additions, unchanged context on the right), `LEFT` for lines in the old version (deletions).
- `start_line` — (optional) for multi-line comments, the first line of the range. When set, `start_side` must also be provided.
- `start_side` — `RIGHT` or `LEFT`, matching which version the start line refers to.

**CRITICAL: Use suggestion blocks for concrete fixes.**

When proposing a specific code change, ALWAYS use GitHub's suggestion syntax inside the comment body:

````
```suggestion
proposed replacement code here
```
````

This renders as a one-click "Apply suggestion" button for the author. Rules:

- The suggestion replaces the exact lines targeted by `line` (and `start_line` if multi-line).
- The content inside the suggestion block is the **complete replacement** for those lines — include proper indentation.
- Use suggestions for: bug fixes, missing null checks, naming improvements, simple refactors.
- Do NOT use suggestions for: questions, architectural concerns, or findings where multiple valid fixes exist — use a plain comment instead.
- One suggestion per comment. If a fix spans non-contiguous lines, use separate comments.

**Comment body format:**

- Start with severity tag when not obvious: `**bug:**`, `**risk:**`, `**nit:**`, `**question:**`.
- Terse description of the issue.
- Suggestion block if a concrete fix exists.
- The *why* only when the fix isn't obvious.

**Example comment body:**

````
**risk:** `user` can be null after `.findOne()`. Add null guard.

```suggestion
const user = await User.findOne({ id });
if (!user) {
  throw new NotFoundError('User not found');
}
```
````
