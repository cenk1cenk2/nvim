# Linear SCM Discovery

Enrich Linear issues, projects, and agent project documents with repository facts, when the user explicitly asks for discovery, enrichment, repository analysis, implementation guidance, or agent-ready context. Which tools do the finding depends on the active profile — see the Discovery Ladder below.

## Trigger

Run this discovery only when the user explicitly asks for it, using phrases like:

- "Discover the repos."
- "Look at GitLab/GitHub first."
- "Enrich this with repository context."
- "Make this easier for agents to implement."
- "Figure out what repositories we need to touch."
- "Research how we should implement this from the codebase."
- "Inspect related MRs/PRs/issues before creating the Linear work."

Do not run broad SCM discovery by default for simple issue/project creation.

## Discovery Goals

Use the prompt to determine:

- What the user is trying to achieve.
- Which repositories are involved.
- Which files, modules, packages, charts, services, or infrastructure layers are likely touched.
- Existing implementations, patterns, or prior art.
- Related issues, MRs, PRs, branches, commits, project docs, or README guidance.
- Implementation approach and likely task boundaries.
- Verification commands and pipeline expectations when discoverable.
- Risks, unknowns, blockers, and decisions the user should answer early.

## Sources

Use the active workspace and SCM context:

- Linear MCP for project/issue history, docs, comments, relations, and labels.
- A code-discovery MCP, when the active profile has one, for fast organization-wide repository/code discovery, repo shortlists, file patterns, symbols, dependencies, and prior art.
- GitLab MCP for `gitlab.kilic.dev` repositories, MRs, pipelines, files, commits, and searches.
- GitHub MCP for GitHub repositories, PRs, checks, files, commits, and searches.
- Local repository checkout when available.
- `context7` or web search only for external library/framework behavior, not for repository-specific facts.

## Discovery Ladder

⛔ **Never assume a given discovery tool is present.** Availability is decided by the active profile, not by the task. Climb the ladder from whatever rung this session actually has.

1. **A code-discovery MCP, when the active profile has one.** The right first rung for an unknown, broad, or cross-repository target — it produces an evidence-backed repo shortlist in a few calls. When that MCP is Sourcebot, read its tool flow and repo-name conversion from `~/.config/nvim/utils/agents/skills/references/sourcebot-discovery.md` before the first call.
2. **The workspace SCM tools — GitLab or GitHub MCP.** Authoritative for live state: repositories, MRs/PRs, pipelines, issues, permissions, and every write. This rung always runs, even when rung 1 already found the answer — rung 1 is never authoritative for live SCM state.
3. **A local checkout**, when one exists, for implementation detail, tests, and final verification.

**Say which rung produced the answer, and announce a skipped one.** With no code-discovery MCP in the profile, start at the SCM tools and state that in one line — the same shortlist built from repeated SCM search costs more calls and misses more, and the user should know that is what happened.

## Output Placement

For one issue:

- Put issue-specific findings in the issue `## Analysis` or `## Notes`.
- Attach repository and MR/PR links with Linear `links`.
- Keep the checklist concrete and implementation-oriented.

For projects or repetitive agent work:

- Put shared discovery output in a project document with `save_document`.
- Keep issues light: repo/scope, specific checklist, exceptions, and "Read first" document reference.
- Use project documents for repository inventories, implementation guides, candidate matrices, shared verification, and agent instructions.

## Guardrails

- Never fabricate repo paths, API fields, endpoints, config keys, or implementation details.
- If the repository cannot be found or searched, say so and ask.
- Prefer explicit evidence: file paths, code references, MR/PR links, commit links, and docs.
- Ask early when discovery exposes competing approaches or incomplete requirements.
