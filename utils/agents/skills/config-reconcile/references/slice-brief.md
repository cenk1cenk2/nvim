# Slice Brief

The shared brief every slice agent in a `config-reconcile` run reads first. Copy it to the scratchpad, fill the placeholders, and point each dispatch prompt at the copy. The dispatch prompt itself carries only the slice: its writable files, its read-only neighbours, and its focus areas.

## Template

```markdown
# Reconcile brief

You are reconciling ONE slice of a skill catalog so it is consistent, correctly wired, current, and concise. Your writable files are in your dispatch prompt. Everything else is read-only.

Catalog root: <root>. Each skill is `<slug>/SKILL.md`; shared references live under `<root>/references/`, skill-local ones under `<slug>/references/`. Central guidance: <central guidance file(s)>.

## FIRST: read the standard

Read these in full before touching anything. They define "correct":
<numbered list: the authoring skills, the loader skill, current-state-only, and the central guidance sections that own cross-cutting rules>

## The checks

Run `<check_catalog path> <root>` and filter the output to your files. WARN rows are heuristics; judge each one.

1. **Wiring.** Declared paths resolve. Every cited reference is declared, or reached by loading the skill that declares it. Every declaration is used. Branch-only declarations of a composed skill are dropped. Per-harness families are declared in full.
2. **Staleness.** Names, paths, tools and flows that were renamed, moved, merged, or now belong to another file. Verify against the live tree and the live tool list; never assume.
3. **Duplication.** Text restated from a reference, another skill, or the central guidance becomes a name.
4. **Contradictions.** Two files disagreeing on one rule. Find the owner and reconcile to it.
5. **Concision.** Tighten without dropping a rule. Every changed line answers to one of these checks.
6. **Descriptions** meet the checklist.
7. **Mechanisms.** Tool names, parameters, paths and config keys match the live source. Flag what you cannot confirm.

## Apply vs propose

Apply directly (meaning-preserving): wiring fixes, replacing a restatement with a name, removing history, tightening, reshaping a description without changing its trigger scope, fixing stale names and paths.

Propose only: anything that changes a rule, behaviour, default, gate or invocation tier; deleting, merging, splitting or renaming a skill or reference; moving content across the slice boundary; any file outside your slice. When unsure, propose.

## Discipline

- Match the voice of the neighbouring skills. Smallest diff; never reformat, re-wrap or realign what you did not change. No commentary about the edit in the file.
- No commits, no staging, no formatters over the tree. Other agents are editing other slices concurrently.
- Open nothing in the user's browser or editor.

## Before reporting

Re-run the linter. Then run `git diff --stat` and confirm every changed file is in your slice, and that every path you added to a frontmatter exists.

## Report (final message, max ~1500 words)

Status: DONE | DONE_WITH_CONCERNS | BLOCKED.

1. **Applied**: one line per file, with what changed and which check drove it.
2. **Proposed (meaning changes)**: ranked, each with the file, current behaviour, proposed behaviour and why.
3. **Deletion / merge candidates**, with evidence. Delete nothing.
4. **Cross-slice issues**: the file, the issue and the suggested fix.
5. **Unverified**.
```

## Filling it

- **The standard** is the catalog's own authoring skills. Here: `config-skills`, `config-references`, `hyprpilot-skills`, `current-state-only`, and the `AGENTS.md` sections for skills, posture and tools. For a different catalog, name that catalog's equivalents; when it has none, the reconcile has nothing to reconcile against, so ask the user before continuing.
- **The central-guidance slice** gets one override line: "This slice is READ-ONLY; everything you find goes into the report as a proposal." Its edits need the captain to name the file and bless the change, per `config-targets`.
