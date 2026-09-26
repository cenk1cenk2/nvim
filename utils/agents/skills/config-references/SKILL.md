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
  - ../references/scm/commit-push-scoped.md
  - ../references/mcp-tool-naming.md
  - ../references/harness/harness-connectors.md
argumentHint: '[create|update|review] [reference-name] [context]'
---

## Reference Management

Posture: `present-first`. Present proposed changes per `output-diff` before writing. Keep real private specifics out of references and their examples per `redact-private-data`. Once edits land, commit and push per `commit-push-scoped` — stage the reference files plus any consuming skill whose frontmatter changed, scope `agents`, branch `rolling`; ask before committing unless the request already blessed the push.

**Target: the reference file whose topic covers the convention**, inferred from what the lesson is actually about; a new reference when none fits.

Target discovery and the self-edit gate per `config-targets`.

## Reference Directory Structure

References live in two locations under `~/.config/nvim/utils/agents/skills/`:

- `references/` — shared references consumed by multiple skills, grouped into family folders.
- `<skill-name>/references/` — skill-specific references consumed only by that skill.

**Shared references are grouped by family, and the root is a legitimate home.**

```
references/
├── agent/        # dispatch, worktrees, conventions, watchers, completion
├── excalidraw/   # elements, templates, MCP preview
├── harness/      # per-runtime mechanics, connectors, provider paths
├── kilic/        # this operator's own infra and observability specifics
├── linear/       # workspace, issue, project, document conventions
├── scm/          # platform detection, PR/MR workflows, commits and trailers
└── *.md          # cross-cutting conventions that belong to no family
```

**Group into a folder when the flat list gets hard to navigate, not at a file count.** A family of related references earns a folder once finding or telling them apart at the root becomes a problem. A single reference never gets a folder of its own. Cross-cutting references such as `output-diff`, `present-first`, `plan-mode`, `mode-toggle` and `current-state-only` are cited from every family, so they stay at the root; a folder would misfile them. A one-off service reference with no siblings, such as `obsidian` or `tmux`, stays at the root too.

When a family moves into a folder, move all of its files and update every declaring skill's path in the same change.

**The folder is part of the declared path**, which is relative to the declaring skill's directory: `../references/scm/commit-style.md` for a family file, `../references/<file>.md` at the root, `./references/<file>.md` for a single-consumer file (absolute base `~/.config/nvim/utils/agents/skills/`). Bodies are unaffected — they cite by name, never by path.

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

Loading mechanics — manifest rows, fetch by path, `bundle: true`, the loaded-path set — belong to the `hyprpilot-skills` skill. What matters when authoring:

- **A declaration costs a manifest row, not the file.** The expensive mistake is a **large multi-topic reference**: a step that needs one section fetches all of it. Split whenever a step would use only part of a file.
- **Path identity de-duplicates.** Every consumer declaring the same file resolves to the same canonical path, so a reader holding it pays once per session. There are no name collisions and no shadowing.
- **A path that does not resolve fails silently.** Declared paths resolve relative to the skill's own directory; a typo is simply absent from the manifest and the skill runs without the convention. In a `bundle: true` read the file appears as a `status: not-found` block in its declared position — check for it after editing a reference or a consumer's frontmatter.

## Process

### Create

1. Determine the scope — **shared** or **skill-specific**.
   - Shared: the content applies to 2+ skills or is a general convention.
   - Skill-specific: the content supports only one skill and would clutter its SKILL.md.
2. If shared, list `~/.config/nvim/utils/agents/skills/references/` **and its family folders** to check for existing references and avoid duplication.
3. If skill-specific, read the parent skill at `~/.config/nvim/utils/agents/skills/<name>/SKILL.md` to understand context.
4. Name the file:
   - Shared, with a family: `<family>/<family>-<topic>.md` (e.g. `linear/linear-prerequisite.md`, `scm/scm-detect.md`).
   - Shared, cross-cutting: `<topic>.md` at the references root.
   - Skill-specific: `<topic>.md` inside `<skill-name>/references/`.
5. Draft the reference content following the format above, current state only per `current-state-only`.
6. Identify which skills should declare this reference in their frontmatter.
7. Present the draft and the list of skills to update.
8. After approval, write the file and update skill frontmatter as needed.
9. **Confirm the new path appears** in `list_skill_references { slug }` for a consumer. The server watches the roots, so a written declaration is rescanned on its own; a path still absent is a typo or an unresolvable file, since both look identical here.

### Update

1. Read the existing reference at `~/.config/nvim/utils/agents/skills/references/<family>/<name>.md`, or at the references root when it is cross-cutting.
2. Read skills that declare it — search for the filename in skill frontmatter to understand consumers.
3. Identify what needs to change based on conversation context.
4. Present proposed changes using diff format.
5. After approval, apply changes — replacing the old wording rather than annotating it, per `current-state-only`.
6. If the update changes the reference's scope or contract, notify about affected skills.
7. When any consumer's frontmatter changed, verify the manifest picked it up — see Create step 9.

### Review

1. List all files in `~/.config/nvim/utils/agents/skills/references/`, recursing into the family folders.
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
| Family shared | `<family>/<family>-<topic>.md` | `linear/linear-prerequisite.md`, `scm/scm-github.md` |
| Cross-family shared | `<topic>.md` at the root | `output-diff.md`, `plan-mode.md` |
| Per-harness | `harness/<consumer>-harness-<provider>.md` | `harness/agent-delegate-harness-claude.md` |
| Skill-specific | `<topic>.md` in `<skill>/references/` | `./references/template.md` |

The family prefix stays in the filename even inside its folder. `scm/scm-github.md` reads as redundant in a listing, but the **name** is what bodies cite and what the manifest surfaces, and a bare `github.md` is ambiguous the moment it is quoted away from its path.

## A Reference Is Not a Pointer

How a body cites references and other skills — by name inline, never a path or a summary, a name only through a manifest the reader holds, another skill as "Load `X`" — is `config-skills`'s; Load it when a consumer's call site changes.

Never create a reference whose only content is "go load skill X". A reference carries a convention; forwarding to a skill just adds a hop and a fetch. A convention owned by another skill is reached by loading that skill, not by naming its references. When a consumer's call site grows past a line, the content belongs in the reference.

## Do Not Declare What a Composed Skill Brings

When a body loads another skill for a branch, that skill arrives **with its own references**. A reference needed only on that branch does not belong in your frontmatter — declaring it taxes every run for a branch most runs skip.

`agent-plan` composes with the Linear pickup skills when the input is Linear, and those declare `linear-state-transitions` and `linear-chunk-issues`. So `agent-plan` does not.

**The test is what the reference serves, not whether both files list it.** Overlap is usually correct:

- **Keep it** when your own steps need it — `present-first` and `output-diff` govern *your* writes, and every writing skill declares them independently. Two skills sharing them is not duplication.
- **Drop it** when it exists purely for the composed skill's job, and your body only mentions it inside that branch.

Applied naively this deletes load-bearing declarations. Check each one against the body: if a step outside the composition branch names it, it stays.

## A Reference Is Shared — Situational Content Stays a Reference

**One property makes something a reference: two or more consumers must stay in lockstep on it.**

Situational content — needed only on some runs, only under one runtime, only for one platform — **is a reference.** Declare it and fetch it on the branch that needs it. That is the conditional-family pattern: declare every member, fetch the one that applies.

| | Reference | Skill |
|---|---|---|
| Arrives | a manifest row always; the body when fetched | only when loaded by name |
| Cost | a manifest row declared, the body only if fetched | a catalog entry in **every** session |
| Discoverable | via its consumers' manifests | yes, listed in the catalog |
| Missed how | the reader has the path and skips the fetch | the agent never chooses to load it |

**Prefer the reference.** A catalog entry is paid by every session whether or not the thing is ever used, while a manifest row is paid only by sessions loading a consumer. And the fetch is mechanical — the path is in hand — where loading a skill is a judgement the agent can simply not make.

**Make it a skill when it is a workflow the user invokes**, or when it must be discoverable by an agent that has loaded none of its consumers. Not merely because it is conditional.

**The test:** if it is a *convention* that some runs need, it is a reference. If it is a *procedure someone invokes*, it is a skill.

Do NOT extract:

- Content with a single consumer — put it in `<skill>/references/` if it is genuinely bulky, otherwise inline. A single-consumer file in the shared directory is mislabelled.
- Skill-specific workflow steps, descriptions, or examples — unique per skill.
- Short inline rules that would lose their context when separated.
- Anything extracted purely to make a SKILL.md shorter — extraction moves tokens, it does not remove them.

## Giving a Reference a Skill Twin — the mode pair

**When the user can switch a convention on and off, it needs both halves.** The reference alone cannot be toggled, and a skill alone would only apply to sessions that happened to load it. So the two split by job:

| Half | Carries | Reaches the agent |
|---|---|---|
| `references/<name>.md` | the rules, the posture, what stays true when it is off | declared by every skill it governs — applies whether or not the skill is ever loaded |
| `<name>/SKILL.md` | **only the toggle** | loaded by name, and only when the user changes the state |

**Same name on both halves**, so the reader who sees `per \`present-first\`` and the user who types `/present-first` land on the same subject.

`present-first` is the worked example: a reference declared by every writing skill, and a small skill that changes its state and nothing else, leaning on `mode-toggle` for the on/off mechanics.

**`caveman` is the deliberate exception.** It has no reference half: `AGENTS.md` §I step 4 force-loads the skill in every session, so it carries its rules inline.

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
- **Pick the tier from who may flip it.** `present-first` is model-invocable because a skill's own flow may legitimately turn its gate off; a mode only the user may change is manual.
- **Not every reference wants a twin.** Only add one when there is a real state the user changes. A convention that simply always applies stays a lone reference.

## Split a Reference When Part of It Is Conditional

A step that fetches a reference pays for all of it. When a chunk is only needed on some runs, split it so each step fetches only what it uses. Two shapes to look for when a reference grows past a few hundred lines:

- **A per-domain catalogue.** Signals, recipes, provider quirks, worked examples — a reader needs the one entry matching what they are doing and none of the rest. Split it into its own file, declared by every consumer like any conditional family. When the catalogue is something invoked for one entry at a time, it can be a skill instead: `agent-watcher-recipes` is a skill holding the per-domain signals and checks, declaring `agent-watchers`, which keeps the discipline, cadence and audit.
- **Runtime-specific content in a file that claims to be agnostic.** A parameter table, a tool name, a default — it belongs in the `<consumer>-harness-<provider>` file, and leaving it in the shared one is both waste and a contradiction of the shared file's own rule.

**Splitting is not the same as extracting for reuse.** Extraction shares content between consumers; this split removes tokens from the runs that do not take the branch. Only conditional content qualifies — anything every consumer needs on every run stays put, however long it is.

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

## MCP Tool Names

Servers and tools are named per `mcp-tool-naming`. Where a harness connector exists for the service, a reference presents it as the one used, with the standalone server as the stated fallback, per `harness-connectors`.

## Key Principles

- A reference is **fetched whole** whenever a step needs it — keep it focused on one topic and ruthlessly short, because every fetch pays its full length.
- A reference should be **self-contained** — readable without loading other references.
- **No frontmatter** — only skills have YAML frontmatter.
- **No workflow steps** — references contain conventions and patterns, not process instructions.
- **State the convention, not its inverse.** A reference says what the shape is; a prohibition belongs in it when the user asked for one, or when the wrong move destroys work. Invented forbidden cases cost every consumer on every load and teach nothing a positive statement did not already.
- **Current state only**, per `current-state-only` — rewrite to the live shape and delete the old one.
- After creating or updating a shared reference, always check if skills need their `references:` frontmatter updated.
