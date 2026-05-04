# Enrich Context

When compiling output for others (Slack messages, PR comments, summaries), enrich entities mentioned in the user's input with real links and references fetched via MCP tools. The goal: make output self-contained so readers can reach the relevant resources without asking follow-up questions.

## Rules

- **Only enrich entities the user actually mentioned.** Do not go looking for extra things to link.
- **Verify before linking.** Use MCP tools to confirm the entity exists and fetch its real URL — do not guess or construct URLs from memory.
- **Stay within scope.** Enrich with links and details, not opinions or analysis.

## Entity Enrichment Table

### GitHub

| Entity | MCP tool | Link format |
|--------|----------|-------------|
| PR | `github__pull_request_read` (method: `get`) | Plain URL (auto-unfurls in Slack/GitHub). |
| Issue | `github__issue_read` | Issue URL from response. |
| Commit | `github__get_commit` | Commit URL from response. |
| Code file/line | `github__get_file_contents` to verify file and line exist | `https://github.com/<owner>/<repo>/blob/<sha>/<path>#L<line>-L<end_line>` |
| Tag | `github__get_tag` | `https://github.com/<owner>/<repo>/releases/tag/<tag_name>` |
| Release | `github__get_latest_release` or `github__get_release_by_tag` | Release URL from response. |
| Repository | `github__search_repositories` | Repository URL from response. |

### GitLab

| Entity | MCP tool | Link format |
|--------|----------|-------------|
| MR | `gitlab__get_merge_request` | Plain URL (auto-unfurls in Slack/GitLab). |
| Issue | `gitlab__get_issue` | Issue URL from response. |
| Commit | `gitlab__get_commit` | Commit URL from response. |
| Code file/line | `gitlab__get_file_contents` to verify file and line exist | `https://gitlab.com/<project_path>/-/blob/<sha>/<path>#L<line>-<end_line>` |
| Pipeline | `gitlab__get_pipeline` | Pipeline URL from response. |
| Pipeline job | `gitlab__get_pipeline_job` | Job URL from response. Use `gitlab__get_pipeline_job_output` for logs. |
| Release | `gitlab__list_releases` | Release URL from response. |
| Project | `gitlab__get_project` | Project URL from response. |

### Spacelift

| Entity | MCP tool | Link format |
|--------|----------|-------------|
| Stack | `spacelift-laravel__list_stacks` | Stack page URL from response. |
| Run | `spacelift-laravel__get_stack_run` or `spacelift-laravel__list_stack_runs` | `<run_url\|stack-name run #N>` for Slack, `[stack-name run #N](url)` for markdown. |
| Run changes | `spacelift-laravel__get_stack_run_changes` | Summarize resource changes (+/~/−) inline. Link to the run. |
| Run logs | `spacelift-laravel__get_stack_run_logs` | Quote relevant log lines. Link to the run. |
| Module | `spacelift-laravel__get_module` or `spacelift-laravel__get_module_version` | Module URL from response. |
| Policy | `spacelift-laravel__get_policy` | Policy URL from response. |
| Blueprint | `spacelift-laravel__get_blueprint` | Blueprint URL from response. |
| Context | `spacelift-laravel__get_context` | Context URL from response. |

### Linear

| Entity | MCP tool | Link format |
|--------|----------|-------------|
| Issue | `linear_*__get_issue` | Issue URL from response. |
| Project | `linear_*__get_project` | Project URL from response. |
| Document | `linear_*__get_document` | Document URL from response. |
| Milestone | `linear_*__get_milestone` | Milestone URL from response. |
| Initiative | `linear_*__get_initiative` | Initiative URL from response. |
| Team | `linear_*__get_team` | Team URL from response. |

### Grafana

| Entity | MCP tool | Link format |
|--------|----------|-------------|
| Dashboard | `grafana-laravel__search_dashboards` to find, `grafana-laravel__get_dashboard_by_uid` for details | `grafana-laravel__generate_deeplink` to build URL with time range and variables. |
| Alert | `grafana-laravel__list_alert_groups` or `grafana-laravel__get_alert_group` | Alert URL from response. |
| Datasource | `grafana-laravel__get_datasource` | Datasource name and type for reference (no public URL). |

## Code Permalinks

When referencing specific lines of code, always build a permalink to the exact SHA — not to a branch (which moves). Steps:

1. Use `github__get_file_contents` or `gitlab__get_file_contents` to verify the file exists and read the content around the target lines.
2. Get the current commit SHA from the PR/MR head or from `git log`.
3. Build the permalink using the SHA, not the branch name.

## Appendix Pattern

When output has additional details that help but would clutter the main message, add an appendix:

- Lists of affected stacks or resources.
- Full error messages or log snippets.
- Detailed code paths or file references.
- Commit SHAs, config snippets, resource counts.

The appendix goes at the end under a clear heading (`## Appendix` for Slack/markdown). Skip it if the message is already self-contained.
