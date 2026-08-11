# GitLab MCP Tools Reference

## Core Rules

- For broad repository/code discovery across `gitlab.kilic.dev`, start with a code-discovery MCP when the active profile has one, then switch to `gitlab` MCP for authoritative metadata and operations. With none present, search from `gitlab` MCP directly and say so.
- Use raw `git` CLI commands for local git operations.
- Use `glab` CLI as fallback when MCP tools lack the needed capability (e.g., `glab ci trace` for job logs).
- Determine project path from the git remote URL.
- Determine the current branch from local git state via `git status`.

## Finding an Unknown GitLab Repository

When the target repository is unknown, broad, or one of several
candidates, the route depends on what the active profile carries:

1. **A code-discovery MCP is present** — build the shortlist there
   first: repo/namespace search, grouped content search across indexed
   repositories, then file-pattern search for structural clues such as
   `**/.gitlab-ci.yml`, `**/Chart.yaml`, `**/package.json`, `**/go.mod`,
   or `**/Cargo.toml`. Inspect the shortlisted files before escalating.
   When that MCP is Sourcebot, load `sourcebot-discovery` before the first call.
2. **None is present** — say so and search from `gitlab` MCP directly:
   `search_repositories` for name and namespace candidates, then
   `get_repository_tree` and `get_file_contents` to confirm the
   shortlist. Expect more calls for the same answer.

Either route ends the same way: convert the discovered repo name into a
GitLab project path (`group/project`, nested groups included) and verify
live state with `gitlab` MCP before touching branches, MRs, pipelines,
permissions, or writes.

## Available Tools by Category

### Repository Browsing

| Tool | Purpose |
|------|---------|
| `gitlab__get_file_contents` | Read a file from a repository at a specific ref. |
| `gitlab__get_repository_tree` | List files and directories in a repository path. |
| `gitlab__search_repositories` | Find projects by name or path. |
| `gitlab__list_projects` | List projects in a group or namespace. |
| `gitlab__list_group_projects` | List all projects within a group. |
| `gitlab__list_commits` | List commits on a branch or in a repository. |
| `gitlab__get_commit` | Get a specific commit. |
| `gitlab__get_commit_diff` | Get the diff for a specific commit. |
| `gitlab__get_branch_diffs` | Compare two branches. |

### Merge Requests

| Tool | Purpose |
|------|---------|
| `gitlab__list_merge_requests` | List MRs. Filter by `source_branch`, `state`, `target_branch`. |
| `gitlab__get_merge_request` | Read MR details (title, description, state, approvals). |
| `gitlab__get_merge_request_diffs` | Get the full MR diff. |
| `gitlab__get_merge_request_approval_state` | Check approval status. |
| `gitlab__mr_discussions` | List or create MR discussion threads (for review comments). |
| `gitlab__list_merge_request_versions` | List MR diff versions. |
| `gitlab__get_merge_request_version` | Get a specific MR diff version. |

### Issues

| Tool | Purpose |
|------|---------|
| `gitlab__list_issues` | List issues in a project. |
| `gitlab__get_issue` | Read issue details. |
| `gitlab__list_issue_discussions` | List discussions on an issue. |
| `gitlab__list_issue_links` | List linked issues. |
| `gitlab__my_issues` | List issues assigned to the current user. |

### CI/CD Pipelines

| Tool | Purpose |
|------|---------|
| `gitlab__list_pipelines` | List pipelines. Filter by `ref` (branch name) and `status`. |
| `gitlab__get_pipeline` | Get pipeline details. |
| `gitlab__list_pipeline_jobs` | List jobs in a pipeline. |
| `gitlab__get_pipeline_job` | Get a specific job's details. |
| `gitlab__get_pipeline_job_output` | Get job log output. |
| `gitlab__list_pipeline_trigger_jobs` | List trigger jobs (downstream pipelines). |

### Releases and Tags

| Tool | Purpose |
|------|---------|
| `gitlab__list_releases` | List releases. |
| `gitlab__get_release` | Get a specific release. |
| `gitlab__list_tags` | List tags for version discovery. |

### Project Metadata

| Tool | Purpose |
|------|---------|
| `gitlab__get_project` | Get project details (default branch, visibility, etc.). |
| `gitlab__get_project_events` | Get recent project activity. |
| `gitlab__list_project_members` | List project members. |
| `gitlab__list_labels` | List project labels. |
| `gitlab__get_label` | Get a specific label. |
| `gitlab__list_namespaces` | List available namespaces. |
| `gitlab__get_namespace` | Get namespace details. |
| `gitlab__verify_namespace` | Verify a namespace exists. |

### Local Git Operations

Raw `git` CLI commands via `Bash` (there is no git MCP server) — the command table lives in the `scm-detect` reference.

## CLI Fallback

When MCP tools lack the needed capability, use `glab` CLI via `Bash`:

- `glab ci trace <job-id>` — stream job logs (more complete than MCP output).
- `glab ci list` — list recent pipelines.
- `glab mr create` — create MR (when MCP creation is unavailable).
- `glab ci view` — view pipeline status interactively.

## Platform Detection

Extract project path from the git remote URL:

```
git@gitlab.example.com:<group>/<project>.git  →  project_path=<group>/<project>
https://gitlab.example.com/<group>/<project>  →  project_path=<group>/<project>
```

For nested groups: `git@gitlab.example.com:<group>/<subgroup>/<project>.git` → `project_path=<group>/<subgroup>/<project>`.
