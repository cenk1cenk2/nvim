---
name: config-references
description: 'config-references Create, update, or review reference files in the skills directory. Triggers: "create/add/update a reference", "extract this to a reference". Do NOT use for skills themselves (config-skills) or loading skills (load-skills).'
disableModelInvocation: true
references:
  - ../references/present-first.md
  - ../references/output-diff.md
  - ../references/redact-private-data.md
argumentHint: "[create|update|review] [reference-name] [description or context]"
---

## Reference Management

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `output-diff` reference for chunked change presentation — show reasoning + content blocks for each proposed reference change before writing.

> **No private specifics.** Read the `redact-private-data` reference — never write real private/sensitive specifics (customer names, account IDs, secrets, internal hostnames, real resource IDs) into references or their examples unless the user explicitly allows it; use placeholders instead.

## Reference Directory Structure

References live in two locations under `~/.config/nvim/utils/agents/skills/`:

- `references/` — shared references consumed by multiple skills.
- `<skill-name>/references/` — skill-specific references consumed only by that skill.

## Reference Format

Reference files are plain markdown. They do NOT have YAML frontmatter — only skills have frontmatter. Start with a `# Title` heading, then sections as needed.

**Structure:**

```
# <Reference Name>

<1-2 sentence description of what this reference covers and when to read it.>

## <Section>

<Content — conventions, rules, patterns, examples.>
```

## Process

### Create

1. Determine the scope — **shared** or **skill-specific**.
   - Shared: the content applies to 2+ skills or is a general convention.
   - Skill-specific: the content supports only one skill and would clutter its SKILL.md.
2. If shared, list files in `~/.config/nvim/utils/agents/skills/references/` to check for existing references and avoid duplication.
3. If skill-specific, read the parent skill at `~/.config/nvim/utils/agents/skills/<name>/SKILL.md` to understand context.
4. Name the file:
   - Shared: `<family>-<topic>.md` (e.g., `linear-prerequisite.md`, `scm-detect.md`).
   - Skill-specific: `<topic>.md` inside `<skill-name>/references/`.
5. Draft the reference content following the format above.
6. Identify which skills should declare this reference in their frontmatter.
7. Present the draft and the list of skills to update.
8. After approval, write the file and update skill frontmatter as needed.

### Update

1. Read the existing reference at `~/.config/nvim/utils/agents/skills/references/<name>.md`.
2. Read skills that declare it — search for the filename in skill frontmatter to understand consumers.
3. Identify what needs to change based on conversation context.
4. Present proposed changes using diff format.
5. After approval, apply changes.
6. If the update changes the reference's scope or contract, notify about affected skills.

### Review

1. List all files in `~/.config/nvim/utils/agents/skills/references/`.
2. For each reference (or a specific one if requested):
   - Read its content.
   - Check which skills declare it in their frontmatter.
   - Identify orphaned references (declared by no skill).
   - Identify stale content (conventions that no longer apply).
   - Check for duplication across references.
3. Present findings and propose improvements.

## Naming Conventions

| Type | Pattern | Examples |
|------|---------|----------|
| Family shared | `<family>-<topic>.md` | `linear-prerequisite.md`, `scm-github.md` |
| Cross-family shared | `<topic>.md` | `output-diff.md`, `plan-mode.md` |
| Per-harness | `harness-<provider>-<skill-or-reference-name>.md` | `harness-claude-agents-delegate.md`, `harness-codex-agent-background.md` |
| Skill-specific | `<topic>.md` in `<skill>/references/` | `./references/template.md` |

## Per-Harness References

When a skill's *mechanics* differ by agent runtime while its *intent* does not, the runtime-specific half becomes one reference per runtime, named `harness-<provider>-<skill-or-reference-name>.md`. The trailing segment is the exact name of the consuming skill or shared reference, so the filename says what it configures.

```
harness-claude-agents-delegate.md      # dispatch mechanics for the agents-delegate reference, on Claude Code
harness-codex-agents-delegate.md       # same slot, different runtime
harness-claude-agent-background.md     # waiting/waking mechanics for the agent-background skill
```

**Two shapes, do not confuse them:**

- `harness-<provider>-<consumer>.md` — mechanics of one runtime for one consuming skill (`harness-claude-agent-background`). Per (runtime × consumer).
- `harness-<topic>.md` — a cross-harness policy plus a per-harness inventory (`harness-connectors`). One file, all runtimes, because the rule is the same everywhere and only the inventory differs.

Rules:

- **Split by consumer, not by provider alone.** One file per (runtime × consumer) keeps a skill loading only the mechanics it needs. Do not accumulate every runtime detail into a single file per provider.
- **The consuming skill declares every provider's file** in `references:` and reads only the active one. Directives name the family — `harness-<provider>-agent-background` — never a single runtime's file.
- **Content is concrete on purpose.** Tool names, parameter names, defaults, env vars, limits, and known traps belong here; this is the one place where naming a specific runtime's tool is correct.
- **Version-mark claims and flag what you could not confirm.** Runtime behavior changes between releases — an unmarked claim rots invisibly, and a guessed one is worse than an absent one. Write `⚠ Unverified` in place rather than asserting.
- **Do not create a provider's file until its behavior is known.** An empty harness file implies coverage that does not exist.

## MCP Tool Name Convention

**⛔ ABSOLUTE — the harness-provided integration outranks the standalone server.** Where the running harness supplies an integration for a service (on Claude Code, `mcp__claude_ai_<Connector>__*`), references must present it as the one that is used, with the standalone MCP server as the stated fallback — not the other way round. A reference that tabulates only the standalone server's tools reads as an instruction to use it; when a harness connector exists for that service, pair the table with the mapping and point at `harness-connectors`. See `slack.md` for the shape.

When references list MCP tool names in tables or inline, use the **`<server>__<tool>` short form** with **kebab-case server names**: `linear-kilic__get_issue`, `slack-kilic__slack_list_channels`, `argocd-kilic__list_applications`, `grafana-laravel__query_prometheus`, `spacelift-laravel__list_stacks`. Server keys use `-` only; `/` and `_` are not valid separators inside server keys. Do NOT bake in a transport prefix (`mcp__...`) — the runtime resolves the prefix at call time. Hyprpilot wires every MCP server directly (no aggregator hub), so the bare server name is the only thing that matters in references.

**Removed servers — do NOT reference these in new or updated content:**

- `git__*` tools — there is no `git` MCP. Reference raw `git` CLI (`git status`, `git diff`, `git log`, etc.) via `Bash` instead.
- `kubernetes__*` tools — the `kubernetes` MCP has been removed. Reference `kubectl` CLI via `Bash` if needed.

**Tmux MCP is read-only.** Only the read-only tools (`tmux__list-*`, `tmux__capture-pane`, `tmux__find-session`, `tmux__get-command-result`) are usable. References must NOT include `execute-command`, `create-window`, `split-pane`, `kill-*`, or `create-session` as a recommended action. For command execution, reference the built-in `Bash` tool.

## Key Principles

- References are **progressive disclosure** — keep them focused on one topic.
- A reference should be **self-contained** — readable without loading other references.
- **No frontmatter** — only skills have YAML frontmatter.
- **No workflow steps** — references contain conventions and patterns, not process instructions.
- After creating or updating a shared reference, always check if skills need their `references:` frontmatter updated.
