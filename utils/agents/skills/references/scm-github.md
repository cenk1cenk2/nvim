# GitHub MCP Tools Reference

## Core Rules

- **ALWAYS use `github` MCP tools for all GitHub operations.**
- **ALWAYS use `git` MCP tools for local git operations.**
- Use `gh` CLI as fallback when MCP tools lack the needed capability (e.g., `gh run list`, `gh run view`).
- Determine repository owner and name from the git remote URL.
- Determine the current branch from local git state via `git status`.

## Available Tools by Category

### Repository Browsing

| Tool | Purpose |
|------|---------|
| `github__get_file_contents` | Read files and directories from a repository. |
| `github__search_code` | Search for code patterns across repositories. |
| `github__search_repositories` | Find repositories by name, topic, or description. |
| `github__list_branches` | List branches in a repository. |
| `github__list_commits` | List commits on a branch or in a repository. |
| `github__get_commit` | Get a specific commit with its diff. |

### Pull Requests

| Tool | Purpose |
|------|---------|
| `github__list_pull_requests` | List PRs. Filter by `head` (format: `owner:branch`), `state`, `base`. |
| `github__pull_request_read` | Read PR details. Use method `get` for metadata, `get_diff` for full diff. |
| `github__create_pull_request` | Create a new PR. |
| `github__update_pull_request` | Update PR title, body, or state. |
| `github__update_pull_request_branch` | Update PR branch (merge base into head). |
| `github__pull_request_review_write` | Submit a review with inline comments. |
| `github__add_reply_to_pull_request_comment` | Reply to an existing review comment. |

### Issues

| Tool | Purpose |
|------|---------|
| `github__list_issues` | List issues in a repository. |
| `github__issue_read` | Read issue details. |
| `github__issue_write` | Create or update an issue. |
| `github__search_issues` | Search issues across repositories. |
| `github__add_issue_comment` | Add a comment to an issue. |

### Releases and Tags

| Tool | Purpose |
|------|---------|
| `github__get_latest_release` | Get the latest release for version checking. |
| `github__get_release_by_tag` | Get a specific release by tag name. |
| `github__list_releases` | List all releases. |
| `github__list_tags` | List tags for version discovery. |
| `github__get_tag` | Get a specific tag. |

### Local Git Operations

| Tool | Purpose |
|------|---------|
| `git status` | Current branch, staged/unstaged changes. |
| `git branch` | List, create, or check branches. |
| `git diff` | Diff between refs (branches, commits). |
| `git diff --staged` | Staged changes only. |
| `git diff` | Unstaged changes only. |
| `git log` | Commit history. |
| `git show` | Show a specific commit. |
| `git add` | Stage files for commit. |
| `git commit` | Create a commit with staged changes. |
| `git reset` | Unstage files or reset to a ref. |
| `git checkout` | Switch branches or restore files. |
| `git branch` | Create a new branch from current HEAD or a ref. |

## CLI Fallback

When MCP tools lack the needed capability, use `gh` CLI via tmux or Bash:

- `gh run list --branch <branch>` — list workflow runs (no MCP equivalent).
- `gh run view <run-id>` — view run summary.
- `gh run view <run-id> --log-failed` — extract failed job logs.
- `gh pr create` — create PR (when MCP creation is unavailable).

## Platform Detection

Extract owner and repository name from the git remote URL:

```
git@github.com:<owner>/<repo>.git  →  owner=<owner>, repo=<repo>
https://github.com/<owner>/<repo>  →  owner=<owner>, repo=<repo>
```
