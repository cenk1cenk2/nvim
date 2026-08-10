---
name: gitlab-mr-review
description: gitlab-mr-review Review a GitLab MR autonomously with inline annotations and a summary comment; on a rerun it reviews only the delta and resolves discussions that are now fixed. Use on "review the MR", "annotate the MR". Not for the MR description, for GitHub pull requests, or for a review that stays in chat.
disableModelInvocation: true
argumentHint: '[optional: MR number or URL]'
references:
  - ../references/scm-review-workflow.md
  - ../references/scm-gitlab.md
  - ../references/scm-detect.md
  - ../references/review-findings.md
---

## GitLab MR Review

Review workflow and tone per `scm-review-workflow`. GitLab tooling and local git per `scm-gitlab`; platform detection per `scm-detect`. Finding format and severity tags per `review-findings`.

This skill performs an autonomous code review on a GitLab merge request using native inline discussion threads. It does NOT draft findings for user approval — it reviews the code and posts annotations and a summary directly.

> **HARD RULE: All findings MUST be posted as inline diff-positioned discussions via `gitlab__mr_discussions` — NEVER as general MR notes without diff position.** The only non-positioned note this skill posts is the summary. Every finding with a file location goes through the discussion API with a diff position. No exceptions.

## Platform specifics

- **Review marker:** `<!-- mr-review-skill -->` — used to identify this skill's summary comments and enable consecutive-run detection.
- **Identify the MR:** if the user provides a GitLab MR URL or number, use it directly. Otherwise detect from the current branch: `git status` for the branch, extract the project path from the remote URL, then `gitlab__list_merge_requests` with `source_branch` filter and `state: opened`. If no open MR is found, inform the user and stop. Read MR metadata via `gitlab__get_merge_request`.
- **Detect previous reviews:** read existing MR notes via `gitlab__get_merge_request_notes` to find prior summary comments carrying the marker above.
- **Diff tool:** full MR diff via `gitlab__get_merge_request_diffs`. Use the same tool to fetch a reference MR's diff for cross-MR consistency checks.
- **Resolve previous threads:** read existing MR discussions via `gitlab__mr_discussions`; reply via `gitlab__mr_discussions`. When a thread is fixed, post the `Fixed in <short-sha>.` reply **and resolve the thread**.
- **Summary comment:** post a top-level note on the MR via `gitlab__mr_discussions` (without diff position — general comment).

### Post inline annotations

Create a discussion thread for each finding via `gitlab__mr_discussions` (diff-positioned draft-note/discussion annotations).

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

**Comment body format:** follow "Inline Comment Body" in the `review-findings` reference.

**Example comment body:**

````
**risk:** `user` can be null after `.find_by`. Add null guard.

```suggestion:-0+0
user = User.find_by(id: params[:id])
raise ActiveRecord::RecordNotFound, 'User not found' unless user
```
````
