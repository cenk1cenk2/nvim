---
name: config-skills
description: config-skills Create, update, or review skills in the skills directory. Use on "create a skill", "update this skill", "add a slash command", "improve this skill". Not for the shared reference files, and not for resolving which skill to load.
disableModelInvocation: true
scripts:
  # Relative to this skill's own directory: resolve against the `bundleDir` the
  # skill metadata carries, never a hardcoded absolute path, because the tree
  # sits at a different root on every runtime that serves this catalog.
  - ./scripts/check_catalog.py
references:
  - ../references/current-state-only.md
  - ../references/present-first.md
  - ../references/config-targets.md
  - ../references/output-diff.md
  - ../references/redact-private-data.md
  - ../references/scm/commit-push-scoped.md
  - ../references/mcp-tool-naming.md
  - ../references/harness/harness-connectors.md
argumentHint: '[create|update|review] [skill-name] [what it should do]'
---

## Skill Management

Posture: `present-first`.
Present proposed changes per `output-diff` before writing. Keep real private specifics out of skills, references, and examples per `redact-private-data`. Once edits land, commit and push per `commit-push-scoped` — scope `agents`, branch `rolling`.

Target discovery and the self-edit gate per `config-targets`.

## Skills Directory

All skills live in `~/.config/nvim/utils/agents/skills/`. Each skill is a directory containing a `SKILL.md` file. Shared reference files live in `references/` at the skills root; its folders and naming are `config-references`'s.

```
~/.config/nvim/utils/agents/skills/
├── references/           # Shared references: family folders plus cross-cutting files at the root
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
3. **Check references** — list `~/.config/nvim/utils/agents/skills/references/` and its family folders, and read the ones that apply. If the skill belongs to a family (e.g., Linear, Obsidian), check whether sibling skills declare references in their frontmatter and reuse the same ones.
4. Draft the full `SKILL.md`. Name any shared convention inline where the body uses it, and declare it in `references:`.
5. **Validate** — run the description checklist (see below), verify conventions, and run the `current-state-only` check: no compatibility notes, no history, nothing describing a past shape.
6. Present the draft in chat.
7. Iterate based on user feedback.
8. After approval, create the directory and write the file.
9. Confirm it landed, per the guidance below.

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
10. Confirm it landed, per the guidance below.

### Review

1. Read the existing `SKILL.md` for the target skill.
2. **Validate** — run the description checklist (see below), check all conventions, and run the `current-state-only` check for compat notes or history that crept in.
3. **Audit references** — check whether the skill duplicates content a shared reference already carries, and whether every declaration is still accurate, still used by the body, and correctly tiered (declared vs path-read).
4. List ambiguities, inconsistencies, or areas that could be improved.
5. Ask clarifying questions to understand user intent.
6. Propose specific improvements based on answers.
7. After approval, apply the changes (or leave as-is if no changes needed).
8. If files changed, confirm they landed, per the guidance below.

## Confirming an Edit Landed

The skills sidecar watches every root, so a written file is rescanned and announced on its own. What still needs doing is confirming it landed and re-reading what you already hold — the rescan fixes the catalog, never your context.

1. Re-read the skill you just wrote with `hyprpilot-skills__read_skill { slug }` and treat the returned body as authoritative. Any copy you were holding from before the edit is void.
2. If references changed, use `hyprpilot-skills__list_skill_references { slug }` on an affected skill to confirm every declared path resolved into the manifest — a typo drops the row silently.
3. Report what you re-read, and anything that failed to resolve.

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

Hyprpilot hands the frontmatter to the agent verbatim — as `metadata` in `list_skills` / `read_skill` output, and as the `io.hyprpilot/skill` key in resource `_meta` — minus `title` and `description` (they ride as the spec `Resource.title` / `Resource.description` fields) and `references` (superseded by the manifest).

What hyprpilot itself *acts on* is small:

| Key | What hyprpilot does with it |
|-----|------------------------------|
| `description` | Becomes `Resource.description`. Falls back to `Guidance for <slug>` when absent — always write one anyway. |
| `title` | Becomes `Resource.title`. Optional; the slug stands in when absent. |
| `references` | Resolved relative to the skill's own `bundleDir` into manifest rows carrying each file's canonical path; bodies fetched by path with `read_skill_references`. |
| `name` | Passed through only — the **directory name is the slug**. A mismatch changes nothing at runtime, so keep them equal for the reader. |

Everything else — `disableModelInvocation`, `argumentHint`, and any key you invent — is **passed through untouched**. Hyprpilot enforces none of it; those are conventions the agent reads out of the metadata block, and the central `AGENTS.md` is what turns `disableModelInvocation` into an actual invocation rule. A stray Claude Code key (`when_to_use`, `allowed-tools`, `model`, `hooks`, …) therefore does not error — it just reaches the agent as noise. Do not add them.

**Body structure:** the body starts directly with top-level `##` sections — there is **no `## system` wrapper**.

```markdown
The body opens with content, not ceremony. No posture directive unless the skill deviates (see Posture below); no directive block for declared references — name them inline where used.

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
| **Model-invocable** | omit (default `false`) | The model MAY invoke it when the user's intent clearly matches, as a step within a flow. | Lead with the action, then `Use on` / `Use when`. |
| **Auto-invoke** *(a Model-invocable sub-case)* | omit (default `false`) | Same runtime state as Model-invocable, but meant to fire the moment its context is detected without the user naming it. No separate flag — the intent is carried by the description wording. | Lead with "Auto-invoked on … context". |

Assignment guidance:

- **Manual** — reviews, reads, fixes, CI, scaffolding, config-authoring (`config-*`), personality modes and postures (`caveman`, `agent-bulldozer`, `agent-coordinator`, `agent-supervisor`), companions, plan handoff/pickup, and any heavy or destructive orchestration the user should trigger deliberately (`git-split`, `agent-labrat`, `hyprpilot-delegate`).
- **Model-invocable** — routine actions the agent legitimately reaches for mid-task: git basics (`git-commit`, `git-branch`, `git-push`), PR/MR creation, most Linear operations, `plan-hard`, `code-improve`, and in-harness dispatch (`agent-delegate`, `agent-plan`, `agent-background`, `agent-review`).
- **Auto-invoke** — session and workspace initializers only (`hyprpilot-skills`, `hyprpilot-nvim`, `linear-kilic`, `linear-laravel`, `slack-kilic`, `slack-laravel`, `spacelift-laravel`, `notion-laravel`).
- **Proactive-suggest overlay** — a Manual skill whose body tells the assistant to *recommend* itself on a trigger (rule drift, user deviations) but never self-invoke (`config-agents`, `obsidian-repository`). `config-repository` is the one skill kept Model-invocable with an explicit `disableModelInvocation: false` because autopilot may auto-apply it.

Note: omitting the flag and writing `disableModelInvocation: false` are behaviorally identical (default is `false`). Write it explicitly only when the autoload intent is the skill's defining feature and you want it legible in source (e.g. `config-repository`).

## References

### Declared by Default

**A `references:` array is a manifest, not a payload.** `read_skill` hands the reader one row per declaration and the bodies are fetched by path on demand — mechanics per the `hyprpilot-skills` skill, cost model and file layout per `config-references`. Declaring is close to free; a large multi-topic reference is the expensive mistake.

| Tier | Mechanism | Use when |
|------|-----------|----------|
| **Declared** | listed in `references:`; appears in the manifest, body fetched on demand | almost always — the body cites it, on any run, including conditionally |
| **Path-read** | named in the body **with its absolute path** | the reader holds no manifest carrying it — `AGENTS.md`, or a file deliberately declared by no skill, which `read_skill_references` refuses |

### A reference name only resolves through a manifest

`read_skill_references` accepts a path, and only a path some manifest published. So a reference name is not a portable address: naming `commit-style` in a body whose skill does not declare it hands the reader a name with nothing to fetch it by.

That decides how a body reaches a convention another skill owns — **route to the skill, not to the reference**:

- **Your own steps need it** — declare it. The row is yours, the path arrives with your skill.
- **A composed skill's steps need it** — write **Load `X`** and let X's manifest carry it. Do not name X's reference directly; the reader cannot address it until X is loaded.

The escape hatch is `Read` on the absolute path, which always works — and is why a path-read directive carries the path in full. A name alone is not enough.

**A path-read directive MUST carry the absolute path.** A missed `Read` raises no error — the skill simply runs without the convention it named, silently.

### Writing Reference Directives — name it inline, do not announce it

The manifest already hands the reader the reference's path, so an instruction to go read it is a no-op that costs tokens to state. So name the reference where the body uses it, in the sentence that uses it:

```markdown
Present proposed changes per `output-diff`.
Fields and their defaults: `linear-mandatory-fields`.
Write the plan to the internal plans directory per `provider-paths`.
```

Not this:

```markdown
> Read the `output-diff` reference for chunked change presentation — show reasoning +
> content blocks for each proposed change before asking for approval.
```

Rules:

- **Name the reference, never the act of reading it.** "per `X`", "via `X`", "fields per `X`".
- **Fold in *when* it applies, when that is not obvious** — ``Before the first dispatch, mechanics per `agent-delegate`.`` At most ONE further clause, and only for a deviation this run needs. Name it once per file.
- **No inline summary for a declared reference.** Its path is in the manifest, so a summary is the same content paid for twice.
- **A real directive block is for path-read references only**, and it carries the absolute path plus a one-line summary — there, the read genuinely may not happen.
- **Reserve a bold ABSOLUTE marker and blockquote weight for traps** — a rule whose violation destroys work. Routine composition gets a clause, not a banner.
- **Never name the fetching tool.** The agent resolves that itself.

### Path Convention

Declared paths are relative to the skill's own directory — `../references/<family>/<file>.md`, `../references/<file>.md`, or `./references/<file>.md` for a single-consumer file. Folders and file naming: `config-references`.

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

**Do not write a posture directive.** The default is `AGENTS.md` §III: investigate, present before writing, act immediately once cleared. Every skill inherits it, so restating it spends tokens telling the agent what it already knows.

State a posture **only when the skill deviates**:

- **Strict plan mode** — declare the `plan-mode` reference and say so in one line. Only for skills that plan or analyze and write nothing outside the internal plans directory.
- **A skill-specific carve-out** — a standing pre-approval, a read-only exemption, a security note about what a spawn runs as. One inline line, in the step it applies to.

Never tell a skill not to enter plan mode. Only skills declaring `plan-mode` enter it; warning every other skill against a mode it cannot enter is anti-guidance.

### When to Create a New Shared Reference

Extract only when **two or more skills must stay in lockstep** on a convention — never to shrink one SKILL.md, and never for what a composed skill already declares. The full test and the do-not-extract list: `config-references`.

### Provider-Specific Behavior — generic body, per-harness reference

A skill is authored once and runs under whichever agent runtime is active. Keep that split explicit:

- **The SKILL.md body stays runtime-agnostic.** Describe the *intent* — "dispatch a subagent", "run it detached", "write the plan to the internal plans directory" — and never name one runtime's tool, parameter, default, or filesystem path.
- **Runtime mechanics live in a per-harness REFERENCE**, `<consumer>-harness-<provider>`, one per (runtime × consumer), every provider declared by the consumer. Naming, declaration and version-marking rules: `config-references`. Cross-cutting paths stay in `provider-paths`.
- **The directive names the family with the placeholder:** *"Fetch `agent-background-harness-<provider>` before arming anything."* Never name a single runtime's file in a runtime-agnostic body.
- **A skill that spawns subagents MUST send the reader to the active provider's reference BEFORE the first dispatch**, as a hard directive rather than optional background.

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

1. **Read existing references** — list `~/.config/nvim/utils/agents/skills/references/` and its family folders, and read the relevant ones.
2. **Compare against the skill** — identify any blocks in the skill that overlap with existing references.
3. **Check sibling skills** — read 2-3 skills in the same family and look for blocks duplicated across them.
4. **Propose extraction** — if a duplicated block has no matching reference, propose creating one, named per `config-references` (e.g. `linear/linear-prerequisite.md`).
5. **Present findings** — show the user which blocks can be replaced with references and which new references should be created.

## Scripts

A skill may ship executable code beside its body. Reach for one when a step is **mechanical and its failure is silent** — a check whose result an agent cannot see it got wrong. Prose is right for judgement; a script is right for a contract.

`agent-background/scripts/watch.py` (poll one condition, exit when it holds) and `hyprpilot-delegate/scripts/hyprpilot-harness.py` (the whole life of a delegated session) are the shape to copy; `ls ~/.config/nvim/utils/agents/skills/*/scripts` is the live list.

### A script needs a skill

**A reference cannot host one.** References are files a skill declares; nothing makes them addressable on their own. A convention that earns a script either moves into a skill, or the script lands in the skill that already owns the subject and the reference points at it. Prefer the second — promoting a reference means editing every skill that declares it, and the popular ones have dozens.

### Declare it, never hardcode its path

```yaml
scripts:
  - ./scripts/check_catalog.py
```

The path is **relative to the skill's own directory**, and a caller resolves it against the `bundleDir` in the skill's metadata. Never write an absolute path into a body: this catalog sits at a different root on every runtime that serves it, and a hardcoded path is a pointer that resolves to nothing on the others. Unknown frontmatter keys ride through to metadata verbatim, so `scripts` reaches a reader without the loader knowing about it.

### Layout

Each skill's `scripts/` is its own uv project:

```
<skill>/scripts/
  pyproject.toml        deps, pytest and ruff config
  <entry>.py            the entry point, uv shebang
  tests/                pytest, not a shell harness
```

The shebang makes the script runnable by path with no wrapper, which is what a background launcher needs:

```sh
#!/usr/bin/env -S sh -c 'exec uv run --project "$(dirname "$0")" "$0" "$@"'
```

**And the shebang only fires when the script is launched by its own path.** A consuming body therefore instructs executing the path, resolved from the owning skill's `bundleDir` — never `python3 <path>`, which bypasses the uv project beside the script and dies on the first third-party import (`ModuleNotFoundError`) at exit 1, colliding with the ceiling code below.

Shared scaffolding lives in `skills/lib/` as the `agentlib` package, consumed as an editable path dependency (`agentlib = { path = "../../lib", editable = true }`). It carries `ScriptError`, `ExitCode`, the rich logger and the pydantic validators, so two scripts do not each grow their own.

Use real libraries rather than hand-rolling: `click` for the CLI, `pydantic` for validation, `rich` for logging, `httpx` for HTTP — bare `urllib` gets bounced by edge proxies — and `jsonpath-ng` where a caller needs to narrow JSON.

### Exit codes are the contract

A script launched detached has no reader; **its exit code is its message**. Fix the meanings and never reuse a number:

| Code | Means |
|---|---|
| 0 | the thing held |
| 1 | a bounded ceiling was reached — not a failure |
| 2 | usage error, nothing was attempted |
| 3 | the check cannot run; polling would never fix it |

Turning a usage error into exit 1 is the worst available bug: the caller reads it as a ceiling and waits.

**A code the table does not claim belongs to the launch shell, not the script.** Write the consuming steps so an unclaimed code is classified as a failed launch — the condition was never observed even once — and never as a result; the codes themselves are enumerated once, in `agent-background`. The check that catches a bad launch before it detaches into silence is one foreground run of the resolved path (`--help` exits 0) ahead of any launch that backgrounds it; a skill that ships a script states that pre-flight beside the launch step.

### stdout is the wake

An agent greps stdout for a result line, so **stdout stays plain and stable**. Rich, colour and progress belong on stderr. Verify it: run the script piped, not on a terminal, and confirm no escape sequences reach stdout.

### Refuse what would fire on the wrong thing

Validate before doing anything. A relative path resolves against whatever directory the launcher had; a glob matches a finished sibling and fires immediately. Both are refused at argument time, before anything is armed, so the refusal is visible rather than a watcher that quietly polls nothing.

### Test it, and wire it into the Taskfile

Tests are pytest, and they mostly shell out to the real entry point, because the contract being tested is exit codes and one-line messages. Add the project to `PYTHON_PROJECTS` in the repository `Taskfile.yml`; `task test:python` and `task lint:python` then cover it.

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
- **MCP tools** — name specific tools when the skill depends on them, per `mcp-tool-naming`. A server with a harness connector also gets its routing per `harness-connectors`.
- **Describe the current state only**, per `current-state-only` — no deprecation notes, no compatibility shims, no history. Delete the old wording and state the new one.
- **Be concise** — skills are instructions for an agent, not documentation for humans. Keep it actionable.
- **State what to do.** Guidance lands as the positive instruction — name the target, the field, the flow. A prohibition earns its place when the user asked for one, or when the wrong move destroys work; otherwise it is an invented example the reader has to parse and discount. A reader told what a thing *is* deduces what it is not.
- **An output that hands the reader an address is a sentence, not a block.** When a skill's output gives someone something to act on — a file to load, a skill to invoke, a command to run — specify it as one plain-English instruction naming the skill, the file, and what to do with it: *"Use the `plan-pickup` skill to read the file at `<path>` and go through the instructions."* A bare path, a labelled key-value block, or a terse command fragment leaves the reader to assemble the instruction themselves. A multi-field status readout or a menu of choices is a different thing and keeps its layout.
- **End list items with `.`** — consistent punctuation across all skills.
- **No emoji, in the skill or in what it tells the agent to write** — the absolute rule lives in the central `AGENTS.md`. Markers are words and bold (**ABSOLUTE**, **NEVER**, **Warning:**), never a pictograph. The only glyph that stays is one a file format or API requires as literal data.
- **Examples** — workflow skills that orchestrate multi-step processes should include at least one example showing trigger → actions → result.
- **Compose over duplicate** — when another skill or reference already does something, name it (Load the skill, or name the reference inline) rather than hardcoding a copy of its logic.
- **SKILL.md size** — no hard line limit. Some scaffolding skills (e.g. `cluster-*`, `argocd-*`) are legitimately long, and that is fine. Do NOT split a skill into references just to shrink it — references exist only to share content across skills (see References).

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
3. Check conventions — posture, punctuation, conciseness.
4. Audit references — check if duplicated blocks exist that should use shared references.
5. Present findings: "The `Not for` clause names a sibling slug instead of the situation".
6. Propose improvements, iterate.

**Result:** Skill updated with improved description and conventions.

---

**User says:** "Update the linear-project-create skill"

1. Read `linear-project-create/SKILL.md`.
2. Read shared references in `references/` to check for deduplication.
3. Identify the prerequisite block and research section as duplicates of existing references.
4. Propose replacing them with inline mentions plus `references` frontmatter declarations.
5. Present changes, iterate on feedback.
6. After approval, update the skill.

**Result:** Duplicated blocks replaced by inline reference mentions, frontmatter updated.
