---
name: config-skills
description: 'config-skills Create, update, or review skills in the skills directory. Triggers: "create a skill", "update skill X", "add a new slash command", "improve this skill". Do NOT use for loading or chaining skills (load-skills).'
disableModelInvocation: true
references:
  - ../references/present-first.md
  - ../references/output-diff.md
  - ../references/redact-private-data.md
  - ../references/commit-push-scoped.md
argumentHint: "[create|update|review] [skill-name] [description of what the skill should do]"
---

## Skill Management

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `output-diff` reference for chunked change presentation — show reasoning + content blocks for each proposed skill change before writing.

> **No private specifics.** Read the `redact-private-data` reference — never write real private/sensitive specifics (customer names, account IDs, secrets, internal hostnames, real resource IDs) into skills, references, or examples unless the user explicitly allows it; use placeholders instead.

> **Commit and push.** Read the `commit-push-scoped` reference — after edits land, stage ONLY the skill and reference files this run touched, then commit as `<type>(agents): <subject>` and push to `rolling` via `git-commit` and `git-push`. Ask first by default; skip the ask when the request already blessed the push.

## ⛔ ABSOLUTE RULE — change the RELEVANT skills, not this one

**When you learn something that should change agent behaviour, discover and edit the skills that actually govern that behaviour. Do NOT write it into `config-skills`.** This file is *authoring guidance* — how to write, structure, and validate a skill. It is not where operational rules live, and nothing reads it at the moment the behaviour is needed.

A rule about dispatching subagents belongs in the dispatch skills and their per-provider references. A rule about waiting on external state belongs in the background/watcher skill. A rule about a rollout's sequencing belongs in that flow's own skill or repository note. Putting any of those here means the agent that needed it never sees it.

So, before editing:

1. **Find the skills that own the behaviour** — search `~/.config/nvim/utils/agents/skills/` for the ones whose process steps actually perform it. There is usually more than one (a family of skills plus a shared reference).
2. **Edit every one of them**, not just the first. A rule present in one sibling and absent in the others fails exactly when a different entry point is used.
3. **Put runtime-specific mechanics in the per-provider reference**, and the runtime-agnostic principle in the body (see *Provider-Specific Behavior*).
4. **Only touch `config-skills` when the lesson is genuinely about how skills are authored** — a new frontmatter field, a validation rule, a structural convention — or when the user explicitly asks for `config-skills` itself.

**This is absolute.** "I'll record it in config-skills so future authors know" is the failure mode: it documents the lesson where nobody acts on it and leaves the real skills wrong.

## Skills Directory

All skills live in `~/.config/nvim/utils/agents/skills/`. Each skill is a directory containing a `SKILL.md` file. Shared reference files live in `references/` at the skills root.

```
~/.config/nvim/utils/agents/skills/
├── references/                          # Shared reference files (read on demand) — EXCERPT below, not the full list
│   ├── linear-prerequisite.md           # Workspace detection and auto-invoke rules
│   ├── linear-mandatory-fields.md       # Team, state, labels, estimate, priority, relations
│   ├── linear-issue-philosophy.md       # Issue vs. conversation authority and timestamps
│   ├── linear-description-structure.md  # Issue/project/initiative description format
│   ├── linear-project-documents.md      # Authoring project-scoped documents for shared Linear context
│   ├── linear-document-handling.md      # Reading/updating existing attached documents (glimpse, classify, edit-with-agreement)
│   ├── linear-pickup-execution.md       # Linear pickup implementation lifecycle
│   ├── harness-claude-agents-delegate.md   # per-harness: dispatch mechanics + tier→model
│   ├── harness-opencode-agents-delegate.md
│   ├── harness-codex-agents-delegate.md
│   ├── harness-claude-agent-background.md  # per-harness: waiting and waking mechanics
│   ├── harness-opencode-agent-background.md
│   ├── harness-codex-agent-background.md
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
2. **Read all declared references** — if the skill has a `references:` frontmatter field, read every path it lists. This ensures you understand the full context the skill operates in before making changes.
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

1. Run `mcp__hyprpilot_skills__reload` so Hyprpilot refreshes the skill catalog.
2. Verify the reload result reports the expected skill count or succeeds without errors.
3. For changed skills, re-read the affected skill with `mcp__hyprpilot_skills__read_skill` when practical to confirm the daemon sees the latest content.
4. If references changed, use `mcp__hyprpilot_skills__load_skill_references` for an affected skill when practical to confirm reference resolution.
5. Report the reload result to the user.

## Committing Changes

After the reload, hand off per the `commit-push-scoped` reference — stage only the files this run touched, then compose with `git-commit` (scope `agents`, e.g. `feat(agents): ...`) and `git-push` targeting `rolling`. Ask before committing unless the request already blessed the push.

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
disableModelInvocation: true # Manual-only. Omit for model-invocable/auto-invoke. See Invocation Tiers.
argumentHint: "[args]" # Shown to user as usage hint.
references: # YAML array of relative paths to reference files.
  - ../references/file.md
  - ./references/local.md
```

Hyprpilot keeps the **whole frontmatter block verbatim** and hands it to the agent — as `metadata` in `list_skills` / `read_skill` output, and as the `io.hyprpilot/skill` key in resource `_meta`. Only `title` and `description` are stripped from that block, because they already ride as the spec `Resource.title` / `Resource.description` fields.

What hyprpilot itself *acts on* is small:

| Key | What hyprpilot does with it |
|-----|------------------------------|
| `description` | Becomes `Resource.description`. Falls back to `Guidance for <slug>` when absent — always write one anyway. |
| `title` | Becomes `Resource.title`. Optional; the slug stands in when absent. |
| `references` | Resolved relative to the skill's own `bundleDir` and bundled by `load_skill_references`. |
| `name` | Passed through only — the **directory name is the slug**. A mismatch changes nothing at runtime, so keep them equal for the reader. |

Everything else — `disableModelInvocation`, `argumentHint`, and any key you invent — is **passed through untouched**. Hyprpilot enforces none of it; those are conventions the agent reads out of the metadata block, and the central `AGENTS.md` is what turns `disableModelInvocation` into an actual invocation rule. A stray Claude Code key (`when_to_use`, `allowed-tools`, `model`, `hooks`, …) therefore does not error — it just reaches the agent as noise. Do not add them.

**Body structure:** the body starts directly with the plan-mode directive and top-level `##` sections — there is **no `## system` wrapper**.

```markdown
> **Plan-mode posture** (choose one per skill)
>
> - **Strict** — declare `plan-mode.md` and open with the strict directive. ONLY for skills that plan/analyze and write nothing (e.g. `plan-hard`, `plan-revise`).
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

How a skill *should* be invoked is declared by `disableModelInvocation`. Hyprpilot does not enforce it — it passes the key through in the metadata block, and the agent honors it per the central `AGENTS.md`. Choose the tier deliberately when authoring: a wrong value is a real behavior change even though nothing validates it.

| Tier | Frontmatter | Behavior | Description should |
|------|-------------|----------|--------------------|
| **Manual** | `disableModelInvocation: true` | Fires only on explicit `/name` or a direct user request; the model never self-invokes it. | Lead with the action; triggers are the phrases a user types. |
| **Model-invocable** | omit (default `false`) | The model MAY invoke it when the user's intent clearly matches, as a step within a flow. | Lead with the action + "Use when user says …". |
| **Auto-invoke** *(a Model-invocable sub-case)* | omit (default `false`) | Same runtime state as Model-invocable, but meant to fire the moment its context is detected without the user naming it. No separate flag — the intent is carried by the description wording. | Start with "Auto-invoked when … detected (e.g. …)". |

Assignment guidance:

- **Manual** — reviews, reads, fixes, CI, scaffolding, config-authoring (`config-*`), personality modes, plan handoff/pickup, and any heavy or destructive orchestration the user should trigger deliberately (`git-split`, `code-improve`, `agents-*`).
- **Model-invocable** — routine actions the agent legitimately reaches for mid-task: git basics (`git-commit`, `git-branch`, `git-push`), PR/MR creation, most Linear operations, `plan-hard`.
- **Auto-invoke** — workspace/session initializers only (`linear-kilic`, `linear-laravel`, `slack-kilic`, `slack-laravel`, `spacelift-laravel`, `notion-laravel`).
- **Proactive-suggest overlay** — a Manual skill whose body tells the assistant to *recommend* itself on a trigger (rule drift, user deviations) but never self-invoke (`config-agents`, `obsidian-repository`). `config-repository` is the one skill kept Model-invocable with an explicit `disableModelInvocation: false` because autopilot may auto-apply it.

Note: omitting the flag and writing `disableModelInvocation: false` are behaviorally identical (default is `false`). Write it explicitly only when the autoload intent is the skill's defining feature and you want it legible in source (e.g. `config-repository`).

## References

References implement progressive disclosure — SKILL.md stays lean with the core workflow, while detailed shared conventions live in separate files read on demand.

### How References Work

1. Skills declare references in frontmatter as a YAML array of relative paths.
2. References are NOT loaded into context automatically — the SKILL.md body tells the model which references to read and when, using reference directives (blockquotes).
3. The model reads reference files on demand via the built-in `Read` tool (filesystem path).
4. Skills must work even if references fail to load (graceful degradation).

When authoring a skill, **do not bake the loading mechanism into the SKILL.md**. Reference directives should name the reference and what it covers, not the tool used to fetch it — the agent picks the right tool (filesystem `Read`, or `mcp__hyprpilot_skills__load_skill_references` for the bundled view).

### Path Convention

Paths are relative to the skill's own directory:

- `../references/<file>.md` — shared references (up to `skills/`, into `references/`).
- `./references/<file>.md` — skill-specific references (inside the skill's own directory).

The absolute base is `~/.config/nvim/utils/agents/skills/`. So `../references/<file>.md` resolves to `~/.config/nvim/utils/agents/skills/references/<file>.md`, and `./references/<file>.md` resolves to `~/.config/nvim/utils/agents/skills/<skill>/references/<file>.md`.

Hyprpilot's `mcp__hyprpilot_skills__load_skill_references { slug }` tool returns every reference a skill declares in one response (concatenated with `--- <basename> ---` delimiters) — useful when you want the daemon to walk the frontmatter for you instead of reading paths one at a time.

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

### Provider-Specific Behavior — generic body, per-harness reference

A skill is authored once and runs under whichever agent runtime is active. Keep that split explicit:

- **The SKILL.md body stays runtime-agnostic.** Describe the *intent* — "dispatch a subagent", "run it detached", "write the plan to the internal plans directory" — and never name one runtime's tool, parameter, default, or filesystem path.
- **Runtime mechanics live in a per-harness reference**, named **`harness-<provider>-<skill-or-reference-name>.md`** — one file per (runtime × consuming skill). That is where the concrete tool name, its parameters, its defaults, and the collection semantics belong. Cross-cutting paths stay in `provider-paths.md`.

**The per-harness naming convention.** A skill that behaves differently per runtime gets one reference per runtime, named after the runtime *and* the thing it configures:

```
references/harness-claude-agents-delegate.md      # dispatch mechanics + tier→model, Claude Code
references/harness-opencode-agents-delegate.md
references/harness-codex-agents-delegate.md
references/harness-claude-agent-background.md     # waiting/waking mechanics, Claude Code
references/harness-opencode-agent-background.md
references/harness-codex-agent-background.md
```

Rules for this family:

1. **`<skill-or-reference-name>` is the exact name of the consumer** — the skill (`agent-background`) or the shared reference (`agents-delegate`) whose mechanics the file carries. A reader seeing the filename knows what it configures without opening it.
2. **The skill declares every provider's file** in its `references:` frontmatter and reads only the active one at runtime. Never assume the session's runtime in the body.
3. **The directive names the family, not one file:** *"Read the active runtime's `harness-<provider>-agent-background` reference before arming anything."*
4. **Split by consumer, not by topic size.** Do not pile every runtime mechanic into one file per provider — a skill should load the mechanics it needs and nothing else.
5. **Add a new provider file only when its behavior is known.** An empty or guessed harness file is worse than none; mark anything unconfirmed as **unverified** in place.
6. **Version-mark behavioral claims.** Runtime behavior changes between releases; a claim without a version marker rots invisibly. When behavior contradicts a file, verify against the running build and fix the file rather than special-casing the runtime in a skill body.
- **A skill that spawns subagents MUST send the reader to the active provider's reference BEFORE the first dispatch**, as a hard directive rather than optional background. Write the directive so it cannot be read as "nice to have".

> **⛔ The expensive failure mode is result COLLECTION, not dispatch.** Whether detached is the default, and above all **how a finished agent's output actually reaches the caller**, vary per runtime and change between versions. One runtime wakes the caller with a completion notification; another never wakes it at all, so detached work finishes into silence. An author who omits the collection guidance produces a skill whose users either discard finished work and re-run it, or wait forever for a wake that was never coming. Any skill that dispatches subagents must therefore cover: how a finished agent's output reaches the caller on the active runtime, how to resume or poll it, and **diagnose the cause before re-dispatching** (blind re-dispatch is what throws work away, not re-dispatch itself).

Checklist for any skill that dispatches subagents:

1. The body names no runtime-specific tool, parameter, or default value.
2. A directive points at `harness-<provider>-agents-delegate` **before** the first dispatch step.
3. Blocking vs detached is expressed as intent; the provider reference owns the flag and its default.
4. Result collection is covered explicitly, including diagnose-before-re-dispatch.
5. If it isolates writes, it points at `agents-worktrees` — including that isolation follows the **session's** repo, not the task's, which breaks cross-repo dispatch.
6. Anything else that differs per runtime (plans directory, state directory, worktree location) points at `provider-paths` instead of hardcoding a path.

When a runtime's behavior turns out to contradict a generic skill body, fix it in that provider's reference — do not special-case the runtime inside the shared body.

### Checking for Deduplication

When creating or updating a skill, always check:

1. **Read existing references** — list files in `~/.config/nvim/utils/agents/skills/references/` and read their content.
2. **Compare against the skill** — identify any blocks in the skill that overlap with existing references.
3. **Check sibling skills** — read 2-3 skills in the same family and look for blocks duplicated across them.
4. **Propose extraction** — if a duplicated block has no matching reference, propose creating one. Name it `<family>-<topic>.md` (e.g., `linear-prerequisite.md`, `scm-detect.md`).
5. **Present findings** — show the user which blocks can be replaced with references and which new references should be created.

### Shared Reference Families

⛔ **This is a map, not an inventory.** The live list is the directory — run `ls ~/.config/nvim/utils/agents/skills/references/` before proposing a new reference or claiming one does not exist. A hand-maintained file list here rots the moment anyone adds a file.

| Family | Prefix | Covers |
|--------|--------|--------|
| Linear | `linear-*` | Prerequisite/workspace detection, mandatory fields, description structure, issue philosophy, states and transitions, pickup execution, documents, chunking, approval gates, SCM discovery, research. |
| SCM | `scm-*` | Platform detection, GitHub/GitLab tool sets, and the shared PR/MR workflows — review, fix-threads, read-summary, create-description, comment-poster, ci-fix. |
| Agents | `agents-*`, `agent-*` | Dispatch posture, worktrees, plan splitting, plan quality, project conventions, merge/review, completion handoff, watchers, target capability. |
| Per-harness | `harness-<provider>-<consumer>` | Runtime mechanics for one consuming skill. See Provider-Specific Behavior. |
| Cross-harness | `harness-<topic>` | One policy across all runtimes plus a per-runtime inventory (`harness-connectors`). |
| Git | `commit-*`, `release-convention` | Commit message style, trailers, release-automation detection. |
| Posture | `plan-mode`, `present-first`, `mode-toggle` | How a skill behaves before it writes; voice-mode on/off mechanics. |
| Authoring policy | `output-diff`, `redact-private-data`, `commit-push-scoped`, `review-findings` | How authored output is presented, redacted, and committed. |
| Service | `obsidian`, `slack*`, `sourcebot-discovery`, `enrich-context`, `excalidraw-*`, `spacelift-github`, `tmux` | Per-service tool sets and conventions. |
| Runtime paths | `provider-paths` | Plans / state / worktree directories per runtime. Never hardcode these in a body. |

Two carry a hard rule worth knowing without opening the file:

- `agents-delegate` points at the per-provider reference for dispatch mechanics — a skill that spawns subagents must send the reader there **before** the first dispatch.
- `agents-worktrees` covers the trap that isolation follows the **session's** repo, not the task's, which breaks cross-repo dispatch.

## Description Checklist

Run this checklist when creating, updating, or reviewing any skill description:

1. **Structure** — follows the format: `[What it does, key use case first] + [When to use it / trigger phrases] + [Negative triggers if needed]`.
2. **Trigger phrases** — includes phrases users would actually say (e.g., "create a skill", "set up a project").
3. **Negative triggers** — includes "Do NOT use for X" when the skill shares vocabulary with sibling skills (e.g., Linear family, cluster family).
4. **Specificity** — not too vague ("Helps with projects" is bad) and not too technical ("Implements the entity model" is bad).
5. **Plain text, key use case first** — brief plain-text prose only. No markdown headers and no YAML block scalars (`|`, `>`) in the description; structured what/when/do-not content belongs in the skill **body**, not the description. Put the primary use case first so it survives truncation.
6. **Length** — keep it short. Hyprpilot applies no cap and truncates nothing, so length is a budget problem, not a correctness one: `list_skills` returns **every** skill's description in one payload, so each description is paid for by the whole catalog. Lead with the primary use case and cut anything that is not a trigger.
7. **No XML tags** — no `<` or `>` characters in the description (security restriction).

## Conventions

- **Directory name** must match the `name` field in frontmatter, both in kebab-case.
- **Description** must follow the description checklist above.
- **Plan mode** — use it for skills that need research or multi-step planning. Skip it for interactive or quick-turnaround skills.
- **Invocation tier** — set `disableModelInvocation` deliberately per the Invocation Tiers section above: `true` for manual-only skills; omit it for model-invocable and auto-invoke skills.
- **MCP tools** — reference specific tool names (e.g., `github__*`) when the skill depends on them. Use the **`<server>__<tool>` short form** (e.g., `github__get_file_contents`, `git status`, `slack__slack_list_channels`) — see MCP Tool Name Convention below.
- **Describe the current state only** — no deprecation notes, no "formerly X", no "this used to be Y", no migration history. A skill is read at the moment of acting, and a past shape it names is a shape the agent can match by mistake. Delete the old wording and state the new one. The single exception is a `harness-*` reference version-marking *current* runtime behavior (`Since v2.1.186, …`) — that marks when a live claim was verified, not what it replaced.
- **Be concise** — skills are instructions for an agent, not documentation for humans. Keep it actionable.
- **End list items with `.`** — consistent punctuation across all skills.
- **Examples** — workflow skills that orchestrate multi-step processes should include at least one example showing trigger → actions → result.
- **Compose over duplicate** — when another skill or reference already does something, call or reference it (compose with the skill "as defined in `load-skills`", or add a `> Read the <name> reference` directive) rather than hardcoding a copy of its logic.
- **SKILL.md size** — no hard line limit. Some scaffolding skills (e.g. `cluster-*`, `argocd-*`) are legitimately long, and that is fine. Do NOT split a skill into references just to shrink it — references exist only to share content across skills (see References).

## MCP Tool Name Convention

**⛔ ABSOLUTE — the harness-provided integration outranks any server a skill names.** When the running harness supplies an integration for a service (on Claude Code, a `mcp__claude_ai_<Connector>__*` connector), it is used for that service and the standalone MCP server is not. A server name in a skill body identifies *which service and workspace*, never *which transport wins* — see the `harness-connectors` reference. When authoring: name the server for identification, and for any service with a harness connector, add a directive pointing at that reference rather than implying the standalone server is the default. Falling back to the standalone server is allowed only when the harness offers nothing for that service or lacks a needed capability, and it is stated out loud.

In skill files, reference files, and documentation, use the **`<server>__<tool>` short form** — the server name is the identifying factor. The harness/client may surface the tool under a longer prefix (`mcp__<server>__<tool>`, `mcp__<hub>__<server>__<tool>`, etc.); the agent resolves whatever prefix the runtime uses at call time. Documentation should NOT bake in a specific prefix.

**Server name rules** — server keys MUST use kebab-case with `-` separators only. Never use `/` in server keys (does not parse correctly through some MCP hubs) and avoid `_` for word separation inside the key. Workspace-suffixed servers follow the `<service>-<workspace>` pattern, e.g., `linear-kilic`, `linear-laravel`, `grafana-kilic`, `grafana-laravel`, `argocd-kilic`, `slack-kilic`, `spacelift-laravel`.

Examples:

- `github__get_file_contents` (server: `github`, tool: `get_file_contents`)
- `gitlab__get_merge_request` (server: `gitlab`, tool: `get_merge_request`)
- `sourcebot-kilic__grep` (server: `sourcebot-kilic`, tool: `grep`)
- `slack-kilic__slack_list_channels` (server: `slack-kilic`, tool: `slack_list_channels`)
- `linear-kilic__get_issue` (server: `linear-kilic`, tool: `get_issue`)
- `grafana-kilic__query_prometheus` (server: `grafana-kilic`, tool: `query_prometheus`)
- `obsidian__vault_read` (server: `obsidian`, tool: `vault_read`)

**There is no `git` MCP server.** For local git operations, reference raw `git` CLI commands (`git status`, `git diff`, `git log`, `git show`, `git commit`, etc.) called via `Bash`. Do NOT introduce a `git__*` tool reference into new or updated skills.

**The `tmux` MCP server is read-only.** Write tools (`execute-command`, `create-window`, `split-pane`, `kill-*`, `create-session`) are disabled. Skills that need to execute commands MUST use the built-in `Bash` tool — a step that says "run it in the scratch pane" is not merely stylistically wrong, it cannot execute. The remaining tools (`tmux__list-*`, `tmux__capture-pane`, `tmux__find-session`, `tmux__get-command-result`) are still available for inspecting existing user panes.

When a skill inspects panes, write its steps against those `tmux__*` tools rather than `tmux` CLI calls shelled through `Bash`, and declare `../references/tmux.md` — it owns the session naming map and the capture-size guard, so no skill should restate either.

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
