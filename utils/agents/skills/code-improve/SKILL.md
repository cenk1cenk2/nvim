---
name: code-improve
description: Audit a codebase (or a scoped area of it) to surface architectural, testability, consistency, and clarity improvements. Dispatches parallel subagents across audit dimensions, produces a ranked shortlist with one-line reasoning per proposal, and can drill into picked candidates with parallel design alternatives. Use when user says "code improve", "improve the codebase", "audit this codebase", "find improvements", "suggest refactors", "architecture audit", "find refactoring opportunities", or "where could we improve". Do NOT use for reviewing a specific PR/branch (use /code-review-branch or /code-review-changes), for a single-file cleanup (just edit directly), or for building a plan from a chosen improvement (use /plan-hard after picking).
interaction: chat
references:
  - ../references/plan-mode.md
---

## system

### Code Improve — Codebase Audit and Improvement Proposals

> **ALWAYS enter plan mode.** Read the `plan-mode` reference (strict variant) for full directives — read from the `mcphub` server via `ReadMcpResourceTool` with URI `skills://skill/code-improve/references`.
>
> - Use `EnterPlanMode` tool immediately.
> - **NEVER exit plan mode.** This skill produces proposals, not implementation. The user picks what to do, then invokes `plan-hard` (or similar) to plan the chosen work.
> - Do NOT modify any code during this skill. Read-only operations only.

### Context

The goal of this skill is to proactively surface improvements the user may not have asked about specifically — architectural friction, testability gaps, consistency drift, dead code, clarity problems. The skill branches out using parallel subagents to cover multiple audit dimensions at once, collates findings into a ranked shortlist, and presents proposals with **short, concise arguments** so the user can triage quickly.

This is an audit, not a review of pending changes. For reviewing a specific branch or PR, use `code-review-branch` or `code-review-changes`.

### Process

1. **Enter plan mode.**

2. **Confirm scope.** Ask the user (one question only):

   > **Scope:** Whole repository, a specific module/directory, or a named area of concern (e.g., "the auth code", "the render pipeline")?
   >
   > **Recommended:** <your pick based on conversation context — recent work, recent commits, active files>.
   >
   > **Optional filter:** any dimensions to skip or prioritize (architecture / testability / consistency / dead code / error handling / naming)?

   If the user replies `g`, `go`, or similar, use the recommended scope.

3. **Phase 1 — Parallel Audit.** Dispatch 3-5 `Explore` subagents in parallel (single message, multiple `Agent` tool calls), each with a focused audit dimension. Each subagent returns a **short report (under 300 words)** listing candidates with file paths and 1-line rationale per candidate.

   **Default dimensions** (skip or merge based on user filter):

   | Dimension                            | Subagent focus                                                                                                                                 |
   | ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
   | **Architecture & module boundaries** | Shallow modules, leaky abstractions, god-objects, circular deps, seams that should exist but don't.                                            |
   | **Testability**                      | Untested code paths, pure functions extracted just for testability where the real bugs are in the callers, missing integration/boundary tests. |
   | **Consistency & convention drift**   | Patterns that deviate from the rest of the codebase: naming, file layout, error handling, dependency injection style.                          |
   | **Dead code & coupling**             | Unreferenced functions/files, duplicated logic, tightly coupled modules, circular imports, over-general abstractions used by one caller.       |
   | **Clarity & error handling**         | Cryptic names, silent failures, missing `Result` / `error` propagation, inconsistent logging, poor panic/throw discipline.                     |

   Each subagent prompt should be **self-contained** — include the scope, the dimension, what "good" looks like, and the concise output format (see below).

4. **Phase 2 — Collate and rank.** After all subagents return, de-duplicate overlapping candidates, then rank by **Impact × Ease** (rough mental heuristic, not a formula). Present a numbered shortlist in chat:

   > **Candidates found — <N> improvements:**
   >
   > 1. **<Short title>** — `<file:line>`. <1-line problem>. <1-line proposal>. Impact: <low/med/high>. Effort: <low/med/high>.
   > 2. ...
   >
   > **Recommended top 3:** #<n>, #<n>, #<n> — because <1-line rationale per pick>.
   >
   > Want me to drill into any of these, or surface more?

   Keep each line ≤ 140 chars. Do NOT dump subagent reports verbatim — condense ruthlessly.

5. **Phase 3 — Drill-down (for picked candidates).** For each candidate the user picks, choose one of:

   **a. Single opinionated proposal** — default for simple or obvious improvements. Produce:
   - **Problem** (2-3 sentences, with file refs).
   - **Proposal** (1 paragraph — what to change, how, why).
   - **Trade-offs** (1-3 bullet points).
   - **Effort estimate** (low / med / high with rough reasoning).

   **b. Parallel design alternatives** — for genuinely architectural changes where the interface is the key decision. Dispatch 3+ `Plan` subagents in parallel, each with a **radically different** design constraint:
   - Agent 1: "Minimize the interface — aim for 1-3 entry points maximum."
   - Agent 2: "Maximize flexibility — support many use cases and extension."
   - Agent 3: "Optimize for the most common caller — make the default case trivial."
   - Agent 4 (if applicable): "Ports & adapters — isolate cross-boundary dependencies."

   Each subagent returns: interface signature, 1 usage example, what complexity it hides, dependency strategy, 1-line trade-offs.

   Present the designs sequentially (compact), then compare them in prose (≤ 150 words). End with an **opinionated recommendation** — which design is strongest, and why. If a hybrid works, propose it. The user wants a strong read, not a menu.

6. **Phase 4 — Hand off or save.**
   - If the user wants to implement a picked improvement, suggest invoking `plan-hard` to build the implementation plan. Do NOT implement directly — `code-improve` stops at proposal.
   - Offer to save the audit shortlist to `~/.claude/plans/YYYY-MM-DD-<project>-code-improve-audit.md` for later reference. Only save if the user agrees.

### Subagent Prompt Template (Phase 1)

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

### Subagent Prompt Template (Phase 3b, Design Alternatives)

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

### Conciseness Rules (Non-Negotiable)

- **A couple of lines at most per proposal** in the shortlist. Never wrap to a paragraph.
- **Arguments must fit in ≤ 25 words.** If the argument requires more, the improvement is too complex for the shortlist — drill down instead.
- **Cite evidence by file path + line.** Never vague ("somewhere in the auth module").
- **No boilerplate.** Drop "Consider refactoring...", "It might be worth...", "You could potentially...". Just state the improvement.
- **Rank ruthlessly.** If you have 20 candidates, pick the top 10. Don't pad.

### Key Principles

- **Friction is the signal.** When exploring, what feels awkward, what takes 3 jumps to understand, what has a test that clearly dodges the real behavior — those are candidates. Organic exploration beats rigid heuristics.
- **Branch out with subagents.** Parallel audits across dimensions find more candidates faster, and each subagent's focus keeps it from drifting.
- **Short arguments or no proposal.** If you can't argue a change in one line, the change is too speculative for the shortlist.
- **Be opinionated.** The user wants a strong read. "All options have trade-offs" is a failure mode — recommend one.
- **Stop at proposal.** This skill does not implement. After picking, the user invokes `plan-hard` (or another skill) to plan the work.
- **Respect scope.** If the user asks for auth-module improvements, don't drift into render pipeline findings. Save those for a later pass.

### Examples

**Example 1 — Whole-repo audit:**

1. Enter plan mode.
2. User says "code improve, whole repo".
3. Dispatch 5 subagents in parallel: architecture, testability, consistency, dead code, clarity.
4. Collate 12 candidates → rank → present top 10 with 1-liners. Recommend top 3.
5. User picks #2 ("Extract DB session management from handlers"). Route to single opinionated proposal (not enough architectural ambiguity to justify 3 design subagents).
6. Present Problem / Proposal / Trade-offs / Effort. Suggest `plan-hard` for implementation.
7. Stop.

**Example 2 — Scoped module audit, architectural ambiguity:**

1. User says "code improve the rendering pipeline".
2. Dispatch 3 subagents (scope is narrow, so skip "dead code" / "consistency" as lower-value dimensions).
3. Candidates surface a central one: `Renderer` is shallow — 90% of its code is in callers.
4. User picks this candidate. It's architecturally ambiguous (the interface is the key call), so trigger Phase 3b — dispatch 3 design subagents in parallel (minimal / flexible / common-case-optimized).
5. Present 3 interfaces compactly. Compare in prose. Recommend the common-case-optimized design — the render pipeline has one dominant caller.
6. Offer to save audit + design notes to plan file. Stop.

### Composition with Other Skills

- **`plan-hard`** (`skills://skill/plan-hard`) — the natural follow-on for any picked improvement. Produce the plan. This skill stops at proposal.
- **`plan-revise`** (`skills://skill/plan-revise`) — if a picked improvement reveals that an existing plan was wrong, route to `plan-revise` instead of `plan-hard`.
- **`code-review-branch`** / **`code-review-changes`** — for reviewing pending changes, not for codebase-wide audit. Different skill, different scope.
- **`code-deviations`** — if the audit surfaces a deviation between intended and actual behavior, apply the deviations pattern when discussing with the user.

### Related Skills

- **`plan-hard`** (resource: `skills://skill/plan-hard`) — build a plan from a picked improvement.
- **`plan-revise`** (resource: `skills://skill/plan-revise`) — revise an existing plan when an audit finding invalidates it.
- **`code-review-branch`** (resource: `skills://skill/code-review-branch`) — review a specific branch's changes.
- **`code-review-changes`** (resource: `skills://skill/code-review-changes`) — review uncommitted / pending changes.
