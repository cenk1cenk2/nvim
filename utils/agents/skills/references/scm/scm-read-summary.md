# SCM Read Summary

Shared read-and-summarize workflow for loading the full state of the current PR/MR into context. Used by `github-pr-read` (GitHub) and `gitlab-mr-read` (GitLab). The platform reference (`scm-github` / `scm-gitlab`) supplies the exact PR/MR-detection, metadata, diff, comment, thread, and commit tools; each skill lists the specific calls and any extra summary rows under its own "Platform specifics".

This skill reads the entire state of a pull/merge request and presents a structured summary. It does NOT modify anything — no comments, no reviews, no code changes. The purpose is to load the PR/MR into context so subsequent questions or skills can reference it.

## Process

### Identify the PR/MR

- If the user provides a PR/MR URL or number, use it directly.
- If not provided, detect from the current branch:
  - Use `git status` to get the current branch.
  - Extract the repository/project identity from the remote URL.
  - Use the platform's open-PR/MR lookup (see the skill's "Platform specifics") to find the open request.
- If no open PR/MR is found, inform the user and stop.

### Read the metadata, comments, threads, and commits

Fetch the full state using the platform's read tools (see the skill's "Platform specifics"):

- **Metadata** — title, description/body, author, state, labels, assignees, reviewers, source/target branches, merge status, created/updated timestamps.
- **Comments/notes** — general top-level discussion (not inline). Note key points, decisions, questions, and any bot/system output (CI reports, pipelines, approvals).
- **Threads** — inline review/discussion threads. For each, note the file path and line range, resolved/unresolved status, the full conversation, and any pending suggestions.
- **Commits** — the commit history for the branch. Note commit count, authors, and messages.

### Read the diff

Use the platform's diff tool (see the skill's "Platform specifics") to get the full diff.

- Note the list of changed files.
- Note total additions and deletions.
- Understand the logical grouping of changes.

### Present the summary

Present a structured summary to the user:

```
### <PR #N | MR !N>: <title>

**Author:** <author> | **State:** <state> | **Branch:** <source> → <target>
**Created:** <date> | **Updated:** <date>
**Labels:** <labels> | **Reviewers:** <reviewers>

#### Description
<body — condensed if very long>

#### Changes
<High-level summary of what the diff contains — grouped by logical concern, not by file>

#### <Comments | Notes> (<count>)
<Summary of general discussion — key discussion points, decisions made>

#### <Review | Discussion> Threads
**Open:** N | **Resolved:** M
<For each open thread: file:line — one-line summary of the concern>

#### Commits (<count>)
<List of commits with short SHAs and messages>
```

- Each skill's "Platform specifics" lists the exact section labels its platform uses and any additional header rows or sections (e.g. approval status, diff versions).
- If a section has no content (e.g., no comments), include the heading with "None."
- Condense long descriptions and thread histories — summarize, don't copy verbatim.

## Key Principles

- **Read-only.** This skill does not modify anything — no comments, no reviews, no code changes.
- **Comprehensive.** Read everything: metadata, description, diff, comments/notes, threads, commits (and any platform extras). Leave nothing unread.
- **Structured output.** Present information in a scannable format so the user or subsequent skills can reference specific aspects.
- **Context loading.** The primary purpose is to internalize the PR/MR state so that follow-up questions or skills can reference it without re-fetching.
- **No opinions.** Present facts, not judgments. Do not evaluate code quality or suggest changes — other skills handle that.
