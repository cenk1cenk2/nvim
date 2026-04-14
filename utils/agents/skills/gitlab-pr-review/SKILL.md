---
name: gitlab-pr-review
description: Autonomously review the current GitLab MR with inline code annotations and a summary comment. Use when user says "review the MR", "review this MR", "annotate the MR", or "do an MR review". Combines code-review-branch and code-review-changes analysis with native GitLab discussion annotations. On consecutive runs, evaluates delta since last review, resolves fixed threads, and reviews new changes. Do NOT use for MR descriptions (gitlab-pr), GitHub PR reviews (github-pr-review), or chat-only code review (code-review-branch, code-review-changes).
interaction: chat
disable-model-invocation: true
argument-hint: "[MR number or URL]"
references:
  - ../references/scm-gitlab.md
  - ../references/scm-detect.md
  - ../references/review-findings.md
---

## system

### GitLab MR Review

> **DO NOT enter plan mode.** This is an autonomous review workflow — analyze, annotate, and summarize without user approval.

> Read the `scm-gitlab` reference for GitLab MCP tools and git MCP tools.
> Read the `scm-detect` reference for platform detection and local git operations.
> Read the `review-findings` reference for finding format, severity tags, and tone rules.

This skill performs an autonomous code review on a GitLab merge request using native inline discussion threads. It does NOT draft findings for user approval — it reviews the code and posts annotations and a summary directly.

### Process

#### Step 1: Identify the MR

- If the user provides a GitLab MR URL or number, use it directly.
- If not provided, detect from the current branch:
  - Use `git__git_status` to get the current branch.
  - Extract the project path from the remote URL.
  - Use `gitlab__list_merge_requests` with `source_branch` filter and `state: opened` to find the open MR.
- If no open MR is found, inform the user and stop.
- Read MR metadata via `gitlab__get_merge_request`.

#### Step 2: Detect Previous Reviews

- Read existing MR notes via `gitlab__get_merge_request_notes` to find prior summary comments from this skill.
- Summary comments are identified by the marker `<!-- mr-review-skill -->` at the top.
- If a previous summary exists, extract the **reviewed commit SHA** from it.
- If no previous review exists, this is a **first run**.

#### Step 3: Determine Review Scope

**First run:**
- Get the full MR diff via `gitlab__get_merge_request_diffs`.
- Record the current HEAD commit SHA as the review baseline.

**Consecutive run:**
- Get the diff between the previously reviewed commit SHA and current HEAD via `git__git_diff`.
- If no new changes exist since the last review, inform the user and stop.
- Also re-read the full MR diff for context on existing annotations.

#### Step 4: Resolve Previous Threads (consecutive runs only)

- Read existing MR discussions via `gitlab__mr_discussions`.
- For each open discussion thread from a previous run:
  - Check if the flagged code has been changed in the new commits.
  - If **fixed** — reply to the thread: `Fixed in <short-sha>.` and resolve the thread.
  - If **still present and unchanged** — leave it. Do not repeat the same finding.
  - If **changed but not fixed** — reply with an updated observation.
- Use `gitlab__mr_discussions` to post thread replies.

#### Step 5: Analyze the Changes

Apply the review methodology from `code-review-branch` and `code-review-changes`:

- **Read surrounding code** — the diff alone is never enough. Trace call sites, check types, read related files.
- **Use `sequentialthinking__sequentialthinking`** to methodically work through the diff.
- **What to look for:**
  - **Silent failures** — errors caught and ignored, missing error propagation, fallback values hiding problems.
  - **Logic errors** — off-by-one, wrong operator, inverted conditions, missing null/undefined checks.
  - **Security** — injection, auth bypass, secret exposure, unsanitized input at boundaries.
  - **Edge cases** — empty input, large data, concurrent access, failure paths.
  - **Error handling** — swallowed errors, missing rollback.
  - **Inconsistency** — new code deviating from existing codebase patterns.
  - **Unnecessary complexity** — over-engineering, premature abstraction, dead code.
- **No noise** — only flag real issues. Silence means approval.
- **Be specific** — concrete problem and fix, not vague suggestions.

#### Step 6: Post Inline Annotations

Create a discussion thread for each finding via `gitlab__mr_discussions`.

**Diff-position targeting:**

Each discussion MUST be positioned on a specific line in the MR diff using the position object:

- `position_type` — `text` for code comments.
- `new_path` — file path in the new version (for additions or unchanged lines).
- `old_path` — file path in the old version (for deletions or renames).
- `new_line` — line number in the new version. Use for comments on added or unchanged lines.
- `old_line` — line number in the old version. Use for comments on deleted lines.
- `base_sha`, `head_sha`, `start_sha` — commit SHAs from the MR diff metadata. Extract these from `gitlab__get_merge_request_diffs` or `gitlab__list_merge_request_versions`.

For a comment on an **added line**: set `new_path` and `new_line`. Leave `old_line` null.
For a comment on a **deleted line**: set `old_path` and `old_line`. Leave `new_line` null.
For a comment on an **unchanged context line**: set both `old_line` and `new_line`, and both paths.

**CRITICAL: Use suggestion blocks for concrete fixes.**

When proposing a specific code change, ALWAYS use GitLab's suggestion syntax inside the comment body:

````
```suggestion:-0+0
proposed replacement code here
```
````

The suggestion syntax supports line offsets: `suggestion:-N+M` replaces from N lines above to M lines below the commented line. Default `suggestion:-0+0` replaces the single commented line.

Rules:

- The content inside the suggestion block is the **complete replacement** for the targeted lines — include proper indentation.
- Use suggestions for: bug fixes, missing null checks, naming improvements, simple refactors.
- Do NOT use suggestions for: questions, architectural concerns, or findings where multiple valid fixes exist — use a plain comment instead.
- For multi-line replacements, use the offset syntax: `suggestion:-2+0` to include 2 lines above the commented line in the replacement range.
- One suggestion per comment. If a fix spans non-contiguous lines, use separate discussion threads.

**Comment body format:**

- Start with severity tag when not obvious: `**bug:**`, `**risk:**`, `**nit:**`, `**question:**`.
- Terse description of the issue.
- Suggestion block if a concrete fix exists.
- The *why* only when the fix isn't obvious.

**Example comment body:**

````
**risk:** `user` can be null after `.find_by`. Add null guard.

```suggestion:-0+0
user = User.find_by(id: params[:id])
raise ActiveRecord::RecordNotFound, 'User not found' unless user
```
````

#### Step 7: Post Summary Comment

Post a top-level note on the MR via `gitlab__mr_discussions` (without diff position — general comment) with this structure:

```markdown
<!-- mr-review-skill -->
**Review — `<short-sha>`**

<1-3 sentence summary of review findings and overall assessment.>

| Severity | Count |
|----------|-------|
| bug      | N     |
| risk     | N     |
| nit      | N     |

<If consecutive run: brief note on resolved threads and new findings.>
```

The `<!-- mr-review-skill -->` marker and commit SHA are required — they enable consecutive run detection.

### Review Tone

Follow the `review-findings` reference tone:

- No hedging, no filler praise, no throat-clearing.
- Terse and specific. One finding per annotation.
- Include the *why* only when the fix isn't obvious.
- Security findings and architectural concerns get full paragraphs.

### Key Principles

- **Autonomous.** No drafts, no approval prompts. Review and post directly.
- **Suggestions over descriptions.** When the fix is clear, use a `suggestion` block so the author can apply it in one click. Do not describe the fix in prose when a suggestion block conveys it better.
- **Incremental.** Consecutive runs only review new changes and resolve old threads.
- **Native annotations.** Use GitLab's discussion API with diff positions for inline comments, not chat output.
- **Commit-tracked.** Every summary records the reviewed commit SHA for future delta detection.
- **No noise.** If the code is clean, say so in one sentence. Do not invent findings.
