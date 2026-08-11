---
name: sourcebot-discovery
description: sourcebot-discovery Organization-wide repository and code discovery with Sourcebot - build an evidence-backed repo shortlist before provider-specific SCM calls, then escalate to GitLab or GitHub for live state. Load when the target repository is unknown or the search spans repositories. Not for authoritative SCM metadata, or for local git.
---

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

## `ask_codebase` Does Not Work

**`sourcebot-kilic__ask_codebase` is non-functional — never call it**, not even
when the question is broad and several targeted searches look inefficient. Answer
broad questions with the grep/glob/symbol flow above; it costs more calls and
returns evidence you can cite.

## Output Expectations

- Build a repo shortlist with concrete evidence: repo, path, symbol or matched pattern, and why it matters.
- Prefer several targeted Sourcebot searches over one massive provider inventory call.
- Do not treat Sourcebot as authoritative for live SCM state; verify live state with GitLab/GitHub or local git before acting.
- If `sourcebot-kilic` is unavailable, ignored by the active profile, or lacks the needed indexed repo, say so and fall back to the active workspace SCM tools.
