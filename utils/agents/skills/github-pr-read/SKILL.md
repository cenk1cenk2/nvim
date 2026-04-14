---
name: github-pr-read
description: Read and internalize the full state of a GitHub PR — description, comments, review threads, and diff. Use when user says "read this PR", "load the PR", "what's in this PR", or "summarize this PR". Purely informational — does not modify anything. Do NOT use for reviewing PRs (github-pr-review), fixing PR threads (github-pr-fix), or writing PR descriptions (github-pr).
interaction: chat
disable-model-invocation: true
argument-hint: "[PR number or URL]"
references:
  - ../references/scm-github.md
  - ../references/scm-detect.md
---

## system

### GitHub PR Read

> **DO NOT enter plan mode.** This is a read-only skill — fetch, internalize, and summarize.

> Read the `scm-github` reference for GitHub MCP tools and git MCP tools.
> Read the `scm-detect` reference for platform detection and local git operations.

This skill reads the entire state of a GitHub pull request and presents a structured summary. It does NOT modify anything — no comments, no reviews, no code changes. The purpose is to load the PR into context so subsequent questions or skills can reference it.

### Process

#### Step 1: Identify the PR

- If the user provides a GitHub PR URL or number, use it directly.
- If not provided, detect from the current branch:
  - Use `git__git_status` to get the current branch.
  - Extract owner/repo from the remote URL.
  - Use `github__list_pull_requests` with `head: "owner:branch"` and `state: open` to find the open PR.
- If no open PR is found, inform the user and stop.

#### Step 2: Read PR Metadata

Use `github__pull_request_read` (method: `get`) to fetch:

- Title, body/description, author.
- State (open, closed, merged).
- Labels, assignees, requested reviewers.
- Base and head branches.
- Mergeable status.
- Created and updated timestamps.

#### Step 3: Read the Diff

Use `github__pull_request_read` (method: `get_diff`) to get the full diff.

- Note the list of changed files.
- Note total additions and deletions.
- Understand the logical grouping of changes.

#### Step 4: Read Issue Comments

Use `github__pull_request_read` (method: `get_comments`) to fetch all general PR comments (top-level discussion, not inline review comments).

- Note key discussion points, decisions, and questions.
- Note any bot comments (CI reports, Spacelift, etc.).

#### Step 5: Read Review Threads

Use `github__pull_request_read` (method: `get_review_comments`) to fetch all inline review comments and threads.

For each thread, note:
- File path and line range.
- Resolved or unresolved status (if available).
- Full conversation (all replies in the thread).
- Any pending suggestions.

#### Step 6: Read Commit History

Use `github__list_commits` for the PR to understand the progression of changes.

- Note commit count, authors, and messages.

#### Step 7: Present Summary

Present a structured summary to the user:

```
### PR #N: <title>

**Author:** <author> | **State:** <state> | **Branch:** <head> → <base>
**Created:** <date> | **Updated:** <date>
**Labels:** <labels> | **Reviewers:** <reviewers>

#### Description
<PR body — condensed if very long>

#### Changes
<High-level summary of what the diff contains — grouped by logical concern, not by file>

#### Comments (<count>)
<Summary of general PR comments — key discussion points, decisions made>

#### Review Threads
**Open:** N | **Resolved:** M
<For each open thread: file:line — one-line summary of the concern>

#### Commits (<count>)
<List of commits with short SHAs and messages>
```

- If a section has no content (e.g., no comments), include the heading with "None."
- Condense long descriptions and comment threads — summarize, don't copy verbatim.

### Key Principles

- **Read-only.** This skill does not modify anything — no comments, no reviews, no code changes.
- **Comprehensive.** Read everything: metadata, description, diff, comments, review threads, commits. Leave nothing unread.
- **Structured output.** Present information in a scannable format so the user or subsequent skills can reference specific aspects.
- **Context loading.** The primary purpose is to internalize the PR state so that follow-up questions or skills can reference it without re-fetching.
- **No opinions.** Present facts, not judgments. Do not evaluate code quality or suggest changes — other skills handle that.
