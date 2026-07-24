---
name: code-improve
description: code-improve Audit a codebase (or a scoped area) to surface architectural, testability, consistency, and clarity improvements. Fans out parallel subagents across audit dimensions and returns a ranked shortlist with one-line reasoning, optionally drilling into picks with parallel design alternatives. Use when user says "code improve", "improve the codebase", "audit this codebase", "find improvements", "suggest refactors", or "find refactoring opportunities". Do NOT use for reviewing a specific PR/branch (use /code-review-branch or /code-review-changes), single-file cleanup (edit directly), or building a plan from a pick (use /plan-hard).
disable-model-invocation: true
references:
  - ../references/present-first.md
  - ../references/agents-delegate.md
  - ../references/project-tooling.md
---

## Code Improve — Codebase Audit and Improvement Proposals

> **Present-first.** Read the `present-first` reference — do not enter plan mode; this skill reads and presents, it does NOT implement. The only write is the optional audit-file save in the final phase, gated on approval.
>
> - Delegate discovery to subagents so the audit stays out of the main context.
> - This skill produces proposals, not implementation. The user picks what to do, then invokes `plan-hard` (or similar) to plan the chosen work.

> Read the `agents-delegate` reference for subagent dispatch mechanics. Resolve tiers to concrete models via the `agents-tiers` skill.

> Read the `project-tooling` reference to discover the project's format / lint / test commands (Taskfile, `package.json`, Makefile, Cargo, …). The audit grounds its proposals in what keeps those tasks green.

## Context

The goal of this skill is to proactively surface improvements the user may not have asked about specifically — architectural friction, testability gaps, consistency drift, dead code, clarity problems. The skill branches out using parallel subagents to cover multiple audit dimensions at once, collates findings into a ranked shortlist, and presents proposals with **short, concise arguments** so the user can triage quickly.

Subagent dispatch keeps the raw exploration in isolated context — the main thread only ever sees condensed reports, not the file dumps behind them.

This is an audit, not a review of pending changes. For reviewing a specific branch or PR, use `code-review-branch` or `code-review-changes`.

## Process

1. **Confirm scope.** Ask the user (one question only):

   > **Scope:** Whole repository, a specific module/directory, or a named area of concern (e.g., "the auth code", "the render pipeline")?
   >
   > **Recommended:** <your pick based on conversation context — recent work, recent commits, active files>.
   >
   > **Optional filter:** any dimensions to skip or prioritize (architecture / testability / consistency / dead code / error handling / naming)?

   If the user replies `g`, `go`, or similar, use the recommended scope.

   Then discover the project's task tooling per the `project-tooling` reference — scan for `Taskfile.yml`, `package.json`, `Makefile`, `Cargo.toml`, and the like, and note the format / lint / test commands. These anchor the audit: proposals must not break them, and the consistency dimension defers to whatever the formatter already normalizes.

2. **Phase 1 — Parallel Audit.** Dispatch 3-5 audit subagents in parallel (single message, multiple subagent dispatches) at **`cheap` tier** — resolve via the `agents-tiers` skill, use an exploration subagent. Each subagent takes a focused audit dimension and returns a **short report (under 300 words)** listing candidates with file paths and 1-line rationale per candidate.

   **Default dimensions** (skip or merge based on user filter):

   | Dimension                            | Subagent focus                                                                                                                                 |
   | ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
   | **Architecture & module boundaries** | Shallow modules, leaky abstractions, god-objects, circular deps, seams that should exist but don't.                                            |
   | **Testability**                      | Untested code paths, pure functions extracted just for testability where the real bugs are in the callers, missing integration/boundary tests. |
   | **Consistency & convention drift**   | Code that reads as written by a different hand: variable/function/type naming, function signatures, comment density (and its intentional absence), file layout, error handling, DI style. See "Consistency Dimension — What to Audit" below. |
   | **Dead code & coupling**             | Unreferenced functions/files, duplicated logic, tightly coupled modules, circular imports, over-general abstractions used by one caller.       |
   | **Clarity & error handling**         | Cryptic names, silent failures, missing `Result` / `error` propagation, inconsistent logging, poor panic/throw discipline.                     |

   Each subagent prompt should be **self-contained** — include the scope, the dimension, what "good" looks like, and the concise output format (see below).

3. **Phase 2 — Collate and rank.** After all subagents return, de-duplicate overlapping candidates, then rank by **Impact × Ease** (rough mental heuristic, not a formula).

   **Optional second opinion (with approval).** Before presenting, offer to cross-check the ranked shortlist with `agents-review`:

   > Want a second opinion? I'll dispatch a review subagent (`agents-review`, `type=freeform`) to sanity-check the top candidates before we drill in.

   On approval, dispatch one `agents-review` pass over the top candidates and fold its verdicts (confirmed / weak / missed) into the shortlist. The cross-check runs in an isolated subagent, so the main context stays clean. Skip silently if the user declines.

   Then present a numbered shortlist in chat:

   > **Candidates found — <N> improvements:**
   >
   > 1. **<Short title>** — `<file:line>`. <1-line problem>. <1-line proposal>. Impact: <low/med/high>. Effort: <low/med/high>.
   > 2. ...
   >
   > **Recommended top 3:** #<n>, #<n>, #<n> — because <1-line rationale per pick>.
   >
   > Want me to drill into any of these, or surface more?

   Keep each line ≤ 140 chars. Do NOT dump subagent reports verbatim — condense ruthlessly.

4. **Phase 3 — Drill-down (for picked candidates).** For each candidate the user picks, choose one of:

   **a. Single opinionated proposal** — default for simple or obvious improvements. Produce:
   - **Problem** (2-3 sentences, with file refs).
   - **Proposal** (1 paragraph — what to change, how, why).
   - **Trade-offs** (1-3 bullet points).
   - **Effort estimate** (low / med / high with rough reasoning).
   - **Verification** (which discovered task confirms it stays green — e.g. `task test`, `task lint`).

   **b. Parallel design alternatives** — for genuinely architectural changes where the interface is the key decision. Dispatch 3+ design subagents in parallel (via the `agents-delegate` mechanics, a planning subagent), each with a **radically different** design constraint:
   - Agent 1: "Minimize the interface — aim for 1-3 entry points maximum."
   - Agent 2: "Maximize flexibility — support many use cases and extension."
   - Agent 3: "Optimize for the most common caller — make the default case trivial."
   - Agent 4 (if applicable): "Ports & adapters — isolate cross-boundary dependencies."

   Each subagent returns: interface signature, 1 usage example, what complexity it hides, dependency strategy, 1-line trade-offs.

   Present the designs sequentially (compact), then compare them in prose (≤ 150 words). End with an **opinionated recommendation** — which design is strongest, and why. If a hybrid works, propose it. The user wants a strong read, not a menu.

5. **Phase 4 — Hand off or save.**
   - If the user wants to implement a picked improvement, suggest invoking `plan-hard` to build the implementation plan. Do NOT implement directly — `code-improve` stops at proposal.
   - Offer to save the audit shortlist to your internal plans directory as `YYYY-MM-DD-<project>-code-improve-audit.md` for later reference. Only write the file once the user agrees.

## Consistency Dimension — What to Audit

Consistency is measured against the **local neighborhood**, not a global ideal: the target state is code indistinguishable from the files around it, where a reader can't tell which lines were added later or by a different hand. For the consistency dimension, audit these axes and flag *drift from the surrounding convention* — never deviation from an external style guide:

- **Naming.** Casing per language (snake_case / camelCase / PascalCase), abbreviation habits, boolean prefixes (`is` / `has` / `should`), and names that restate their scope (`sandbox.resolve(path)`, not `sandbox.resolve_sandbox_path(path)`). Flag stutters, one-off casings, and names that diverge from how siblings name the same concept.
- **Function signatures.** Parameter order and grouping, options-bag vs positional params, return discipline (`Result` / `error` / option / throw — applied consistently?), sync vs async shape, and behavior placed as a free function where the codebase would make it a method (or vice versa).
- **Comments — density and its absence.** Match the surrounding file. Flag comments added where neighbors carry none (noise), and missing comments where the file or module documents consistently. A sparse-comment file is a deliberate convention — do NOT propose blanket "add docstrings"; flag the *drift*, in either direction.
- **Layout & idiom.** File/module structure, import ordering, error-handling and logging shape, dependency-injection style — deviations from how sibling files solve the same problem.

**Defer to the tooling.** Skip whatever the project's formatter/linter auto-normalizes — import ordering, whitespace, quote style, trailing commas. That drift isn't worth a finding; `task fmt` (or the project's equivalent) fixes it on the next run. Spend the consistency budget on what the tooling can't catch: naming, signatures, comment intent, structure.

Report each as a concrete drift with `file:line` and the local convention it breaks, not a style preference.

## Subagent Prompt Template (Phase 1)

When dispatching Phase 1 audit subagents, use this shape:

> You are auditing the <scope> codebase for <dimension>. Scan relevant files and identify specific, actionable improvement candidates.
>
> **What "good" looks like for <dimension>:** <1-2 sentences describing the target state>.
>
> **Output format — for each candidate, one compact block:**
>
> - **<Short title>** (`<file:line>`): <1-sentence problem>. Proposal: <1-sentence change>. Impact: <low/med/high>. Evidence: <file refs>.
>
> **Limits:** Return at most 5 candidates. Total response under 300 words. Skip if nothing significant found — say so explicitly.

Subagents run in parallel — **dispatch all in a single message with multiple tool calls**, not sequentially.

## Subagent Prompt Template (Phase 3b, Design Alternatives)

> You are designing an interface for <module/concept> in the <scope> codebase. Your design constraint: **<constraint>**.
>
> **Context:** <file paths, coupling details, what's being hidden, why the current shape is wrong>.
>
> **Output format:**
>
> 1. **Interface signature** (types, methods, params — code fence).
> 2. **Usage example** (1 realistic caller — code fence).
> 3. **What it hides internally** (1 sentence).
> 4. **Dependency strategy** (1 sentence — injected, imported, resolved how?).
> 5. **Trade-offs** (2-3 bullets — what this design is good at, what it sacrifices).
>
> **Limits:** Under 250 words. Be opinionated — your constraint is a strong preference, lean into it.

## Conciseness Rules (Non-Negotiable)

- **A couple of lines at most per proposal** in the shortlist. Never wrap to a paragraph.
- **Arguments must fit in ≤ 25 words.** If the argument requires more, the improvement is too complex for the shortlist — drill down instead.
- **Cite evidence by file path + line.** Never vague ("somewhere in the auth module").
- **No boilerplate.** Drop "Consider refactoring...", "It might be worth...", "You could potentially...". Just state the improvement.
- **Rank ruthlessly.** If you have 20 candidates, pick the top 10. Don't pad.

## Key Principles

- **Friction is the signal.** When exploring, what feels awkward, what takes 3 jumps to understand, what has a test that clearly dodges the real behavior — those are candidates. Organic exploration beats rigid heuristics.
- **Branch out with subagents.** Parallel audits across dimensions find more candidates faster, each subagent's focus keeps it from drifting, and the raw exploration stays isolated from the main context.
- **Consistency is local.** Measure each file against its neighbors, not a global ideal. Flag drift from the surrounding convention — naming, signatures, comment density — and treat the absence of comments or abstraction as a deliberate pattern to preserve, never a gap to fill.
- **Ground in the tooling.** Discover the project's format / lint / test tasks up front and keep proposals inside what they enforce — a picked improvement should land green, and don't spend findings on drift the formatter auto-fixes.
- **Be opinionated.** The user wants a strong read. "All options have trade-offs" is a failure mode — recommend one.
- **Stop at proposal.** This skill does not implement. After picking, the user invokes `plan-hard` (or another skill) to plan the work.
- **Respect scope.** If the user asks for auth-module improvements, don't drift into render pipeline findings. Save those for a later pass.

## Examples

**Example 1 — Whole-repo audit:**

1. User says "code improve, whole repo".
2. Dispatch 5 audit subagents in parallel (`cheap` tier): architecture, testability, consistency, dead code, clarity.
3. Collate 12 candidates → rank. Offer a second opinion; user accepts, so dispatch `agents-review` over the top candidates and fold in its verdicts.
4. Present top 10 with 1-liners. Recommend top 3.
5. User picks #2 ("Extract DB session management from handlers"). Route to single opinionated proposal (not enough architectural ambiguity to justify 3 design subagents).
6. Present Problem / Proposal / Trade-offs / Effort. Suggest `plan-hard` for implementation.
7. Stop.

**Example 2 — Scoped module audit, architectural ambiguity:**

1. User says "code improve the rendering pipeline".
2. Dispatch 3 subagents (scope is narrow, so skip "dead code" / "consistency" as lower-value dimensions).
3. Candidates surface a central one: `Renderer` is shallow — 90% of its code is in callers. User declines the second opinion.
4. User picks this candidate. It's architecturally ambiguous (the interface is the key call), so trigger Phase 3b — dispatch 3 design subagents in parallel (minimal / flexible / common-case-optimized).
5. Present 3 interfaces compactly. Compare in prose. Recommend the common-case-optimized design — the render pipeline has one dominant caller.
6. Offer to save audit + design notes to plan file. Stop.

## Composition with Other Skills

- **`agents-review`** — the second-opinion pass in Phase 2. Cross-checks the ranked shortlist in an isolated subagent so the review never pollutes the main context. Gated on user approval.
- **`agents-delegate`** — the dispatch mechanics for the Phase 1 audit and Phase 3b design subagents (tier resolution, self-contained prompts, blocking parallel dispatch).
- **`plan-hard`** — the natural follow-on for any picked improvement. Produce the plan. This skill stops at proposal.
- **`plan-revise`** — if a picked improvement reveals that an existing plan was wrong, route to `plan-revise` instead of `plan-hard`.
- **`code-review-branch`** / **`code-review-changes`** — for reviewing pending changes, not for codebase-wide audit. Different skill, different scope.
- **`code-deviations`** — if the audit surfaces a deviation between intended and actual behavior, apply the deviations pattern when discussing with the user.

## Related Skills

- **`agents-review`** — dispatch a review subagent for a second opinion on the shortlist.
- **`agents-delegate`** — subagent dispatch mechanics and tier resolution.
- **`plan-hard`** — build a plan from a picked improvement.
- **`plan-revise`** — revise an existing plan when an audit finding invalidates it.
- **`code-review-branch`** — review a specific branch's changes.
- **`code-review-changes`** — review uncommitted / pending changes.
