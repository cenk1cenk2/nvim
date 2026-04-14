---
name: gitlab-pr-read
description: Read and internalize the full state of a GitLab MR — description, comments, discussion threads, and diff. Use when user says "read this MR", "load the MR", "what's in this MR", or "summarize this MR". Purely informational — does not modify anything. Do NOT use for reviewing MRs (gitlab-pr-review), fixing MR threads (gitlab-pr-fix), or writing MR descriptions (gitlab-pr).
interaction: chat
disable-model-invocation: true
argument-hint: "[MR number or URL]"
references:
  - ../references/scm-gitlab.md
  - ../references/scm-detect.md
---

## system

### GitLab MR Read

> **DO NOT enter plan mode.** This is a read-only skill — fetch, internalize, and summarize.

> Read the `scm-gitlab` reference for GitLab MCP tools and git MCP tools.
> Read the `scm-detect` reference for platform detection and local git operations.

This skill reads the entire state of a GitLab merge request and presents a structured summary. It does NOT modify anything — no comments, no reviews, no code changes. The purpose is to load the MR into context so subsequent questions or skills can reference it.

### Process

#### Step 1: Identify the MR

- If the user provides a GitLab MR URL or number, use it directly.
- If not provided, detect from the current branch:
  - Use `git__git_status` to get the current branch.
  - Extract the project path from the remote URL.
  - Use `gitlab__list_merge_requests` with `source_branch` filter and `state: opened` to find the open MR.
- If no open MR is found, inform the user and stop.

#### Step 2: Read MR Metadata

Use `gitlab__get_merge_request` to fetch:

- Title, description, author.
- State (opened, closed, merged).
- Labels, assignees, reviewers.
- Source and target branches.
- Merge status.
- Created and updated timestamps.

Use `gitlab__get_merge_request_approval_state` to fetch approval status:

- Required approvals vs current approvals.
- Who has approved, who hasn't.

#### Step 3: Read the Diff

Use `gitlab__get_merge_request_diffs` to get the full diff.

- Note the list of changed files.
- Note total additions and deletions.
- Understand the logical grouping of changes.

#### Step 4: Read MR Notes

Use `gitlab__get_merge_request_notes` to fetch all general MR notes (non-discussion comments, system notes, etc.).

- Note key discussion points, decisions, and questions.
- Note any bot or system notes (pipeline results, approvals, etc.).

#### Step 5: Read Discussion Threads

Use `gitlab__mr_discussions` to fetch all discussion threads (inline and general).

For each thread, note:
- File path and line range (if positioned on the diff).
- Resolved or unresolved status.
- Full conversation (all notes in the thread).
- Any pending suggestions.

#### Step 6: Read Version and Commit History

Use `gitlab__list_merge_request_versions` to understand the diff version progression:

- Note version count and timestamps.

Use `gitlab__list_commits` for the MR branch:

- Note commit count, authors, and messages.

#### Step 7: Present Summary

Present a structured summary to the user:

```
### MR !N: <title>

**Author:** <author> | **State:** <state> | **Branch:** <source> → <target>
**Created:** <date> | **Updated:** <date>
**Labels:** <labels> | **Reviewers:** <reviewers>
**Approvals:** <approval status summary>

#### Description
<MR description — condensed if very long>

#### Changes
<High-level summary of what the diff contains — grouped by logical concern, not by file>

#### Notes (<count>)
<Summary of general MR notes — key discussion points, decisions made>

#### Discussion Threads
**Open:** N | **Resolved:** M
<For each open thread: file:line — one-line summary of the concern>

#### Versions (<count>)
<List of diff versions with timestamps>

#### Commits (<count>)
<List of commits with short SHAs and messages>
```

- If a section has no content (e.g., no notes), include the heading with "None."
- Condense long descriptions and thread histories — summarize, don't copy verbatim.

### Key Principles

- **Read-only.** This skill does not modify anything — no comments, no reviews, no code changes.
- **Comprehensive.** Read everything: metadata, description, diff, notes, discussion threads, versions, commits. Leave nothing unread.
- **Structured output.** Present information in a scannable format so the user or subsequent skills can reference specific aspects.
- **Context loading.** The primary purpose is to internalize the MR state so that follow-up questions or skills can reference it without re-fetching.
- **No opinions.** Present facts, not judgments. Do not evaluate code quality or suggest changes — other skills handle that.
