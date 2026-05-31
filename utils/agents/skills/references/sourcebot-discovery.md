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
   - Use `sourcebot-kilic__grep` for text, config keys, endpoint names, package names, and migrations. Use `groupByRepo: true` when searching across many repositories to build a repo shortlist before drilling in.
   - Use `sourcebot-kilic__glob` for file patterns such as `**/.gitlab-ci.yml`, `**/Chart.yaml`, or `**/package.json`.
2. **Inspect evidence.**
   - Use `sourcebot-kilic__read_file` and `sourcebot-kilic__list_tree` to inspect shortlisted repos and files.
   - Use `sourcebot-kilic__find_symbol_definitions` and `sourcebot-kilic__find_symbol_references` when the question is symbol/code-structure oriented.
   - Use `sourcebot-kilic__get_diff` and `sourcebot-kilic__list_commits` when historical context helps, but switch to SCM tools for authoritative MR/PR history.
3. **Escalate to SCM tools.**
   - Use GitLab/GitHub for authoritative metadata, permissions, live branch state, issues, MRs/PRs, pipelines, reviews, project settings, and writes.
   - Use local checkouts for implementation, test discovery, and final verification.

## GitLab Repository Discovery

For `gitlab.kilic.dev` work where the exact project path is unknown:

1. Search repo names and namespaces with `sourcebot-kilic__list_repos`.
2. Search likely code/config clues with `sourcebot-kilic__grep` and
   `groupByRepo: true` to rank candidate repositories.
3. Search structural clues with `sourcebot-kilic__glob`, such as
   `.gitlab-ci.yml`, Helm charts, package manifests, Terraform roots,
   or service-specific config files.
4. Convert Sourcebot repo names like `gitlab.kilic.dev/group/project`
   to GitLab MCP project paths like `group/project`.
5. Verify live GitLab state with GitLab MCP before creating branches,
   reading MRs/pipelines, or writing anything.

## AI-assisted Sourcebot Research

Use `sourcebot-kilic__ask_codebase` only when the user explicitly asks
to use Sourcebot AI / `ask_codebase`. It is useful for broad natural
language questions where several targeted searches would be inefficient.
Always verify actionable results with targeted Sourcebot calls,
GitLab/GitHub MCP, or local git before acting.

## Output Expectations

- Build a repo shortlist with concrete evidence: repo, path, symbol or matched pattern, and why it matters.
- Prefer several targeted Sourcebot searches over one massive provider inventory call.
- Do not treat Sourcebot as authoritative for live SCM state; verify live state with GitLab/GitHub or local git before acting.
- If `sourcebot-kilic` is unavailable, ignored by the active profile, or lacks the needed indexed repo, say so and fall back to the active workspace SCM tools.
