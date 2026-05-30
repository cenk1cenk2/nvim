# Sourcebot Repository Discovery

Use Sourcebot when available for fast organization-wide repository and code discovery before provider-specific SCM calls.

## When to Start with Sourcebot

- Unknown target repository or multiple possible repositories.
- Organization-wide investigations, migrations, inventories, or "where is X used?" questions.
- Need a first-pass repo shortlist before GitLab/GitHub tool calls.
- Need examples of config keys, API fields, chart values, symbols, dependencies, or prior art across indexed code.

## Tool Flow

1. **Find candidates.**
   - Use `sourcebot-kilic__list_repos` for repository inventory and name filtering.
   - Use `sourcebot-kilic__grep` for text, config keys, endpoint names, package names, and migrations.
   - Use `sourcebot-kilic__glob` for file patterns such as `**/.gitlab-ci.yml`, `**/Chart.yaml`, or `**/package.json`.
2. **Inspect evidence.**
   - Use `sourcebot-kilic__read_file` and `sourcebot-kilic__list_tree` to inspect shortlisted repos and files.
   - Use `sourcebot-kilic__find_symbol_definitions` and `sourcebot-kilic__find_symbol_references` when the question is symbol/code-structure oriented.
   - Use `sourcebot-kilic__get_diff` and `sourcebot-kilic__list_commits` when historical context helps, but switch to SCM tools for authoritative MR/PR history.
3. **Escalate to SCM tools.**
   - Use GitLab/GitHub for authoritative metadata, permissions, live branch state, issues, MRs/PRs, pipelines, reviews, project settings, and writes.
   - Use local checkouts for implementation, test discovery, and final verification.

## Output Expectations

- Build a repo shortlist with concrete evidence: repo, path, symbol or matched pattern, and why it matters.
- Prefer several targeted Sourcebot searches over one massive provider inventory call.
- Do not treat Sourcebot as authoritative for live SCM state; verify live state with GitLab/GitHub or local git before acting.
- If `sourcebot-kilic` is unavailable, ignored by the active profile, or lacks the needed indexed repo, say so and fall back to the active workspace SCM tools.
