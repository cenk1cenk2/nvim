---
name: config-references
description: Create, update, or review reference files in the skills directory. Use when user says "create a reference", "add a reference", "update reference X", "review references", or "extract this to a reference". Do NOT use for skills themselves (use /config-skills) or loading skills (use /load-skills).
disable-model-invocation: true
references:
  - ../references/present-first.md
  - ../references/output-diff.md
argument-hint: "[create|update|review] [reference-name] [description or context]"
---

## Reference Management

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `output-diff` reference for chunked change presentation — show reasoning + content blocks for each proposed reference change before writing.

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
| Skill-specific | `<topic>.md` in `<skill>/references/` | `./references/template.md` |

## MCP Tool Name Convention

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
