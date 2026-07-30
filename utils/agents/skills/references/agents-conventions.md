# Agent Conventions — Match the House Style

**⛔ MANDATORY for every dispatch that writes code.** Not an optional enrichment step. Skip it only for genuinely read-only work (research, audits, reviews).

A subagent starts with a fresh context and no taste for this codebase. Left to itself it writes generically-correct code in its own dialect: different naming, invented helpers, explanatory comments nobody asked for, a structure that mirrors no existing file. It passes the tests and reads as foreign — and that *is* the defect, because the next person to touch it cannot tell what the codebase's pattern actually is.

## The acceptance test

**A reader without `git blame` must not be able to tell which file the agent wrote.** If the diff stands out from its neighbours, the task is not done, however well it works.

## 1. Study the examples BEFORE writing

Make this the agent's mandatory first action, stated in the prompt. Authority runs in this order — a lower source never overrides a higher one:

1. **⛔ Examples the user pointed at.** When the user named a file, function, module, commit, or PR and said "do it like this" — that is the template, and it outranks everything, including your own reading of the codebase and your judgement about what is better. Read it before writing a line, follow its shape exactly, and if you believe it is wrong, say so in the report instead of quietly doing it differently.
2. **The nearest siblings.** The 2-3 files in the same directory or module, read end to end.
3. **The closest existing implementation of the same kind of thing** — another handler, another plugin module, another migration, another test — used as the working template.
4. **The wider codebase**, for anything the local files do not settle.
5. **Language or framework defaults** — last resort, and only where the codebase is genuinely silent.

**Read the history of the code you are touching**, not the repo's history in general. A commit is worth reading when it shows how *this kind of change* was made *around here*:

- commits that touched the same directory or file (`git log -p -- <path>`),
- the commit or PR/MR that introduced the sibling you are modelling on — it shows the whole shape of such a change, including the tests and docs that came with it,
- commits that added the same kind of thing somewhere else in the codebase, when the local area has no precedent.

Skip anything unrelated: a commit that merely touched the file for a rename or a formatting sweep teaches nothing.

**Extend an existing pattern rather than introducing a new one.** Where no precedent exists at any level, say so in the report instead of inventing one silently.

## 2. Copy, don't design

Mirror what the examples already do:

- **Naming scheme** — casing per symbol kind, how the codebase abbreviates versus spells out, the words it uses for recurring concepts, how files are named. Reuse the codebase's vocabulary; do not introduce a synonym for a concept that already has a name.
- **Inlining versus extracting** — does this codebase inline a single-use helper, or pull it out? Does behavior hang off the type as a method, or sit in a free function? Match that. Do not extract an abstraction the neighbours would have inlined, and do not inline what they consistently factor out.
- **Structure** — declaration order, file layout, module boundaries, where a new thing of this kind belongs.
- **Signature shape** — parameter order and grouping, options-object versus positional, what gets returned, how optionality is expressed.
- **Error handling, logging, configuration, dependency passing** — the local idiom, not the language's most popular one.
- **Imports** — grouping, ordering, aliasing.
- **Tests** — framework, style, location, fixture and assertion patterns.

When the user pointed at an example, this list is measured against **that** example first.

**A convention you find suboptimal is still the convention.** Flag it in the report; do not "fix" it as a side effect. Unrequested refactors and renames are the fastest way to make a diff unrecognizable.

## 3. Comments — the absolute

- **Match the surrounding density and format, including when that means none at all.**
- **Never restate what the code does.** A comment earns its place only by explaining a non-obvious *why*: a constraint, a trade-off, a gotcha, an edge case.
- **No section banners, no narration** (`// Step 1: …`), **no docstrings** added where siblings carry none, **no TODOs** unless asked.
- Explanation belongs in the agent's report, not in the code.

## 4. Scope discipline

- Touch only files in the declared write scope.
- No drive-by reformatting of untouched lines; no reordering imports "while there".
- No new dependencies unless the task says so.
- Keep the diff minimal — the smallest change consistent with local style.

## What the dispatcher discovers first

Discover these from the code before dispatching (Sourcebot first when the pattern may span repos, then the target repo directly), and fold them into the prompt block below. Skip categories that do not apply.

- **Testing** — framework, style (table-driven / BDD), file naming, location, fixture and mock patterns.
- **Code style** — formatter in use (and whether the agent should run it or `hyprpilot-nvim__editor_format`), whitespace habits, naming per symbol kind, import grouping, error-handling idiom.
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
- Shape: match the local habit on inlining versus extracting helpers, methods versus free functions, and signature style. Do not add an abstraction the neighbours would have inlined.
- Formatting: <formatter + when to run it>. <whitespace habits>.
- Errors: <local idiom>.
- Imports: <grouping/ordering>.
- Tests: <framework, style, location>.
- Architecture: <where this kind of code belongs>.
- Comments: match the surrounding density — <none | why-only>. Never restate what the code does. No banners, no narration, no added docstrings, no TODOs.
- Scope: modify only <paths>. No refactors, renames, reformatting, or dependency changes outside the task. A convention you dislike is still the convention — flag it, don't fix it.

Before you report, self-check your diff against <reference file>: if a reader could tell your code apart from its neighbours, fix it. If the codebase had no precedent for something you needed, say so in the report rather than inventing one silently.
```

## On return — check the diff, not the summary

The agent's report describes intent. Read the actual diff and check:

1. Naming matches the examples, per symbol kind, reusing existing vocabulary — and matches any example the user pointed at above all.
1b. Inlining/extraction and signature shape match the local habit; no abstraction introduced where the neighbours inline.
2. No comments that restate the code; no docstrings or banners the siblings do not have.
3. No reformatting, renames, or refactors outside the task.
4. No new helper or abstraction where a local one already existed.
5. Structure, imports, and error handling follow the house idiom.

**Bounce a mismatch back to the agent with the specific line rather than silently fixing it by hand** — it still holds the context, and hand-fixing hides the miss from the next dispatch. Fix it yourself only when it is a one-liner.

This is the same drift that `code-improve`'s consistency dimension hunts after the fact. Preventing it at dispatch time is far cheaper than auditing it later.
