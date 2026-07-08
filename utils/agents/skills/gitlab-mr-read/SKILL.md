---
name: gitlab-mr-read
description: Read and internalize the full state of a GitLab MR — description, comments, discussion threads, and diff. Use when user says "read this MR", "load the MR", "what's in this MR", or "summarize this MR". Purely informational — does not modify anything. Do NOT use for reviewing MRs (gitlab-mr-review), fixing MR threads (gitlab-mr-fix), or writing MR descriptions (gitlab-mr-create).
disable-model-invocation: true
argument-hint: "[MR number or URL]"
references:
  - ../references/present-first.md
  - ../references/scm-read-summary.md
  - ../references/scm-gitlab.md
  - ../references/scm-detect.md
---

## GitLab MR Read

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `scm-read-summary` reference for the full read/summarize workflow and key principles.
> Read the `scm-gitlab` reference for GitLab MCP tools and git MCP tools.
> Read the `scm-detect` reference for platform detection and local git operations.

## Platform specifics

- **Find the MR** (when not given): `git status` for the branch, extract the project path from the remote, then `gitlab__list_merge_requests` with `source_branch` filter and `state: opened`.
- **Read metadata:** `gitlab__get_merge_request` — title, description, author, state (opened/closed/merged), labels, assignees, reviewers, source/target branches, merge status, created/updated timestamps. Then `gitlab__get_merge_request_approval_state` — required vs current approvals, who has approved and who hasn't.
- **Read the diff:** `gitlab__get_merge_request_diffs`.
- **Read notes:** `gitlab__get_merge_request_notes` for general MR notes (non-discussion comments, system notes, etc.). Note bot or system notes (pipeline results, approvals, etc.).
- **Read discussion threads:** `gitlab__mr_discussions` for all discussion threads (inline and general) — file:line if positioned on the diff, resolved/unresolved status, full conversation, pending suggestions.
- **Read versions and commits:** `gitlab__list_merge_request_versions` for the diff version progression (count, timestamps); `gitlab__list_commits` for the MR branch.
- **Summary template:** header line `### MR !N: <title>`; add an `**Approvals:** <approval status summary>` row to the header block; use `#### Notes (<count>)` for the discussion section and `#### Discussion Threads` for the threads section; add a `#### Versions (<count>)` section listing diff versions with timestamps.
