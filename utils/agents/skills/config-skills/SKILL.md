---
name: config-skills
description: config-skills Create, update, or review skills in the skills directory. Use on "create a skill", "update this skill", "add a slash command", "improve this skill". Not for the shared reference files, and not for resolving which skill to load.
disableModelInvocation: true
references:
  - ../references/current-state-only.md
  - ../references/present-first.md
  - ../references/config-targets.md
  - ../references/output-diff.md
  - ../references/redact-private-data.md
  - ../references/scm/commit-push-scoped.md
argumentHint: '[create|update|review] [skill-name] [what it should do]'
---

## Skill Management

Posture: `present-first`.
Present proposed changes per `output-diff` before writing. Keep real private specifics out of skills, references, and examples per `redact-private-data`. Once edits land, commit and push per `commit-push-scoped` — scope `agents`, branch `rolling`.

## ABSOLUTE RULE — change the RELEVANT skills, not this one

**When you learn something that should change agent behaviour, discover and edit the skills that actually govern that behaviour. Do NOT write it into `config-skills`.** This file is *authoring guidance* — how to write, structure, and validate a skill. It is not where operational rules live, and nothing reads it at the moment the behaviour is needed.

A rule about dispatching subagents belongs in the dispatch skills and their per-provider references. A rule about waiting on external state belongs in the background/watcher skill. A rule about a rollout's sequencing belongs in that flow's own skill or repository note. Putting any of those here means the agent that needed it never sees it.

So, before editing:

1. **Find the skills that own the behaviour** — search `~/.config/nvim/utils/agents/skills/` for the ones whose process steps actually perform it. There is usually more than one (a family of skills plus a shared reference). **Name them back in one line before drafting**; a run that opens with a draft has skipped this step.
2. **Edit every one of them**, not just the first. A rule present in one sibling and absent in the others fails exactly when a different entry point is used.
3. **Put runtime-specific mechanics in the per-provider reference**, and the runtime-agnostic principle in the body (see *Provider-Specific Behavior*).
4. **A gap in `config-skills` itself gets proposed, not written**, per `config-targets`. Even when the lesson is genuinely about authoring — a new frontmatter field, a validation rule, a structural convention — raise it and stop. Two things must both hold before this file is edited: the captain **names** it, and the captain **blesses** the presented change. Naming without a blessing means present and wait; a blessing for other work never reaches this file.

**This is absolute.** "I'll record it in config-skills so future authors know" is the failure mode: it documents the lesson where nobody acts on it and leaves the real skills wrong.

## Skills Directory

All skills live in `~/.config/nvim/utils/agents/skills/`. Each skill is a directory containing a `SKILL.md` file. Shared reference files live in `references/` at the skills root.

```
~/.config/nvim/utils/agents/skills/
├── references/           # Shared references, grouped into family folders
│   ├── <family>/         # agent, harness, linear, scm, excalidraw, kilic
│   └── <topic>.md        # cross-cutting conventions live at the root
├── <skill-name>/
│   ├── SKILL.md
│   └── references/       # Skill-specific references (single consumer)
└── <another-skill>/
    └── SKILL.md
```

**Never hand-maintain a file list here.** `ls ~/.config/nvim/utils/agents/skills/references/` is the live inventory; a copy in this file is stale the moment anyone adds a reference.

## Skill Ecosystem

Skills in this directory form an interconnected system. A skill may depend on or compose with other skills in the same folder. When creating or updating a skill, read related skills to understand how they connect. Document any dependencies or composition in the process steps of the skill itself.

## Process

### Create

1. Determine what the skill should do. Ask the user if not clear from context.
2. Read 2-3 existing skills in the same family to understand patterns, tone, and structure. For each, read `~/.config/nvim/utils/agents/skills/<name>/SKILL.md` directly — issue reads in parallel.
3. **Check references** — read shared references at `~/.config/nvim/utils/agents/skills/references/<name>.md`. If the skill belongs to a family (e.g., Linear, Obsidian), check whether sibling skills declare references in their frontmatter and reuse the same ones.
4. Draft the full `SKILL.md`. Name any shared convention inline where the body uses it, and declare it in `references:`.
5. **Validate** — run the description checklist (see below), verify conventions, and run the `current-state-only` check: no compatibility notes, no history, nothing describing a past shape.
6. Present the draft in chat.
7. Iterate based on user feedback.
8. After approval, create the directory and write the file.
9. Reload the skill catalog using the reloading guidance below.

### Update

1. Read the existing `SKILL.md` for the target skill at `~/.config/nvim/utils/agents/skills/<target-skill>/SKILL.md`.
2. **Read the target with plain `read_skill { slug }`** — the manifest is enough to see what it declares. Fetch a reference body only when the change depends on its content.
3. Review the preceding conversation for key learnings, corrections, or deviations from the current skill content.
4. Identify what needs to change.
5. **Check for deduplication** — if the skill contains blocks that are duplicated in sibling skills (prerequisite blocks, plan mode directives, description structures, research patterns), check whether a shared reference already exists in `~/.config/nvim/utils/agents/skills/references/`. If it does, replace the duplicated block with an inline mention plus the declaration. If it doesn't and 2+ skills must stay in lockstep on it, propose extracting it.
6. **Validate** — run the description checklist against the updated description, and the `current-state-only` check over the edit: the old wording is deleted, not annotated.
7. Present proposed changes to the user.
8. Iterate based on feedback.
9. After approval, apply the changes.
10. Reload the skill catalog using the reloading guidance below.

### Review

1. Read the existing `SKILL.md` for the target skill.
2. **Validate** — run the description checklist (see below), check all conventions, and run the `current-state-only` check for compat notes or history that crept in.
3. **Audit references** — check whether the skill duplicates content a shared reference already carries, and whether every declaration is still accurate, still used by the body, and correctly tiered (declared vs path-read).
4. List ambiguities, inconsistencies, or areas that could be improved.
5. Ask clarifying questions to understand user intent.
6. Propose specific improvements based on answers.
7. After approval, apply the changes (or leave as-is if no changes needed).
8. If files changed, reload the skill catalog using the reloading guidance below.

## Reloading Skills

After creating, updating, deleting, or moving skill files:

1. Run `mcp__hyprpilot-skills__reload` so Hyprpilot refreshes the skill catalog.
2. Verify the reload result reports the expected skill count or succeeds without errors.
3. For changed skills, re-read the affected skill with `mcp__hyprpilot-skills__read_skill` when practical to confirm the daemon sees the latest content.
4. If references changed, use `mcp__hyprpilot-skills__list_skill_references { slug }` on an affected skill to confirm every declared path resolved into the manifest — a typo drops the row silently.
5. Report the reload result to the user.

## SKILL.md Format

Every `SKILL.md` starts with YAML frontmatter followed by markdown instructions.

**Required frontmatter fields:**

```yaml
---
name: skill-name # kebab-case, matches directory name
description: slug What it does. Use on "trigger phrase", "another phrase". Not for the situation it must not take.
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
| `references` | Resolved relative to the skill's own `bundleDir` into manifest rows carrying each file's canonical path; bodies fetched by path with `read_skill_references`. |
| `name` | Passed through only — the **directory name is the slug**. A mismatch changes nothing at runtime, so keep them equal for the reader. |

Everything else — `disableModelInvocation`, `argumentHint`, and any key you invent — is **passed through untouched**. Hyprpilot enforces none of it; those are conventions the agent reads out of the metadata block, and the central `AGENTS.md` is what turns `disableModelInvocation` into an actual invocation rule. A stray Claude Code key (`when_to_use`, `allowed-tools`, `model`, `hooks`, …) therefore does not error — it just reaches the agent as noise. Do not add them.

**Body structure:** the body starts directly with the plan-mode directive and top-level `##` sections — there is **no `## system` wrapper**.

```markdown
The body opens with content, not ceremony. No posture directive unless the skill deviates (see Posture above); no directive block for declared references — name them inline where used.

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

- **Manual** — reviews, reads, fixes, CI, scaffolding, config-authoring (`config-*`), personality modes, plan handoff/pickup, and any heavy or destructive orchestration the user should trigger deliberately (`git-split`, `code-improve`, `agent-*`).
- **Model-invocable** — routine actions the agent legitimately reaches for mid-task: git basics (`git-commit`, `git-branch`, `git-push`), PR/MR creation, most Linear operations, `plan-hard`.
- **Auto-invoke** — workspace/session initializers only (`linear-kilic`, `linear-laravel`, `slack-kilic`, `slack-laravel`, `spacelift-laravel`, `notion-laravel`).
- **Proactive-suggest overlay** — a Manual skill whose body tells the assistant to *recommend* itself on a trigger (rule drift, user deviations) but never self-invoke (`config-agents`, `obsidian-repository`). `config-repository` is the one skill kept Model-invocable with an explicit `disableModelInvocation: false` because autopilot may auto-apply it.

Note: omitting the flag and writing `disableModelInvocation: false` are behaviorally identical (default is `false`). Write it explicitly only when the autoload intent is the skill's defining feature and you want it legible in source (e.g. `config-repository`).

## References

### How References Load — declaring one costs a manifest row, not the file

**A skill's `references:` array is a manifest, not a payload.** `read_skill { slug }` returns the body plus one row per declared reference — `path`, `name`, `size`, `modified`, `created`, and the reference's own frontmatter — and **not the bodies**. The reader fetches what it needs with `read_skill_references { references: [path] }`, addressed by canonical absolute path. `bundle: true` still pulls every body inline for a first read of an unfamiliar skill.

**So a declaration costs roughly 150 bytes; a body averages 4,619.** Declaring is close to free, and a reader that keeps a loaded-path set pays for each distinct file once per session — which matters because `output-diff` is declared by 57 skills and `scm-detect` by 31.

The consequence that governs every decision below: **the expensive mistake is a large multi-topic reference, not an extra declaration.** A step that needs one section of a file pays for all of it, so splitting pays whenever a step uses less than about 97% of a file — in practice, always. Extraction into a shared reference buys consistency; granularity buys tokens.

**Declared is the default. Reserve path-read for what cannot be declared.**

| Tier | Mechanism | Use when |
|------|-----------|----------|
| **Declared** | listed in `references:`; appears in the manifest, body fetched on demand | almost always — the body cites it, on any run |
| **Path-read** | named in the body **with its absolute path** | the file is deliberately **not** declared by any skill, so no manifest carries it and `read_skill_references` refuses it |

Conditional use is not a reason to skip declaring: an unused row costs a manifest line, and declaring it makes the file fetchable by path. Path-read means genuinely undeclared — the per-harness family, where naming all three providers in one skill's frontmatter would claim files that belong to whichever runtime is live.

### A reference name only resolves through a manifest

`read_skill_references` accepts a path, and only a path some manifest published. So a reference name is not a portable address: naming `commit-style` in a body whose skill does not declare it hands the reader a name with nothing to fetch it by.

That decides how a body reaches a convention another skill owns — **route to the skill, not to the reference**:

- **Your own steps need it** — declare it. The row is yours, the path arrives with your skill.
- **A composed skill's steps need it** — write **Load `X`** and let X's manifest carry it. Do not name X's reference directly; the reader cannot address it until X is loaded.

The escape hatch is `Read` on the absolute path, which always works — and is why a path-read directive carries the path in full. A name alone is not enough.

**A path-read directive MUST carry the absolute path.** A missed `Read` raises no error — the skill simply runs without the convention it named, silently.

### Writing Reference Directives — name it inline, do not announce it

The reference text is **already in context** when the body runs. An instruction to go read it is a no-op that costs tokens to state. So name the reference where the body uses it, in the sentence that uses it:

```markdown
Present proposed changes per `output-diff`.
Fields and their defaults: `linear-mandatory-fields`.
Resolve tiers to concrete models via `agent-harness`.
```

Not this:

```markdown
> Read the `output-diff` reference for chunked change presentation — show reasoning +
> content blocks for each proposed change before asking for approval.
```

Rules:

- **Name the reference, never the act of reading it.** "per `X`", "via `X`", "fields per `X`".
- **No inline summary for a declared reference.** It cannot fail to load, so a summary is the same content paid for twice.
- **A real directive block is for path-read references only**, and it carries the absolute path plus a one-line summary — there, the read genuinely may not happen.
- **Reserve a bold ABSOLUTE marker and blockquote weight for traps** — a rule whose violation destroys work. Routine composition gets a clause, not a banner.
- **Never name the fetching tool.** The agent resolves that itself.

### Path Convention

Paths are relative to the skill's own directory:

- `../references/<family>/<file>.md` — shared references in a family folder (agent, harness, linear, scm, excalidraw, kilic).
- `../references/<file>.md` — cross-cutting shared references, which stay at the references root.
- `./references/<file>.md` — skill-specific references (inside the skill's own directory).

The absolute base is `~/.config/nvim/utils/agents/skills/`. So `../references/<family>/<file>.md` resolves to `~/.config/nvim/utils/agents/skills/references/<family>/<file>.md`, and `./references/<file>.md` resolves to `~/.config/nvim/utils/agents/skills/<skill>/references/<file>.md`.

`mcp__hyprpilot-skills__list_skill_references { slug }` returns a skill's reference manifest without its body, and `read_skill_references { references: [path] }` returns the bodies for the canonical paths you name. Each file arrives under a `reference:` block naming it and its declared path; see `config-references` for the shape.

### Naming another skill — one line, and never its contents

A body needing **another skill** says so in one sentence carrying the load and the trigger. Nothing else.

```markdown
Load `agent-harness` to resolve tiers to concrete models.
Load `linear-structure-agent` before implementation.
```

- **Say "Load `X`".** A skill is not bundled the way a reference is; only an explicit instruction gets it loaded.
- **Name the trigger** — "before the first write", "when the request names a Linear id". A load with no trigger fires always or never.
- **Add at most ONE short clause**, and only for a deviation this run needs the reader to know. Never a second sentence.
- **Put it where the need arises** — at the top when it gates the whole skill, in the step when it gates one action.
- **Name it once per file.** A second mention of the same skill is drift waiting to happen.

**Never restate what the skill contains.** It is about to be loaded and will say so itself, at length, in its own words. A call site that summarises the skill doubles the tokens, and the summary rots the moment the skill changes while the reader has no way to tell which is current.

```markdown
Load `linear-structure-agent` before implementation — picking up is one of its two modes.
```

Not:

```markdown
Load the `linear-structure-agent` skill before implementation starts, whether or not this tree
was shaped with it — picking up is one of its two modes, and it owns what stays true throughout:
the executable unit is one repo, one PR, one concern, a parent holds the description while
sub-issues hold deviations, ownership is blessed once, and findings get recorded as they surface.
```

The second is 500 characters restating the skill's own opening. Every one of those clauses is in the skill.

### Posture — inherited, stated only on deviation

**Do not write a posture directive.** The default is `AGENTS.md` §II: investigate, present before writing, act immediately once cleared. Every skill inherits it, so restating it in 99 skills spends tokens telling the agent what it already knows.

State a posture **only when the skill deviates**:

- **Strict plan mode** — declare the `plan-mode` reference and say so in one line. Only for skills that plan or analyze and write nothing outside the internal plans directory.
- **A skill-specific carve-out** — a standing pre-approval, a read-only exemption, a security note about what a spawn runs as. One inline line, in the step it applies to.

Never tell a skill not to enter plan mode. Only skills declaring `plan-mode` enter it; warning the other 100 against a mode they cannot enter is anti-guidance.

### When to Create a New Shared Reference

**References share content across skills — they do not shrink one.** Bodies are pull-on-demand and cost nothing until routed to, so a long body is not a problem to solve. Extraction moves tokens; it does not remove them.

Extract when **two or more skills must stay in lockstep** on a convention or policy — the value is that a fix lands once instead of drifting into divergent copies. Then pick the tier: **declared** if every consumer uses it on every run, **path-read** if any consumer uses it conditionally.

Do NOT extract:

- Content a **composed skill already declares**, when it only matters on that composition's branch — the skill brings its own references, so declaring them again taxes every run. Keep anything your own steps need regardless; `output-diff` and `present-first` govern your writes, not the composed skill's.
- Content with a single consumer — put it in `<skill>/references/` if it is genuinely bulky, otherwise inline. A single-consumer file in the shared directory is mislabelled.
- Skill-specific workflow steps, descriptions, or examples — unique per skill.
- Short inline rules that would lose their context when separated.
- Anything extracted purely to make a SKILL.md shorter.

### Provider-Specific Behavior — generic body, per-harness reference

A skill is authored once and runs under whichever agent runtime is active. Keep that split explicit:

- **The SKILL.md body stays runtime-agnostic.** Describe the *intent* — "dispatch a subagent", "run it detached", "write the plan to the internal plans directory" — and never name one runtime's tool, parameter, default, or filesystem path.
- **Runtime mechanics live in a per-harness REFERENCE**, named **`<consumer>-harness-<provider>.md`** — one per (runtime × consumer). That is where the concrete tool name, its parameters, its defaults, and the collection semantics belong. Cross-cutting paths stay in `provider-paths.md`.

```
agent-delegate-harness-claude      # dispatch mechanics + tier to model, Claude Code
agent-delegate-harness-opencode
agent-delegate-harness-codex
agent-background-harness-claude    # waiting and waking mechanics, Claude Code
agent-background-harness-opencode
agent-background-harness-codex
```

Rules for this family:

1. **`<consumer>` is the exact name of the thing it configures** — the skill (`agent-background`) or shared reference (`agent-delegate`) whose mechanics it carries. The name says what it configures without opening it.
2. **They are references, and the consuming skill declares EVERY provider in the family.** Reference bodies are fetched on demand, so declaring all three costs three manifest rows and fetches one body — the conditional-family pattern in `hyprpilot-skills`. A reference beats a skill here because the manifest hands the reader the path, making the fetch mechanical; loading a skill is a choice that can be forgotten.
3. **The directive names the family with the placeholder:** *"Fetch `agent-background-harness-<provider>` before arming anything."* `<provider>` resolves at runtime. Never name a single runtime's file in a runtime-agnostic body.
4. **Split by consumer, not by topic size.** A consumer should fetch the mechanics it needs and nothing else.
5. **Add a new provider only when its behavior is known.** An empty or guessed harness skill is worse than none; mark anything unconfirmed as **unverified** in place.
6. **Version-mark behavioral claims.** Runtime behavior changes between releases; a claim without a version marker rots invisibly.
- **A skill that spawns subagents MUST send the reader to the active provider's reference BEFORE the first dispatch**, as a hard directive rather than optional background. Write the directive so it cannot be read as "nice to have".

> **The expensive failure mode is result COLLECTION, not dispatch.** Whether detached is the default, and above all **how a finished agent's output actually reaches the caller**, vary per runtime and change between versions. One runtime wakes the caller with a completion notification; another never wakes it at all, so detached work finishes into silence. An author who omits the collection guidance produces a skill whose users either discard finished work and re-run it, or wait forever for a wake that was never coming. Any skill that dispatches subagents must therefore cover: how a finished agent's output reaches the caller on the active runtime, how to resume or poll it, and **diagnose the cause before re-dispatching** (blind re-dispatch is what throws work away, not re-dispatch itself).

Checklist for any skill that dispatches subagents:

1. The body names no runtime-specific tool, parameter, or default value.
2. A directive points at `agent-delegate-harness-<provider>` **before** the first dispatch step.
3. Blocking vs detached is expressed as intent; the provider reference owns the flag and its default.
4. Result collection is covered explicitly, including diagnose-before-re-dispatch.
5. If it isolates writes, it points at `agent-worktrees` — including that isolation follows the **session's** repo, not the task's, which breaks cross-repo dispatch.
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

**This is a map, not an inventory.** The live list is the directory — run `ls ~/.config/nvim/utils/agents/skills/references/` before proposing a new reference or claiming one does not exist. A hand-maintained file list here rots the moment anyone adds a file.

| Family | Prefix | Covers |
|--------|--------|--------|
| Linear | `linear-*` | Prerequisite/workspace detection, mandatory fields, description structure, issue philosophy, states and transitions, pickup execution, documents, chunking, approval gates, SCM discovery, research. |
| SCM | `scm-*` | Platform detection, GitHub/GitLab tool sets, and the shared PR/MR workflows — review, fix-threads, read-summary, create-description, comment-poster, ci-fix. |
| Agents | `agent-*`, `agent-*` | Dispatch posture, worktrees, plan splitting, plan quality, project conventions, merge/review, completion handoff, watchers, target capability. |
| Per-harness | `<consumer>-harness-<provider>` | Runtime mechanics for one consuming skill; every provider declared, one fetched. See Provider-Specific Behavior. |
| Cross-harness | `harness-<topic>` | One policy across all runtimes plus a per-runtime inventory (`harness-connectors`). |
| Git | `commit-*`, `release-convention` | Commit message style, trailers, release-automation detection. |
| Posture | `plan-mode`, `mode-toggle` | Strict planning posture; voice-mode on/off mechanics. Everything else inherits the default. |
| Authoring policy | `output-diff`, `redact-private-data`, `commit-push-scoped`, `review-findings` | How authored output is presented, redacted, and committed. |
| Service | `obsidian`, `slack*`, `enrich-context`, `excalidraw-*`, `spacelift-github`, `tmux` | Per-service tool sets and conventions. |
| Runtime paths | `provider-paths` | Plans / state / worktree directories per runtime. Never hardcode these in a body. |

Two carry a hard rule worth knowing without opening the file:

- `agent-delegate` points at the per-provider reference for dispatch mechanics — a skill that spawns subagents must send the reader there **before** the first dispatch.
- `agent-worktrees` covers the trap that isolation follows the **session's** repo, not the task's, which breaks cross-repo dispatch.

## Description Checklist

Run this when creating, updating, or reviewing any description. **One shape, every skill:**

```
<slug> <what it does>. Use on "<phrase>", "<phrase>". Not for <situation>.
```

1. **Start with the slug.** Claude Code truncates long descriptions, so leading with the slug keeps the skill identifiable when the tail is cut. Not redundancy — a truncation defence.
2. **Then what it does**, in one clause. Plain prose, no headers, no YAML block scalars.
3. **Then `Use on` / `Use when`** with phrases a user would actually type, or the situation that should trigger it. Auto-invoked skills lead with the condition instead: *"Auto-invoked on X context - ..."*.
4. **Then `Not for <situation>`** — **describe the situation, never name the sibling skill.** A hardcoded slug goes stale the moment anything is renamed, and it forces every rename into a catalog-wide sweep. "Not for a read-only refresh" routes as well as "(use /linear-issue-read)" and survives the rename.
5. **Say it once.** Do not restate the tier — `disableModelInvocation` already carries "manually invoked", and repeating it in prose costs the whole catalog.
6. **Keep it short.** `list_skills` returns every description in one payload, so each is paid for by the whole catalog and an over-long one risks truncation eating its own triggers. Roughly 380 characters is the ceiling.
7. **No `<` or `>`** anywhere in the description.

## Conventions

- **Directory name** must match the `name` field in frontmatter, both in kebab-case.
- **Description** must follow the description checklist above.
- **Posture** — inherited by default; declare `plan-mode` only for skills that write nothing outside the internal plans directory. See Posture above.
- **Invocation tier** — set `disableModelInvocation` deliberately per the Invocation Tiers section above: `true` for manual-only skills; omit it for model-invocable and auto-invoke skills.
- **MCP tools** — reference specific tool names (e.g., `github__*`) when the skill depends on them. Use the **`<server>__<tool>` short form** (e.g., `github__get_file_contents`, `git status`, `slack-kilic__slack_list_channels`) — see MCP Tool Name Convention below.
- **Describe the current state only**, per `current-state-only` — no deprecation notes, no compatibility shims, no history. Delete the old wording and state the new one.
- **Be concise** — skills are instructions for an agent, not documentation for humans. Keep it actionable.
- **State what to do.** Guidance lands as the positive instruction — name the target, the field, the flow. A prohibition earns its place when the user asked for one, or when the wrong move destroys work; otherwise it is an invented example the reader has to parse and discount. A reader told what a thing *is* deduces what it is not.
- **An output that hands the reader an address is a sentence, not a block.** When a skill's output gives someone something to act on — a file to load, a skill to invoke, a command to run — specify it as one plain-English instruction naming the skill, the file, and what to do with it: *"Use the `plan-pickup` skill to read the file at `<path>` and go through the instructions."* A bare path, a labelled key-value block, or a terse command fragment leaves the reader to assemble the instruction themselves. A multi-field status readout or a menu of choices is a different thing and keeps its layout.
- **End list items with `.`** — consistent punctuation across all skills.
- **No emoji, in the skill or in what it tells the agent to write** — the absolute rule lives in the central `AGENTS.md`. Markers are words and bold (**ABSOLUTE**, **NEVER**, **Warning:**), never a pictograph. The only glyph that stays is one a file format or API requires as literal data.
- **Examples** — workflow skills that orchestrate multi-step processes should include at least one example showing trigger → actions → result.
- **Compose over duplicate** — when another skill or reference already does something, name it (compose with the skill "as defined in `load-skills`", or name the reference inline) rather than hardcoding a copy of its logic.
- **SKILL.md size** — no hard line limit. Some scaffolding skills (e.g. `cluster-*`, `argocd-*`) are legitimately long, and that is fine. Do NOT split a skill into references just to shrink it — references exist only to share content across skills (see References).

## MCP Tool Name Convention

**ABSOLUTE — the harness-provided integration outranks any server a skill names.** When the running harness supplies an integration for a service (on Claude Code, a `mcp__claude_ai_<Connector>__*` connector), it is used for that service and the standalone MCP server is not. A server name in a skill body identifies *which service and workspace*, never *which transport wins* — see the `harness-connectors` reference. When authoring: name the server for identification, and for any service with a harness connector, add a directive pointing at that reference rather than implying the standalone server is the default. Falling back to the standalone server is allowed only when the harness offers nothing for that service or lacks a needed capability, and it is stated out loud.

In skill files, reference files, and documentation, use the **`<server>__<tool>` short form** — the server name is the identifying factor. The harness/client may surface the tool under a longer prefix (`mcp__<server>__<tool>`, `mcp__<hub>__<server>__<tool>`, etc.); the agent resolves whatever prefix the runtime uses at call time. Documentation should NOT bake in a specific prefix.

**Server name rules** — catalog server keys (the ones `config-mcp` writes) MUST use kebab-case with `-` separators only. Never use `/` in a server key (does not parse correctly through some MCP hubs) and avoid `_` for word separation inside it. Workspace-suffixed servers follow the `<service>-<workspace>` pattern, e.g., `linear-kilic`, `linear-laravel`, `grafana-kilic`, `grafana-laravel`, `argocd-kilic`, `slack-kilic`, `spacelift-laravel`.

**Hyprpilot's injected servers are not catalog entries but follow the same rule.** `hyprpilot`, `hyprpilot-skills`, `hyprpilot-nvim` and `hyprpilot-harness` are kebab, so each is spelled exactly like its same-named skill.

Examples:

- `github__get_file_contents` (server: `github`, tool: `get_file_contents`)
- `gitlab__get_merge_request` (server: `gitlab`, tool: `get_merge_request`)
- `sourcebot-kilic__grep` (server: `sourcebot-kilic`, tool: `grep`)
- `slack-kilic__slack_list_channels` (server: `slack-kilic`, tool: `slack_list_channels` — the Laravel workspace is connector-only, see `harness-connectors`)
- `linear-kilic__get_issue` (server: `linear-kilic`, tool: `get_issue`)
- `grafana-kilic__query_prometheus` (server: `grafana-kilic`, tool: `query_prometheus`)
- `obsidian__vault_read` (server: `obsidian`, tool: `vault_read`)

**Write steps only against tools a server actually registers.** Several expose less than their vendor documents — a read-only flag, disabled write tools, a capability the catalog entry withholds. Load that server's same-named skill before writing steps against it. A step routed through a tool the server does not register cannot execute, and nothing catches that at authoring time: it reads as a perfectly ordinary instruction and fails only when someone runs it.

Where no server covers the job, name the CLI instead — local git is always raw `git` via `Bash`, so a `git__*` tool never appears in a skill. And when a server carries its own conventions, declare its reference or name its skill rather than restating them.

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
4. Propose replacing them with inline mentions plus `references` frontmatter declarations.
5. Present changes, iterate on feedback.
6. After approval, update the skill.

**Result:** Duplicated blocks replaced by inline reference mentions, frontmatter updated.
