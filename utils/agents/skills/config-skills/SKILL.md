---
name: config-skills
description: Create, update, or review skills in the skills directory. Use when user says "create a skill", "update skill X", "review my skills", "add a new slash command", or "improve this skill". Do NOT use for loading or chaining skills (use /load-skills).
disable-model-invocation: true
references:
  - ../references/present-first.md
  - ../references/output-diff.md
argument-hint: "[create|update|review] [skill-name] [description of what the skill should do]"
---

## Skill Management

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `output-diff` reference for chunked change presentation — show reasoning + content blocks for each proposed skill change before writing.

## Skills Directory

All skills live in `~/.config/nvim/utils/agents/skills/`. Each skill is a directory containing a `SKILL.md` file. Shared reference files live in `references/` at the skills root.

```
~/.config/nvim/utils/agents/skills/
├── references/                          # Shared reference files (read on demand)
│   ├── linear-prerequisite.md           # Workspace detection and auto-invoke rules
│   ├── linear-mandatory-fields.md       # Team, state, labels, estimate, priority, relations
│   ├── linear-issue-philosophy.md       # Issue vs. conversation authority and timestamps
│   ├── linear-description-structure.md  # Issue/project/initiative description format
│   ├── linear-project-documents.md      # Authoring project-scoped documents for shared Linear context
│   ├── linear-document-handling.md      # Reading/updating existing attached documents (glimpse, classify, edit-with-agreement)
│   ├── linear-pickup-execution.md       # Linear pickup implementation lifecycle
│   ├── agents-tiers-claude.md           # Claude tier→model table + Agent tool dispatch
│   ├── agents-tiers-opencode.md         # OpenCode tier→model table + task tool dispatch
│   ├── agents-tiers-codex.md            # Codex/OpenAI role models + dispatch
│   ├── linear-scm-discovery.md          # Explicit opt-in Sourcebot/GitHub/GitLab discovery for Linear context
│   ├── linear-research-documentation.md # Research process, analysis, appendix, links
│   ├── sourcebot-discovery.md          # Sourcebot-first org-wide repository/code discovery
│   ├── plan-mode.md                     # Strict plan-mode directive (planning only, no writes)
│   ├── present-first.md                 # Present-first directive (writes after approval/blessing)
│   ├── obsidian.md                      # Vault conventions, tool access, writing style
│   └── slack.md                         # Slack tools, response conventions, reaction rules
├── skill-name/
│   ├── SKILL.md
│   └── references/                      # Skill-specific references (optional)
├── another-skill/
│   └── SKILL.md
```

## Skill Ecosystem

Skills in this directory form an interconnected system. A skill may depend on or compose with other skills in the same folder. When creating or updating a skill, read related skills to understand how they connect. Document any dependencies or composition in the process steps of the skill itself.

## Process

### Create

1. Determine what the skill should do. Ask the user if not clear from context.
2. Read 2-3 existing skills in the same family to understand patterns, tone, and structure. For each, read `~/.config/nvim/utils/agents/skills/<name>/SKILL.md` directly — issue reads in parallel.
3. **Check references** — read shared references at `~/.config/nvim/utils/agents/skills/references/<name>.md`. If the skill belongs to a family (e.g., Linear, Obsidian), check whether sibling skills declare references in their frontmatter and reuse the same ones.
4. Draft the full `SKILL.md`. Use reference directives for any shared conventions found in step 3. Add matching `references:` frontmatter field.
5. **Validate** — run the description checklist (see below) and verify conventions before presenting.
6. Present the draft in chat.
7. Iterate based on user feedback.
8. After approval, create the directory and write the file.
9. Reload the skill catalog using the reloading guidance below.

### Update

1. Read the existing `SKILL.md` for the target skill at `~/.config/nvim/utils/agents/skills/<target-skill>/SKILL.md`.
2. **Read all declared references** — if the skill has a `references:` frontmatter field, load all references via `reading the files listed in `references:``. This ensures you understand the full context the skill operates in before making changes.
3. Review the preceding conversation for key learnings, corrections, or deviations from the current skill content.
4. Identify what needs to change.
5. **Check for deduplication** — if the skill contains blocks that are duplicated in sibling skills (prerequisite blocks, plan mode directives, description structures, research patterns), check whether a shared reference already exists in `~/.config/nvim/utils/agents/skills/references/`. If it does, replace the duplicated block with a reference directive. If it doesn't and the block appears in 2+ skills, propose extracting it to a new shared reference.
6. **Validate** — run the description checklist (see below) against the updated description.
7. Present proposed changes to the user.
8. Iterate based on feedback.
9. After approval, apply the changes.
10. Reload the skill catalog using the reloading guidance below.

### Review

1. Read the existing `SKILL.md` for the target skill.
2. **Validate** — run the description checklist (see below) and check all conventions.
3. **Audit references** — check whether the skill duplicates content that exists in shared references. List any blocks that could be replaced with reference directives. Check whether the skill's declared references in frontmatter are still accurate (no stale paths, no missing references).
4. List ambiguities, inconsistencies, or areas that could be improved.
5. Ask clarifying questions to understand user intent.
6. Propose specific improvements based on answers.
7. After approval, apply the changes (or leave as-is if no changes needed).
8. If files changed, reload the skill catalog using the reloading guidance below.

## Reloading Skills

After creating, updating, deleting, or moving skill files:

1. Run `mcp__hyprpilot__reload` so Hyprpilot refreshes the skill catalog.
2. Verify the reload result reports the expected skill count or succeeds without errors.
3. For changed skills, re-read the affected skill with `mcp__hyprpilot__read_skill` when practical to confirm the daemon sees the latest content.
4. If references changed, use `mcp__hyprpilot__load_skill_references` for an affected skill when practical to confirm reference resolution.
5. Report the reload result to the user.

## SKILL.md Format

Every `SKILL.md` starts with YAML frontmatter followed by markdown instructions.

**Required frontmatter fields:**

```yaml
---
name: skill-name # kebab-case, matches directory name
description: What it does, key use case first. Use when user says "trigger phrase", "another phrase". Do NOT use for X (use /other-skill).
---
```

**Optional frontmatter fields:**

```yaml
disable-model-invocation: true # Manual-only. Omit for model-invocable/auto-invoke. See Invocation Tiers.
argument-hint: "[args]" # Shown to user as usage hint.
references: # YAML array of relative paths to reference files.
  - ../references/file.md
  - ./references/local.md
```

Hyprpilot honors only `name` and `description` (required), plus `disable-model-invocation`, `argument-hint`, and `references` (optional). It still parses a legacy `interaction` key but does nothing with it — **omit it**; existing skills are being cleaned of it. Every other Claude Code frontmatter key (`when_to_use`, `user-invocable`, `paths`, `model`, `effort`, `allowed-tools`, `context`, `agent`, `hooks`, `shell`) is **silently dropped** — parses without error but never surfaces or takes effect. Do not add them; they are dead weight that misleads readers.

**Body structure:** the body starts directly with the plan-mode directive and top-level `##` sections — there is **no `## system` wrapper** (a retired convention; skills that still carry it are being cleaned up).

```markdown
> **Plan-mode posture** (choose one per skill)
>
> - **Strict** — declare `plan-mode.md` and open with the strict directive. ONLY for skills that plan/analyze and write nothing (e.g. `plan-hard`, `code-improve`).
> - **Present-first** — declare `present-first.md` and open with the present-first directive. For every skill that writes anything (code, files, Linear/PR resources); it drafts, presents, and proceeds on approval or upfront blessing.

> **Reference directives** (when the skill uses shared conventions)
>
> Read the `<reference-name>` reference for <topic>.

## Context (optional)

Background information the agent needs to do its job.

## Process

Numbered steps describing the workflow.

## Format / Conventions (optional)

Templates, patterns, or formatting rules.

## Examples (optional, recommended for workflow skills)

Concrete use case examples showing trigger → actions → result.

## Key Principles (optional)

Guiding rules for the skill's behavior.
```

## Invocation Tiers

How a skill can be invoked is set by `disable-model-invocation` — the only invocation lever hyprpilot honors. Choose the tier deliberately when authoring.

| Tier | Frontmatter | Behavior | Description should |
|------|-------------|----------|--------------------|
| **Manual** | `disable-model-invocation: true` | Fires only on explicit `/name` or a direct user request; the model never self-invokes it. | Lead with the action; triggers are the phrases a user types. |
| **Model-invocable** | omit (default `false`) | The model MAY invoke it when the user's intent clearly matches, as a step within a flow. | Lead with the action + "Use when user says …". |
| **Auto-invoke** *(a Model-invocable sub-case)* | omit (default `false`) | Same runtime state as Model-invocable, but meant to fire the moment its context is detected without the user naming it. No separate flag — the intent is carried by the description wording. | Start with "Auto-invoked when … detected (e.g. …)". |

Assignment guidance:

- **Manual** — reviews, reads, fixes, CI, scaffolding, config-authoring (`config-*`), personality modes, plan handoff/pickup, and any heavy or destructive orchestration the user should trigger deliberately (`git-split`, `code-improve`, `agents-*`).
- **Model-invocable** — routine actions the agent legitimately reaches for mid-task: git basics (`git-commit`, `git-branch`, `git-push`), PR/MR creation, most Linear operations, `plan-hard`.
- **Auto-invoke** — workspace/session initializers only (`linear-kilic`, `linear-laravel`, `slack-kilic`, `slack-laravel`, `spacelift-laravel`, `notion-laravel`).
- **Proactive-suggest overlay** — a Manual skill whose body tells the assistant to *recommend* itself on a trigger (rule drift, user deviations) but never self-invoke (`config-agents`, `obsidian-repository`). `config-repository` is the one skill kept Model-invocable with an explicit `disable-model-invocation: false` because autopilot may auto-apply it.

Note: omitting the flag and writing `disable-model-invocation: false` are behaviorally identical (default is `false`). Write it explicitly only when the autoload intent is the skill's defining feature and you want it legible in source (e.g. `config-repository`).

## References

References implement progressive disclosure — SKILL.md stays lean with the core workflow, while detailed shared conventions live in separate files read on demand.

### How References Work

1. Skills declare references in frontmatter as a YAML array of relative paths.
2. References are NOT loaded into context automatically — the SKILL.md body tells the model which references to read and when, using reference directives (blockquotes).
3. The model reads reference files on demand via the built-in `Read` tool (filesystem path).
4. Skills must work even if references fail to load (graceful degradation).

When authoring a skill, **do not bake the loading mechanism into the SKILL.md**. Reference directives should name the reference and what it covers, not the tool used to fetch it — the agent picks the right tool (filesystem `Read`, or `mcp__hyprpilot__load_skill_references` for the bundled view).

### Path Convention

Paths are relative to the skill's own directory:

- `../references/<file>.md` — shared references (up to `skills/`, into `references/`).
- `./references/<file>.md` — skill-specific references (inside the skill's own directory).

The absolute base is `~/.config/nvim/utils/agents/skills/`. So `../references/<file>.md` resolves to `~/.config/nvim/utils/agents/skills/references/<file>.md`, and `./references/<file>.md` resolves to `~/.config/nvim/utils/agents/skills/<skill>/references/<file>.md`.

Hyprpilot's `mcp__hyprpilot__load_skill_references { slug }` tool returns every reference a skill declares in one response (concatenated with `--- <basename> ---` delimiters) — useful when you want the daemon to walk the frontmatter for you instead of reading paths one at a time.

### Reference Directives in SKILL.md

Use blockquotes to instruct the model to read a reference:

```markdown
> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules.
> A Linear workspace skill MUST be active before this skill runs.
```

**Plan-mode posture directive** (one per skill, matching the reference it declares):

```markdown
> **ALWAYS enter plan mode.** Read the `plan-mode` reference for full directives — planning only, no writes.

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.
```

The directive should:
- Name the reference clearly (matching the filename without extension).
- State what the reference covers so the model knows why to read it.
- Include a brief inline summary so the skill still works if the reference fails to load.

### When to Create a New Shared Reference

**References exist to share the same content across multiple skills — not to shrink a single skill.** If a block lives in only one skill, keep it inline no matter how long.

Extract content to a shared reference when:

- The same block appears in **2 or more skills** (verbatim or near-verbatim).
- The block is **longer than 5 lines** — short duplications (1-2 lines) are not worth the indirection.
- The block represents a **convention or policy** (not skill-specific logic).

Do NOT extract:
- Skill-specific workflow steps — these belong in SKILL.md.
- Descriptions or examples — these are unique per skill.
- Short inline rules that would lose context when separated.

### Checking for Deduplication

When creating or updating a skill, always check:

1. **Read existing references** — list files in `~/.config/nvim/utils/agents/skills/references/` and read their content.
2. **Compare against the skill** — identify any blocks in the skill that overlap with existing references.
3. **Check sibling skills** — read 2-3 skills in the same family and look for blocks duplicated across them.
4. **Propose extraction** — if a duplicated block has no matching reference, propose creating one. Name it `<family>-<topic>.md` (e.g., `linear-prerequisite.md`, `cluster-naming.md`).
5. **Present findings** — show the user which blocks can be replaced with references and which new references should be created.

### Available Shared References

| File | Covers | Used by |
|------|--------|---------|
| `linear-prerequisite.md` | Workspace detection, auto-invoke rules. | Linear family (14 skills). |
| `linear-mandatory-fields.md` | Team, state, labels, estimate, priority, relations. | Issue/project creation skills. |
| `linear-issue-philosophy.md` | Issue vs. conversation authority, timestamps. | Issue update/revisit/pick skills. |
| `linear-description-structure.md` | Issue/project/initiative description format. | Issue/project/initiative creation skills. |
| `linear-project-documents.md` | Project-scoped documents for shared Linear context, repetitive agent instructions, and lightweight issue references. | Linear project creation and agent project skills. |
| `linear-pickup-execution.md` | Linear project/issue pickup lifecycle, agent/direct scheduling, state updates, PR/MR, pipelines, review fixes, and final reporting. | Linear pickup and agent orchestration skills. |
| `linear-scm-discovery.md` | Explicit opt-in Sourcebot-first discovery for repository inventory, implementation guidance, prior art, and agent-ready Linear context before GitHub/GitLab metadata calls. | Linear creation, project agent, and pickup skills. |
| `linear-research-documentation.md` | Research process, analysis, appendix, link management. | Research-heavy creation skills. |
| `sourcebot-discovery.md` | Sourcebot-first organization-wide repository/code discovery before GitLab/GitHub metadata calls. | Agent planning/delegation and Linear discovery workflows. |
| `linear-issue-states.md` | State meanings, transition rules, dependency resolution, decision patterns. | State-transition skills (implement, triage, next-task, cycle). |
| `linear-state-transitions.md` | Auto-advance triggers (pickup → In Progress, MR/PR open → In Review, merge → Done), never-downgrade guard, id extraction, silent-with-report contract. | Agent-dispatch skills (agents-delegate, agents), PR/MR-create skills (gitlab-mr-create, github-pr-create), linear-issue-comment. |
| `scm-detect.md` | SCM platform detection from remote URL, local git MCP tools, CLI fallback. | Cross-platform skills (code-pull, code-review-branch). |
| `scm-github.md` | GitHub MCP tools, `gh` CLI fallback, platform-specific conventions. | GitHub CI/PR/failed-CI skills, cross-platform skills. |
| `scm-gitlab.md` | GitLab MCP tools, `glab` CLI fallback, platform-specific conventions. | GitLab CI/PR/failed-CI skills, cross-platform skills. |
| `scm-comment-poster.md` | Shared draft-and-post-comment workflow for the current PR/MR. | `github-pr-comment`, `gitlab-mr-comment`. |
| `scm-review-workflow.md` | Shared PR/MR review workflow: previous-review detection, delta scope, thread resolution, analysis checklist, summary template, tone, principles. | `github-pr-review`, `gitlab-mr-review`. |
| `scm-fix-threads.md` | Shared review-thread fixing workflow: thread analysis categories, triage, apply, reply/resolve, report, principles. | `github-pr-fix`, `gitlab-mr-fix`. |
| `scm-read-summary.md` | Shared read-only PR/MR summary workflow: identify, read metadata/threads/diff, structured summary, principles. | `github-pr-read`, `gitlab-mr-read`. |
| `scm-create-description.md` | Shared PR/MR title+description workflow: branch reuse, drafting, format templates, writing style. | `github-pr-create`, `gitlab-mr-create`. |
| `scm-ci-fix.md` | Shared CI-failure diagnosis workflow: pickup notes, diagnose, propose, ask-to-implement, principles. | `github-ci-fix`, `gitlab-ci-fix`. |
| `plan-mode.md` | Strict plan-mode directive — planning/analysis only, implementation disabled, never exit. | Planning-only skills (`plan-hard`, `plan-revise`, `plan-handoff`, `code-improve`). |
| `present-first.md` | Present-first posture — draft, present before writing, proceed on approval or upfront blessing; no plan mode. | Every skill that writes (Linear / SCM / config / obsidian / scaffolding / code — ~80 skills). |
| `obsidian.md` | Vault location, tool access, file naming, frontmatter, writing style, vault exploration. | Obsidian family (4 skills). |
| `slack.md` | Slack MCP tools, response conventions, `:dark_sunglasses:` pattern, large results handling. | Slack family (2 skills). |
| `enrich-context.md` | Entity enrichment table (MCP tools → links), code permalinks, appendix pattern. | Skills that compile output for others (slack-laravel-compile, slack-channel). |
| `project-tooling.md` | Task runner discovery order, verification command extraction, user confirmation flow. | Agent skills (agents-plan, agents-delegate). |
| `agents-tiers-claude.md` | Claude tier→model table (`haiku`/`sonnet`/`opus`/`fable`) + `Agent` tool dispatch. | `agents-tiers` skill; agent delegation skills on demand. |
| `agents-tiers-opencode.md` | OpenCode tier→model table (`kilic/*` models) + `task` tool dispatch. | `agents-tiers` skill; agent delegation skills on demand. |
| `agents-tiers-codex.md` | Codex/OpenAI role models (`gpt-*`) + dispatch. | `agents-tiers` skill; agent delegation skills on demand. |
| `linear-document-handling.md` | Reading/updating existing attached documents: glimpse, classify plan-like vs external, edit only with agreement. | Linear read/update skills (issue-read, project-read, issue-update, project-update). |
| `agents-write-plans.md` | Plan quality: exact file paths, no placeholders, concrete steps, optional depends_on field, self-review checklist. | Agent skills (agents-plan). |
| `agents-conventions.md` | Project conventions discovery: testing, code style, patterns, formatting, commits. | Agent skills (agents-plan, agents-delegate). |
| `agents-completion.md` | Completion handoff: summarize, present options (commit/push/PR/leave), execute choice. | Agent skills (agents-plan, agents-delegate). |
| `agents-plan-split.md` | Planning phase: understand goal, tooling, conventions, plan, split tasks, declare depends_on, build layer schedule, verify file overlap. | Agent skills (agents-plan). |
| `agents-merge-review.md` | Per-layer merge + per-layer review, end-of-run review against run baseline, final verification with evidence, handoff. | Agent skills (agents-plan). |
| `output-diff.md` | Chunked change presentation — reasoning + content blocks before any write. | Config family (5 skills), Linear/Obsidian/Slack write skills. |

## Description Checklist

Run this checklist when creating, updating, or reviewing any skill description:

1. **Structure** — follows the format: `[What it does, key use case first] + [When to use it / trigger phrases] + [Negative triggers if needed]`.
2. **Trigger phrases** — includes phrases users would actually say (e.g., "create a skill", "set up a project").
3. **Negative triggers** — includes "Do NOT use for X" when the skill shares vocabulary with sibling skills (e.g., Linear family, cluster family).
4. **Specificity** — not too vague ("Helps with projects" is bad) and not too technical ("Implements the entity model" is bad).
5. **Plain text, key use case first** — brief plain-text prose only. No markdown headers and no YAML block scalars (`|`, `>`) in the description; structured what/when/do-not content belongs in the skill **body**, not the description. Put the primary use case first so it survives truncation.
6. **Length** — well under the 1,536-character cap (the runtime truncates the combined `description` text at 1,536 chars in the listing). Shorter is better: descriptions load into context **every turn** against a small budget, and overflow is trimmed — which can strip the trigger keywords the model needs to match.
7. **No XML tags** — no `<` or `>` characters in the description (security restriction).

## Conventions

- **Directory name** must match the `name` field in frontmatter, both in kebab-case.
- **Description** must follow the description checklist above.
- **Plan mode** — use it for skills that need research or multi-step planning. Skip it for interactive or quick-turnaround skills.
- **Invocation tier** — set `disable-model-invocation` deliberately per the Invocation Tiers section above: `true` for manual-only skills; omit it for model-invocable and auto-invoke skills.
- **MCP tools** — reference specific tool names (e.g., `github__*`) when the skill depends on them. Use the **`<server>__<tool>` short form** (e.g., `github__get_file_contents`, `git status`, `slack__slack_list_channels`) — see MCP Tool Name Convention below.
- **Be concise** — skills are instructions for an agent, not documentation for humans. Keep it actionable.
- **End list items with `.`** — consistent punctuation across all skills.
- **Examples** — workflow skills that orchestrate multi-step processes should include at least one example showing trigger → actions → result.
- **Compose over duplicate** — when another skill or reference already does something, call or reference it (compose with the skill "as defined in `load-skills`", or add a `> Read the <name> reference` directive) rather than hardcoding a copy of its logic.
- **SKILL.md size** — no hard line limit. Some scaffolding skills (e.g. `cluster-*`, `argocd-*`) are legitimately long, and that is fine. Do NOT split a skill into references just to shrink it — references exist only to share content across skills (see References).

## MCP Tool Name Convention

In skill files, reference files, and documentation, use the **`<server>__<tool>` short form** — the server name is the identifying factor. The harness/client may surface the tool under a longer prefix (`mcp__<server>__<tool>`, `mcp__<hub>__<server>__<tool>`, etc.); the agent resolves whatever prefix the runtime uses at call time. Documentation should NOT bake in a specific prefix.

**Server name rules** — server keys MUST use kebab-case with `-` separators only. Never use `/` in server keys (does not parse correctly through some MCP hubs) and avoid `_` for word separation inside the key. Workspace-suffixed servers follow the `<service>-<workspace>` pattern, e.g., `linear-kilic`, `linear-laravel`, `grafana-kilic`, `grafana-laravel`, `argocd-kilic`, `slack-kilic`, `spacelift-laravel`.

Examples:

- `github__get_file_contents` (server: `github`, tool: `get_file_contents`)
- `gitlab__get_merge_request` (server: `gitlab`, tool: `get_merge_request`)
- `sourcebot-kilic__grep` (server: `sourcebot-kilic`, tool: `grep`)
- `slack-kilic__slack_list_channels` (server: `slack-kilic`, tool: `slack_list_channels`)
- `linear-kilic__get_issue` (server: `linear-kilic`, tool: `get_issue`)
- `memory__add_observations` (server: `memory`, tool: `add_observations`)
- `obsidian__vault_read` (server: `obsidian`, tool: `vault_read`)

**There is no `git` MCP server.** For local git operations, reference raw `git` CLI commands (`git status`, `git diff`, `git log`, `git show`, `git commit`, etc.) called via `Bash`. Do NOT introduce a `git__*` tool reference into new or updated skills.

**The `tmux` MCP server is read-only.** Write tools (`execute-command`, `create-window`, `split-pane`, `kill-*`, `create-session`) are disabled. Skills that need to execute commands MUST use the built-in `Bash` tool. The remaining tmux tools (`tmux__list-*`, `tmux__capture-pane`, `tmux__find-session`, `tmux__get-command-result`) are still available for inspecting existing user panes.

## Examples

**User says:** "Create a skill for managing Obsidian daily notes"

1. Ask clarifying questions (what should the skill do, manual or auto-invoked).
2. Read 2-3 existing Obsidian skills for patterns.
3. Check `references/` for shared conventions the new skill should use.
4. Draft `SKILL.md` with frontmatter, process, and format sections.
5. Validate against description checklist.
6. Present draft in chat, iterate on feedback.
7. After approval, create `obsidian-daily/SKILL.md`.

**Result:** New skill directory and `SKILL.md` created.

---

**User says:** "Review the linear-issue-create skill"

1. Read `linear-issue-create/SKILL.md`.
2. Run description checklist — check trigger phrases, negative triggers, specificity.
3. Check conventions — plan mode, punctuation, conciseness.
4. Audit references — check if duplicated blocks exist that should use shared references.
5. Present findings: "Description missing negative triggers for /linear-issue-update".
6. Propose improvements, iterate.

**Result:** Skill updated with improved description and conventions.

---

**User says:** "Update the linear-project-create skill"

1. Read `linear-project-create/SKILL.md`.
2. Read shared references in `references/` to check for deduplication.
3. Identify prerequisite block, plan mode block, and research section as duplicates of existing references.
4. Propose replacing them with reference directives and adding `references` to frontmatter.
5. Present changes, iterate on feedback.
6. After approval, update the skill.

**Result:** Skill slimmed down with reference directives, frontmatter updated.
