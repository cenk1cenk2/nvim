# Agent Conventions — Match the House Style

**MANDATORY for every dispatch that writes code.** Not an optional enrichment step. Skip it only for genuinely read-only work (research, audits, reviews).

A subagent starts with a fresh context and no taste for this codebase. Left to itself it writes generically-correct code in its own dialect: different naming, its own vocabulary for concepts that already have names, explanatory comments nobody asked for, a second way to do something the codebase already does. It passes the tests and reads as foreign — and that *is* the defect, because the next person to touch it cannot tell what the codebase's pattern actually is.

## Two levels — do not confuse them

**Idiom always binds. Shape binds only when a precedent exists.**

| Level | What it covers | When it applies |
|-------|----------------|-----------------|
| **Idiom** | Naming and vocabulary, comment density, imports, formatting, error handling, logging, config, test style, where files live. | **Always** — new feature or not. There is no such thing as code too novel to be named and formatted like its codebase. |
| **Shape** | Decomposition, abstractions, interfaces, control flow, how the pieces fit together. | **Only when an analogous implementation exists** — migrating something, adding the Nth of a kind, redoing an existing thing in a different form. |

The acceptance test follows the same split: **the code must read as though this codebase's authors wrote it.** That is a claim about idiom, not about the design being derivative. A genuinely new feature is expected to look new — it is not expected to look foreign.

## When there is no precedent

Real for a genuinely new feature, a first-of-its-kind integration, or a new subsystem. Then:

- **Idiom still binds in full.** The authority order and every idiom line in the prompt block apply unchanged.
- **Design deliberately**, against the codebase's architectural grain — its layering, its boundaries, how it passes dependencies — rather than copying an unrelated file for the sake of copying. Forcing a mismatched pattern onto new work is its own failure mode.
- **Say so in the report:** what had no precedent, what you chose, and why. That is the sentence the reviewer needs. Inventing silently is what makes a diff unreviewable.
- **Do not invent a second way to do something the codebase already does.** No precedent for the *feature* rarely means no precedent for its parts — config loading, errors, tests, and wiring almost always have one.

## Authority order — a lower source never overrides a higher one

The ladder the prompt block's numbered list is filled from. Studying these is the agent's mandatory first action, and the prompt must say so.

1. **Examples the user pointed at.** A file, function, module, commit, or PR they named with "do it like this" outranks everything, including your own reading of the codebase and your judgement about what is better. If you believe it is wrong, say so in the report rather than quietly deviating.
2. **The nearest siblings** — the 2-3 files in the same directory or module, read end to end.
3. **The closest existing implementation of the same kind** — another handler, plugin module, migration, or test — used as the working template.
4. **The wider codebase**, for anything the local files do not settle.
5. **Language or framework defaults** — last resort, and only where the codebase is genuinely silent.

**Read the history of the code being touched**, not the repo's history in general: commits on the same path (`git log -p -- <path>`), and the commit or PR/MR that introduced the sibling being modelled on, which shows the whole shape of such a change including the tests and docs that came with it. Where the local area has no precedent, the commit that added the same kind of thing elsewhere serves. A commit that only renamed or reformatted teaches nothing.

Everything else the agent must follow — naming, shape, formatting, errors, imports, tests, architecture, comments, scope — is stated once, in the prompt block below. Fill it in rather than restating it here.

## What the dispatcher discovers first

Discover these from the code before dispatching (Sourcebot first when the pattern may span repos, then the target repo directly), and fold them into the prompt block below. Skip categories that do not apply.

- **Testing** — framework, style (table-driven / BDD), file naming, location, fixture and mock patterns.
- **Code style** — formatter in use (and whether the agent should run it or `hyprpilot_nvim__editor_format`), whitespace habits, naming per symbol kind, import grouping, error-handling idiom.
- **Project patterns** — architecture, where new code of this kind belongs, dependency injection, logging, configuration.
- **Git** — commit convention, branch naming.
- **Tooling** — linter and the rules that matter; the agent must not introduce violations.

Keep the result short. Only conventions that are non-obvious, or where the project deviates from language defaults, earn a line.

## Required prompt block

Every code-writing dispatch carries this, filled in:

```
## Conventions — match the house style

FIRST, before writing anything, read these and follow them — in this order of authority:
1. <files/functions the user explicitly pointed at — "do it like this">. These outrank your own judgement; if you think one is wrong, say so in the report, do not silently deviate.
2. <nearest sibling files>.
3. <closest existing implementation of the same kind>.
Then check how this kind of change was made around here: `git log -p -- <path>`, and the commit/PR that introduced the file you are modelling on — it shows the full shape, tests and all. Ignore unrelated commits (renames, formatting sweeps).
Extend the existing pattern rather than introducing a new one.

- Naming: <per-symbol-kind rules discovered above>. Reuse the codebase's existing vocabulary — no synonyms for concepts that already have a name.
- Shape: <analogous implementation, if one exists> — mirror its decomposition, inlining-versus-extracting habit, and signature style. If this work has no analogue, design it against the codebase's architecture and say in your report what you chose and why. Do not force an unrelated file's structure onto genuinely new work, and do not invent a second way to do something the codebase already does (config, errors, wiring, tests almost always have a precedent even when the feature does not).
- Formatting: <formatter + when to run it>. <whitespace habits>.
- Errors: <local idiom>.
- Imports: <grouping/ordering>.
- Tests: <framework, style, location>.
- Architecture: <where this kind of code belongs>.
- Comments: match the surrounding density — <none | why-only>. Never restate what the code does; a comment earns its place only by explaining a non-obvious why. No banners, no narration (`// Step 1: …`), no docstrings where the siblings carry none, no TODOs unless asked. Explanation goes in your report, not the code. If a TODO-family comment IS asked for, write `KEYWORD: @<handle> <message>` — e.g. `TODO: @cenk1cenk2 drop once the v2 endpoint ships` — with the handle read off that repository's git remote. Recognised keywords, and nothing else: `FIX` (`FIXME`, `BUG`, `FIXIT`, `ISSUE`), `TODO`, `HACK`, `WARN` (`WARNING`, `XXX`), `PERF` (`OPTIM`, `PERFORMANCE`, `OPTIMIZE`), `NOTE` (`INFO`).
- Scope: modify only <paths>. No refactors, renames, reformatting, or dependency changes outside the task. A convention you dislike is still the convention — flag it, don't fix it.

Before you report, self-check your diff against <reference file>: if it reads as though someone outside this codebase wrote it — different naming, unfamiliar vocabulary, comments the neighbours would not have, a foreign error or import style — fix it. New functionality is allowed to look new; it is not allowed to look foreign.
```

## On return — check the diff, not the summary

The agent's report describes intent. Read the actual diff and check:

1. Naming matches the examples, per symbol kind, reusing existing vocabulary — and matches any example the user pointed at above all.
1b. Where an analogous implementation exists, inlining/extraction and signature shape match it. Where none exists, the report says what was designed and why — silence here is the actual defect.
2. No comments that restate the code; no docstrings or banners the siblings do not have.
3. No reformatting, renames, or refactors outside the task.
4. No new helper or abstraction where a local one already existed.
5. Structure, imports, and error handling follow the house idiom.

**Bounce a mismatch back to the agent with the specific line rather than silently fixing it by hand** — it still holds the context, and hand-fixing hides the miss from the next dispatch. Fix it yourself only when it is a one-liner.

This is the same drift that `code-improve`'s consistency dimension hunts after the fact. Preventing it at dispatch time is far cheaper than auditing it later.
