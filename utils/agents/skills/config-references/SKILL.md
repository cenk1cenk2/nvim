---
name: config-references
description: config-references Create, update, or review the shared reference files that skills declare. Use on "create a reference", "extract this to a reference", "review the references". Not for the skills themselves, or for resolving which skill to load.
disableModelInvocation: true
references:
  - ../references/current-state-only.md
  - ../references/present-first.md
  - ../references/config-targets.md
  - ../references/output-diff.md
  - ../references/redact-private-data.md
  - ../references/commit-push-scoped.md
argumentHint: '[create|update|review] [reference-name] [context]'
---

## Reference Management

Posture: `present-first`. Present proposed changes per `output-diff` before writing. Keep real private specifics out of references and their examples per `redact-private-data`. Once edits land, commit and push per `commit-push-scoped` — stage the reference files plus any consuming skill whose frontmatter changed, scope `agents`, branch `rolling`.

**Target: the reference file whose topic covers the convention**, inferred from what the lesson is actually about; a new reference when none fits. Targets and the propose-don't-write rule for a gap in this skill: `config-targets`.

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

**A skill's `references:` array is a manifest, not a payload.** `read_skill { slug }` returns the body plus one manifest row per declared reference — `path`, `name`, `size`, `modified`, `created`, and the reference's own frontmatter. **The bodies do not come with it.** The reader fetches the ones it needs with `read_skill_references { references: [path] }`, addressed by canonical absolute path.

**So declaring a reference costs a manifest row, roughly 150 bytes, not the file.** A body averages 4,619 bytes. That inverts the old authoring economics: an extra declaration is nearly free, and the expensive mistake is now a **large multi-topic file**, because a step that needs one section of it pays for all of them. Splitting pays whenever a step uses less than about 97% of a file — in practice, always.

`output-diff` is declared by 57 skills and `scm-detect` by 31, so a reader that keeps a loaded-path set pays for each once per session. Path identity is what makes that mechanical: `git-commit`'s `output-diff` and `git-push`'s `output-diff` are the same path, so they de-duplicate on sight. There are no name collisions and no shadowing.

Hyprpilot resolves declared paths **relative to that skill's own bundle directory** — the directory holding its `SKILL.md`. There is no separate references root. A path that does not resolve is simply absent from the manifest: nothing is logged and nothing errors, so a typo fails silently and the skill runs without the convention it declared.

`read_skill { slug, bundle: true }` still returns every body inline, delimited by a YAML block naming each file and its declared path, under a banner naming the skill and the count. Reach for it on the first load of an unfamiliar skill, not as a habit:

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
5. Draft the reference content following the format above, current state only per `current-state-only`.
6. Identify which skills should declare this reference in their frontmatter.
7. Present the draft and the list of skills to update.
8. After approval, write the file and update skill frontmatter as needed.

### Update

1. Read the existing reference at `~/.config/nvim/utils/agents/skills/references/<name>.md`.
2. Read skills that declare it — search for the filename in skill frontmatter to understand consumers.
3. Identify what needs to change based on conversation context.
4. Present proposed changes using diff format.
5. After approval, apply changes — replacing the old wording rather than annotating it, per `current-state-only`.
6. If the update changes the reference's scope or contract, notify about affected skills.

### Review

1. List all files in `~/.config/nvim/utils/agents/skills/references/`.
2. For each reference (or a specific one if requested):
   - Read its content.
   - Check which skills declare it in their frontmatter.
   - Bundle one consuming skill's references and confirm this file appears — a declared path that silently fails to resolve looks identical to a correct one in the frontmatter.
   - Identify orphaned references (declared by no skill). **The `<consumer>-harness-<provider>` files are declared by every consumer in the family on purpose** — all providers are declared, one body is fetched. A missing declaration is the defect, not an extra one.
   - Identify stale content, and any compat note or history the `current-state-only` check forbids.
   - Check for duplication across references.
3. Present findings and propose improvements.

## Naming Conventions

| Type | Pattern | Examples |
|------|---------|----------|
| Family shared | `<family>-<topic>.md` | `linear-prerequisite.md`, `scm-github.md` |
| Cross-family shared | `<topic>.md` | `output-diff.md`, `plan-mode.md` |
| Per-harness | `<consumer>-harness-<provider>.md` | `agent-delegate-harness-claude.md`, `agent-background-harness-codex.md` |
| Skill-specific | `<topic>.md` in `<skill>/references/` | `./references/template.md` |

## A Reference Is Not a Pointer

**Cite a reference by NAME, never by path.** A body names it inline where used (`per \`output-diff\``) with no load instruction — the reader resolves that name against the manifest `read_skill` just handed it. A path in prose is machine detail that breaks the moment the file moves. **Skills do not arrive at all** — a body needing another skill writes `Load \`agent-harness\`.` plus its trigger. `config-skills` owns that form.

Never create a reference whose only content is "go load skill X". A reference carries a convention; forwarding to a skill just adds a hop and a fetch.

## Consumers Name It, Never Summarise It

**The reader can fetch the reference the moment it needs it.** A call site that explains what the reference contains pays for the same content twice, and the summary rots the moment the reference changes while the reader cannot tell which is current.

- **`<thing> per \`x\`.`** That is the base form. Not "per the `x` reference", not "read `x` to learn how", not a sentence describing what `x` covers.
- **Fold in *when* it applies, when that is not obvious** — `Before the first dispatch, mechanics per \`agent-delegate\`.` A trigger is what lets the reader check whether this run needs it, so it earns its clause. What the reference *contains* never does.
- **Add at most ONE further clause**, and only for a deviation this run needs.
- **Name it once per consuming file.** A second mention of the same reference is drift waiting to happen.
- **A declared reference gets no inline summary at all** — it cannot fail to load. Only a path-read reference earns a one-line summary, because that read genuinely may not happen.

When a consumer's call site grows past a line, the content belongs in the reference, not at the call site.

## Do Not Declare What a Composed Skill Brings

When a body loads another skill for a branch, that skill arrives **with its own references**. A reference needed only on that branch does not belong in your frontmatter — declaring it taxes every run for a branch most runs skip.

`agent-plan` composes with the Linear pickup skills when the input is Linear, and those declare `linear-state-transitions` and `linear-chunk-issues`. So `agent-plan` does not.

**The test is what the reference serves, not whether both files list it.** Overlap is usually correct:

- **Keep it** when your own steps need it — `present-first` and `output-diff` govern *your* writes, and every writing skill declares them independently. Two skills sharing them is not duplication.
- **Drop it** when it exists purely for the composed skill's job, and your body only mentions it inside that branch.

Applied naively this deletes load-bearing declarations. Check each one against the body: if a step outside the composition branch names it, it stays.

## A Reference Is Shared — Situational Is No Longer a Reason to Make It a Skill

**One property makes something a reference: two or more consumers must stay in lockstep on it.**

Situational content — needed only on some runs, only under one runtime, only for one platform — **is still a reference.** Declare it and fetch it on the branch that needs it. That is the conditional-family pattern: declare every member, fetch the one that applies.

| | Reference | Skill |
|---|---|---|
| Arrives | a manifest row always; the body when fetched | only when loaded by name |
| Cost | ~150 bytes declared, the body only if fetched | a catalog entry (~798 bytes) in **every** session |
| Discoverable | via its consumers' manifests | yes, listed in the catalog |
| Missed how | the reader has the path and skips the fetch | the agent never chooses to load it |

**Prefer the reference.** A catalog entry is paid by every session whether or not the thing is ever used, while a manifest row is paid only by sessions loading a consumer. And the fetch is mechanical — the path is in hand — where loading a skill is a judgement the agent can simply not make.

**Make it a skill when it is a workflow the user invokes**, or when it must be discoverable by an agent that has loaded none of its consumers. Not merely because it is conditional.

**The test:** if it is a *convention* that some runs need, it is a reference. If it is a *procedure someone invokes*, it is a skill.

## Giving a Reference a Skill Twin — the mode pair

**When the user can switch a convention on and off, it needs both halves.** The reference alone cannot be toggled, and a skill alone would only apply to sessions that happened to load it. So the two split by job:

| Half | Carries | Reaches the agent |
|---|---|---|
| `references/<name>.md` | the rules, the posture, what stays true when it is off | declared by every skill it governs — applies whether or not the skill is ever loaded |
| `<name>/SKILL.md` | **only the toggle** | loaded by name, and only when the user changes the state |

**Same name on both halves**, so the reader who sees `per \`present-first\`` and the user who types `/present-first` land on the same subject.

`present-first` is the worked example: a 1,562-byte reference declared by 53 skills, against a 1,371-byte skill that changes its state and nothing else. `caveman` is the same shape for voice, and both lean on `mode-toggle` for the on/off mechanics.

### Structuring the skill half

Keep it small. Its whole job is state.

```yaml
---
name: <name>                       # identical to the reference
description: <name> Toggle the ... posture. The posture already rides along with
  every skill that ...; load this only to change its state. Not for <the per-use case>.
references:
  - ../references/<name>.md        # its own rules
  - ../references/mode-toggle.md   # the on/off mechanics
argumentHint: '[on|off]'
---
```

Body, in order:

1. **One sentence disclaiming the rules.** Say they live in the reference, that the reference arrives with every skill it governs, and that nothing needs loading for the posture to apply. This is what stops the skill growing a second copy of the rules.
2. **A `## Toggle` section**, opening with `On/off mechanics per \`mode-toggle\`.` then five fixed lines:
   - **On** — the default state if any, the slash form, and the phrases a user actually types.
   - **Off** — the phrases that end it, and how long that lasts.
   - **Level** — intensity settings, or `none — on or off`.
   - **Survives disengage** — what stays armed or written after it is switched off. Usually `nothing`.
   - **Layering** — that it sits under other modes and never toggles one.
3. **A closing line on acknowledgement** — what to say when the state changes, including what the toggle does *not* lift (destructive-action gates, any skill's own stricter rule).

### Rules

- **Never restate the posture in the skill.** Both halves are in context whenever the skill loads, so a copy is the same content paid twice and rots the moment the reference changes.
- **The reference must state what survives the mode being off.** Turning a mode off never lifts a destructive-action gate or a stricter rule a skill sets for itself, and that belongs with the rules, not with the toggle.
- **Pick the tier from who may flip it.** `caveman` is manual because only the user changes voice; `present-first` is model-invocable because a skill's own flow may legitimately turn its gate off.
- **Not every reference wants a twin.** Only add one when there is a real state the user changes. A convention that simply always applies stays a lone reference.

## Split a Reference When Part of It Is Conditional

A reference is paid for on **every** load by **every** consumer. When a chunk of it is only needed on some runs, that chunk is taxing all the others.

Two shapes to look for when a reference grows past a few hundred lines:

- **A per-domain catalogue.** Signals, recipes, provider quirks, worked examples — a reader needs the one entry matching what they are doing and none of the rest. Split it out and reach it by **path-read** with the absolute path, so it loads only when that branch is taken. `agent-watchers` keeps the discipline, the cadence table and the audit; `agent-watcher-recipes` holds the per-domain signals and shell checks.
- **Runtime-specific content in a file that claims to be agnostic.** A parameter table, a tool name, a default — it belongs in the `<consumer>-harness-<provider>` file, and leaving it in the shared one is both waste and a contradiction of the shared file's own rule.

**Splitting is not the same as extracting for reuse.** Extraction shares content between consumers and moves tokens without removing them. This split *removes* tokens from most loads, because the new file is path-read rather than declared. Only conditional content qualifies — anything every consumer needs on every run stays put, however long it is.

**When the split lands, the stub must carry the absolute path**, since a missed path-read is silent: the run simply proceeds without the recipes and nobody is told.

## Per-Harness References

When a skill's *mechanics* differ by agent runtime while its *intent* does not, the runtime-specific half becomes one reference per runtime, named `<consumer>-harness-<provider>.md`. The trailing segment is the exact name of the consuming skill or shared reference, so the filename says what it configures.

```
agent-delegate-harness-claude.md      # dispatch mechanics for the agent-delegate reference, on Claude Code
agent-delegate-harness-codex.md       # same slot, different runtime
agent-background-harness-claude.md    # waiting/waking mechanics for the agent-background skill
```

**Two shapes, do not confuse them:**

- `<consumer>-harness-<provider>.md` — mechanics of one runtime for one consuming skill (`agent-background-harness-claude`). Per (runtime x consumer).
- `harness-<topic>.md` — a cross-harness policy plus a per-harness inventory (`harness-connectors`). One file, all runtimes, because the rule is the same everywhere and only the inventory differs.

Rules:

- **Split by consumer, not by provider alone.** One file per (runtime × consumer) keeps a skill loading only the mechanics it needs. Do not accumulate every runtime detail into a single file per provider.
- **The consuming skill declares EVERY provider file in the family.** Bodies are fetched on demand, so three declarations cost three manifest rows and fetch one body. The body names the family with the placeholder — `agent-background-harness-<provider>` — and resolves `<provider>` at runtime. Never name a single runtime's file in a runtime-agnostic body.
- **Content is concrete on purpose.** Tool names, parameter names, defaults, env vars, limits, and known traps belong here; this is the one place where naming a specific runtime's tool is correct.
- **Version-mark claims and flag what you could not confirm.** Runtime behavior changes between releases — an unmarked claim rots invisibly, and a guessed one is worse than an absent one. Write `Unverified` in place rather than asserting.
- **Do not create a provider's file until its behavior is known.** An empty harness file implies coverage that does not exist.

## MCP Tool Name Convention

**ABSOLUTE — the harness-provided integration outranks the standalone server.** Where the running harness supplies an integration for a service (on Claude Code, `mcp__claude_ai_<Connector>__*`), references must present it as the one that is used, with the standalone MCP server as the stated fallback — not the other way round. A reference that tabulates only the standalone server's tools reads as an instruction to use it; when a harness connector exists for that service, pair the table with the mapping and point at `harness-connectors`. See `slack.md` for the shape.

When references list MCP tool names in tables or inline, use the **`<server>__<tool>` short form** with **kebab-case server names**: `linear-kilic__get_issue`, `slack-kilic__slack_list_channels`, `argocd-kilic__list_applications`, `grafana-laravel__query_prometheus`, `spacelift-laravel__list_stacks`. Catalog server keys use `-` only, and `/` is never valid in one. **Hyprpilot's injected servers are `_` delimited** — write `hyprpilot_skills`, `hyprpilot_nvim`, and `hyprpilot_harness` verbatim; every skill slug is `-`, so a server and its same-named skill differ by delimiter on purpose. Do NOT bake in a transport prefix (`mcp__...`) — the runtime resolves the prefix at call time. Hyprpilot wires every MCP server directly (no aggregator hub), so the bare server name is the only thing that matters in references.

**Servers that do not exist — never reference these:**

- `git__*` tools — there is no `git` MCP. Reference raw `git` CLI (`git status`, `git diff`, `git log`, etc.) via `Bash` instead.
- `kubernetes__*` tools — there is no `kubernetes` MCP. Reference `kubectl` CLI via `Bash` if needed.

**Tmux MCP is read-only.** Only the read-only tools (`tmux__list-*`, `tmux__capture-pane`, `tmux__find-session`, `tmux__get-command-result`) are usable. References must NOT include `execute-command`, `create-window`, `split-pane`, `kill-*`, or `create-session` as a recommended action. For command execution, reference the built-in `Bash` tool. For reads, reference the `tmux__*` tools rather than `tmux` CLI invocations — the CLI belongs in a reference only where the MCP exposes no equivalent (the *current* session) or where the MCP may be absent. Session naming and capture-size guidance live in `tmux.md`; point at it instead of duplicating either.

## Committing Changes

After applying reference edits and any consumer frontmatter updates, hand off per `commit-push-scoped` — stage only the touched files, then compose with `git-commit` (scope `agents`, e.g. `feat(agents): ...`) and `git-push` targeting `rolling`. Ask before committing unless the request already blessed the push.

## Key Principles

- References are **bundled whenever their skill loads** — keep them focused on one topic and ruthlessly short, because every consumer pays their full length on every load.
- A reference should be **self-contained** — readable without loading other references.
- **No frontmatter** — only skills have YAML frontmatter.
- **No workflow steps** — references contain conventions and patterns, not process instructions.
- **State the convention, not its inverse.** A reference says what the shape is; a prohibition belongs in it when the user asked for one, or when the wrong move destroys work. Invented forbidden cases cost every consumer on every load and teach nothing a positive statement did not already.
- **Current state only**, per `current-state-only` — rewrite to the live shape and delete the old one.
- After creating or updating a shared reference, always check if skills need their `references:` frontmatter updated.
