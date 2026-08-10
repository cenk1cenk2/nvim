---
name: config-references
description: 'config-references Create, update, or review reference files in the skills directory. Triggers: "create/add/update a reference", "extract this to a reference". Do NOT use for skills themselves (config-skills) or loading skills (load-skills).'
disableModelInvocation: true
references:
  - ../references/output-diff.md
  - ../references/redact-private-data.md
  - ../references/commit-push-scoped.md
argumentHint: "[create|update|review] [reference-name] [description or context]"
---

## Reference Management

Present proposed changes per `output-diff` before writing. Keep real private specifics out of references and their examples per `redact-private-data`. Once edits land, commit and push per `commit-push-scoped` — stage the reference files plus any consuming skill whose frontmatter changed, scope `agents`, branch `rolling`.

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

## How References Resolve

**A skill's declared references are appended to it on read.** `read_skill` and `hyprpilot://skills/<slug>` both bundle them; `references: false` opts out of the tool's default, and `load_skill_references { slug }` / `hyprpilot://references/<slug>` fetch the bundle alone. So the `references:` array is the load list, **declaring a reference is a token cost paid on every load of that skill**, and a reference the body never uses is waste multiplied by every invocation.

That cost compounds across a session: a reference declared by many skills is re-injected by each one. `output-diff` is declared by 48 skills, `scm-detect` by 19, `agents-delegate` by 8 at 3.4k tokens each. A reader can skip the repeat with `references: false` and top up what it lacks, so **size matters most for the widely-declared files** — trimming one of those pays back on every consumer.

That splits references into two tiers, and choosing the wrong one is the most common authoring mistake:

| Tier | Mechanism | Use when |
|------|-----------|----------|
| **Declared** | listed in `references:`; injected on every load | every run of the consuming skill uses it |
| **Path-read** | named in the body **with its absolute path**, read only when that branch is reached | only some runs use it — one runtime out of three, one platform out of two, an error path |

Hyprpilot resolves declared paths **relative to that skill's own bundle directory** — the directory holding its `SKILL.md`. There is no separate references root. A path that does not resolve is simply absent from the bundle: nothing is logged and nothing errors, so a typo fails silently and the skill runs without the convention it declared. A missed path-read fails the same silent way.

A bundle delimits each file with a YAML block naming it and its declared path, all under a banner naming the skill and the count:

```
---
skill_references:
  skill: git-commit
  count: 2
---

---
reference:
  name: commit-style
  path: ../references/commit-style.md
---
<file body>
```

A file that fails to read yields the same block with `status: not-found`, **in its declared position** — that marker is the only signal a path is wrong, so check for it after editing a reference or a consumer's frontmatter.

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
   - Bundle one consuming skill's references and confirm this file appears — a declared path that silently fails to resolve looks identical to a correct one in the frontmatter.
   - Identify orphaned references (declared by no skill). **The `harness-<provider>-<consumer>` files are declared by nobody on purpose** — they are path-read, named in bodies with an absolute path. They are never orphans; check that a consuming body still names each one instead.
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
- **The consuming skill does NOT declare the provider files — they are path-read.** Declaring all three injects all three when at most one is usable, so two are guaranteed waste on every load. The body names the family with an absolute path — `~/.config/nvim/utils/agents/skills/references/harness-<provider>-agent-background.md` — and resolves `<provider>` at runtime. Never name a single runtime's file.
- **Content is concrete on purpose.** Tool names, parameter names, defaults, env vars, limits, and known traps belong here; this is the one place where naming a specific runtime's tool is correct.
- **Version-mark claims and flag what you could not confirm.** Runtime behavior changes between releases — an unmarked claim rots invisibly, and a guessed one is worse than an absent one. Write `⚠ Unverified` in place rather than asserting.
- **Do not create a provider's file until its behavior is known.** An empty harness file implies coverage that does not exist.

## MCP Tool Name Convention

**⛔ ABSOLUTE — the harness-provided integration outranks the standalone server.** Where the running harness supplies an integration for a service (on Claude Code, `mcp__claude_ai_<Connector>__*`), references must present it as the one that is used, with the standalone MCP server as the stated fallback — not the other way round. A reference that tabulates only the standalone server's tools reads as an instruction to use it; when a harness connector exists for that service, pair the table with the mapping and point at `harness-connectors`. See `slack.md` for the shape.

When references list MCP tool names in tables or inline, use the **`<server>__<tool>` short form** with **kebab-case server names**: `linear-kilic__get_issue`, `slack-kilic__slack_list_channels`, `argocd-kilic__list_applications`, `grafana-laravel__query_prometheus`, `spacelift-laravel__list_stacks`. Server keys use `-` only; `/` and `_` are not valid separators inside server keys. Do NOT bake in a transport prefix (`mcp__...`) — the runtime resolves the prefix at call time. Hyprpilot wires every MCP server directly (no aggregator hub), so the bare server name is the only thing that matters in references.

**Servers that do not exist — never reference these:**

- `git__*` tools — there is no `git` MCP. Reference raw `git` CLI (`git status`, `git diff`, `git log`, etc.) via `Bash` instead.
- `kubernetes__*` tools — there is no `kubernetes` MCP. Reference `kubectl` CLI via `Bash` if needed.

**Tmux MCP is read-only.** Only the read-only tools (`tmux__list-*`, `tmux__capture-pane`, `tmux__find-session`, `tmux__get-command-result`) are usable. References must NOT include `execute-command`, `create-window`, `split-pane`, `kill-*`, or `create-session` as a recommended action. For command execution, reference the built-in `Bash` tool. For reads, reference the `tmux__*` tools rather than `tmux` CLI invocations — the CLI belongs in a reference only where the MCP exposes no equivalent (the *current* session) or where the MCP may be absent. Session naming and capture-size guidance live in `tmux.md`; point at it instead of duplicating either.

## Committing Changes

After applying reference edits and any consumer frontmatter updates, hand off per the `commit-push-scoped` reference — stage only the touched files, then compose with `git-commit` (scope `agents`, e.g. `feat(agents): ...`) and `git-push` targeting `rolling`. Ask before committing unless the request already blessed the push.

## Key Principles

- References are **bundled whenever their skill loads** — keep them focused on one topic and ruthlessly short, because every consumer pays their full length on every load.
- A reference should be **self-contained** — readable without loading other references.
- **No frontmatter** — only skills have YAML frontmatter.
- **No workflow steps** — references contain conventions and patterns, not process instructions.
- **Current state only** — no deprecation notes, no "formerly X", no history of what a convention replaced. Rewrite to the live shape and delete the old one; a past shape named in a reference is one the agent can match by mistake. Version-marking *current* runtime behavior in a `harness-*` file stays — that dates a live claim rather than narrating a change.
- After creating or updating a shared reference, always check if skills need their `references:` frontmatter updated.
