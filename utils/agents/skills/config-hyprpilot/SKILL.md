---
name: config-hyprpilot
description: config-hyprpilot Edit or review the hyprpilot launcher config - profiles, agents, patches, and the in-tree MCP/skills block - deriving the schema from hyprpilot's own source. Use on "add a profile", "change the default model", "why did that profile resolve that way", "which skills does this profile see". Not for the MCP server catalog, skill files, agent guidelines, or repo knowledge bases.
disableModelInvocation: true
references:
  - ../references/current-state-only.md
  - ../references/present-first.md
  - ../references/config-targets.md
  - ../references/output-diff.md
  - ../references/redact-private-data.md
  - ../references/scm/commit-push-scoped.md
argumentHint: '[what to change or review]'
---

## Hyprpilot Launcher Config

Posture: `present-first`.

**Target: `~/.dotfiles/hyprpilot/.config/hyprpilot/config.yaml`** — the launcher config. It is stowed,
so `~/.config/hyprpilot/config.yaml` is a symlink to it; edit the dotfiles path, which is the one git
tracks.

> **ABSOLUTE — discover the target before drafting, per `config-targets`.** This file is the procedure; the target is the launcher config. Editing this file needs the captain naming it **and** blessing the change — except for the schema carve-out below, where drift against the installed binary is repaired in place.

## What This Config Is

One layered file decides what a `hyprpilot <profile>` launch becomes: which vendor CLI is `exec()`d,
with which model and mode, carrying which system prompt, which MCP servers, and which skills.

Layers merge in order — compiled defaults, the global config, an optional named config-layer profile,
then `patches` and `--with-config`. A launch picks one base profile, folds every matching patch in
declaration order, re-validates, projects the result onto the vendor's native flags, and `exec()`s.

Three consequences drive most edits:

- **Patches fold over profile bodies**, so a patch beats the profile it lands on. Anything that must
  win against an unscoped patch has to be a later patch.
- **`patches` accumulates across layers** while other sections overwrite, so an earlier layer's patch
  is overridden rather than removed.
- **Config is read once per launch.** There is no daemon and no reload; an edit reaches the next
  launch, and running sessions keep what they started with.

This skill owns the wiring. What sits at the other end of each wire belongs elsewhere: `config-agents`
for the injected `AGENTS.md`, `config-skills` for the skill bundles, `config-mcp` for the MCP catalog.

## Deriving the Schema From Source

**The Rust source is the schema. Read it before answering a question about a field.** Upstream is
`github.com/hyprpilot/hyprpilot`, cloned locally at `~/development/hyprpilot`. The published docs
under `docs/config/` are a secondary read — useful for narrative, behind the code for detail.

**First, reconcile versions.** `hyprpilot --version` is what is actually running; the local clone is a
working tree that may sit on a feature branch, ahead or behind it. Check `git log` / `git describe` in
the clone and compare. When they disagree, `git fetch` and read at the tag matching the installed
binary rather than at whatever is checked out — a struct read from the wrong ref documents a field the
running binary rejects.

**The module map.** `src/config/mod.rs` holds the root `Config` struct, and its fields *are* the root
sections. Each section's shape lives in its own file:

| Read | For |
|---|---|
| `src/config/mod.rs` | root sections, layer loading, format discovery |
| `src/config/agents.rs` | agent, profile, and profile-harness shapes; the provider enum |
| `src/config/mcp.rs` | the in-tree server blocks and their defaults |
| `src/config/extensions.rs` | MCP catalog entries and skill-dir entries |
| `src/config/system_prompt.rs` | system-prompt entries |
| `src/config/patch.rs` | `$match` filtering and every merge directive |
| `src/config/merge_strategies.rs` | how each field behaves across layers |
| `src/config/validations.rs` | the cross-field rules that reject a config |
| `src/config/defaults.toml` | what the compiled defaults seed |
| `src/paths.rs` | config discovery and path/env expansion |

**Reading a struct.** The derive attributes carry the answers, and the field doc comments are the real
documentation — richer and more current than the published page:

- `#[serde(rename_all = "camelCase")]` on the struct means the on-disk keys are camelCase
  (`autoAcceptTools`, `includeProfiles`) even though the Rust fields are snake_case. A struct without
  it uses the field names verbatim (`system_prompt`, `set_title`). This is the single most common
  source of a key that "should work" and does not.
- `#[serde(deny_unknown_fields)]` marks a closed shape — a typo is a load error naming the field path.
- `#[serde(alias = "…")]` is a second accepted spelling for the same key.
- `Option<T>` is genuinely unset; `#[serde(default)]` on a concrete type means a value is always
  present. The effective default often lives in an `impl Default` or an accessor method
  (`is_enabled()`, `server_name()`) rather than in `defaults.toml`.
- `#[merge(strategy = …)]` names the cross-layer behaviour — overwrite, merge-by-id, or append.
- `#[garde(custom(…))]` points at the function in `validations.rs` that is the actual rule.

**Then confirm against the binary.** `hyprpilot --help`, `hyprpilot mcp --help`, and a launch with
`--log-level debug` settle anything the source leaves ambiguous. Logging covers the resolve phase and
stops at `exec()`; everything after belongs to the vendor.

## Process

### Change

1. Read the config, and read the source for any field whose behaviour the edit depends on.
2. Locate the layer. A knob for one profile goes on the profile; a knob shared by a family goes in a
   `$match`ed patch; a knob that must beat an unscoped patch has to be a later patch.
3. Walk the fold order and name which patch wins each field being set.
4. Present the edit per `output-diff`, stating the resolution consequence: which profiles change, and
   what they will resolve to. Keep real hostnames, tokens and account ids out of the config and its
   examples per `redact-private-data`.
5. Apply to the dotfiles path.
6. Verify. `hyprpilot profiles` loads and validates the whole config, so a clean listing proves the
   edit parses and every cross-reference resolves; `--json` gives the machine-readable form and
   `--log-level debug` prints the resolve narrative. Report what it actually said.
7. Say the change lands on the next launch.

### Review

1. Read the config; reconcile the clone against `hyprpilot --version`.
2. Walk each patch, name the profiles its `$match` glob reaches, and what it overrides on them.
3. Flag what the resolution pipeline makes inert or contradictory — a profile field an unscoped patch
   overrides, a harness opt-in with no matching launcher glob, an `ignore` pattern matching nothing, a
   commented-out entry whose condition has since fired.
4. Confirm with `hyprpilot profiles`, then present findings and propose changes.

## Keeping This Skill Current

**Schema drift is this skill's own target — fix it here, in the same run.** This is the carve-out in
`config-targets`: the claims above describe an external binary, so correcting them is a factual repair
rather than a lesson recorded in the wrong file.

- **Correct only what was verified against source at the installed version**, and say which sections
  were re-checked.
- **Rewrite rather than annotate**, per `current-state-only`.
- A gap in this skill's *procedure* is the ordinary case and gets proposed.

## Committing

Two repositories can be in play; they are separate commits.

| What changed | Repo | Branch | Scope |
|---|---|---|---|
| the config file | `~/.dotfiles` | `master` | `hyprpilot` |
| this skill file | `~/.config/nvim` | `rolling` | `agents` |

Per `commit-push-scoped`: stage only the touched paths, then compose with `git-commit` and
`git-push`. Both branches are protected, so `git-push` stops for an ack — the captain's push blessing
is that ack. Ask once before committing unless the request already blessed the push.

## Key Principles

- **The source answers, the binary referees.** Read the struct; when the struct and the running binary
  disagree, believe the binary and fix the digest here.
- **Reason through the pipeline, not from a single line.** A field's value in the file is not its value
  at launch — a patch may already be overriding it.
- **Validation is cheap proof.** Closed shapes and cross-field checks mean a bad edit fails loudly at
  load, so `hyprpilot profiles` after every change is worth running.
- **Relaunch to reconfigure.** No daemon, no reload.
