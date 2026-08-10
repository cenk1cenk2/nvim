# GitLab MCP Tools Reference

## Core Rules

- Use Sourcebot first when available for broad repository/code discovery across `gitlab.kilic.dev`; switch to `gitlab` MCP for authoritative GitLab metadata and operations.
- Use raw `git` CLI commands for local git operations.
- Use `glab` CLI as fallback when MCP tools lack the needed capability (e.g., `glab ci trace` for job logs).
- Determine project path from the git remote URL.
- Determine the current branch from local git state via `git status`.

## Sourcebot-first GitLab Repository Discovery

When `sourcebot-kilic` is available and the GitLab repository is
unknown, broad, or one of several candidates:

1. Use `sourcebot-kilic__list_repos` with `query` to find name,
   namespace, or service candidates.
2. Use `sourcebot-kilic__grep` with `groupByRepo: true` for config
   keys, package names, service names, hostnames, routes, or other text
   clues across all indexed repositories.
3. Use `sourcebot-kilic__glob` for file patterns such as
   `**/.gitlab-ci.yml`, `**/Chart.yaml`, `**/package.json`,
   `**/go.mod`, or `**/Cargo.toml`.
4. Inspect shortlisted evidence with `sourcebot-kilic__read_file` or
   `sourcebot-kilic__list_tree`.
5. Convert Sourcebot repo names like `gitlab.kilic.dev/group/project`
   into GitLab project paths like `group/project`, then verify live
   state with GitLab MCP before using branches, MRs, pipelines,
   permissions, or writes.

Use `sourcebot-kilic__ask_codebase` only when the user explicitly asks
to use Sourcebot AI / `ask_codebase`. Treat its answer as a research
shortcut and verify actionable findings with targeted Sourcebot,
GitLab MCP, or local git before acting.

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
