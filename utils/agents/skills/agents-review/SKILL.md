---
name: agents-review
description: agents-review Dispatch a review subagent to cross-check an artifact (plan, DAG, facts, or free-form analysis) against the codebase or a devil's-advocate lens. Uses a cheap model by default for quick checks; opts up to a smarter model for hard reviews. Multiple artifacts in one invocation dispatch reviewers in parallel. Use when user says "review this", "fact-check", "cross-check", "second opinion", "peer review", "agents-review". Do NOT use for running a task (use /agents-delegate), for multi-task plans (use /agents-plan), or to re-read code you've already seen (just read it yourself).
disable-model-invocation: true
argument-hint: "[type=plan|dag|facts|freeform] [artifact or file path] [optional: 'hard' | 'deep' | 'thorough' | explicit model name]"
references:
  - ../references/present-first.md
  - ../references/agents-delegate.md
  - ../references/scm-detect.md
---

## Review Subagent Dispatch

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `agents-delegate` reference for subagent dispatch parameters and mechanics. Resolve tiers to concrete models via the `agents-tiers` skill (and its per-provider references).
> Read the `scm-detect` reference only if the review task requires git context (e.g., reviewing a diff or historical change).

## Context

This skill externalises review: instead of self-evaluating an artifact you produced, you hand it to another agent with a review-specific prompt and collect a structured verdict. The reviewer is read-only — it verifies, flags, and suggests, but never modifies files.

**When to use:**

- Fact-checking self-answered claims (often invoked automatically by `plan-hard`).
- Sanity-checking a DAG schedule before running `agents-plan`.
- Peer-reviewing a plan before committing to it.
- Getting a devil's-advocate take on a recommendation or analysis.

**When NOT to use:**

- Running a task (use `agents-delegate`).
- Multi-task plans with file edits (use `agents-plan`).
- Reading code you haven't looked at (just use `Read` / `Grep`).

## Artifact Types

Four typed templates, each with a different checklist. The skill picks the right template from the user's invocation (`type=plan`, `type=dag`, etc., or inferred from the artifact shape).

| Type | Use case | Reviewer's focus |
|------|----------|------------------|
| `plan` | Plan file or plan section | Requirement coverage, missing steps, overlooked risks, unclear acceptance criteria. |
| `dag` | Layer schedule from `agents-plan` | Dependency correctness, missed semantic deps, file collisions within layers, layering optimality. |
| `facts` | List of factual claims | Per-claim verification against the codebase. PASS / FAIL / QUESTION with evidence. |
| `freeform` | Analysis, recommendation, rationale | Devil's-advocate: counter-arguments, dismissed alternatives, load-bearing assumptions, failure modes. |

## Model Tier

**Default tier: `cheap` for all types** (Claude resolves this to `haiku`; get the concrete model for the active provider from the `agents-tiers` skill). The default review is a quick sanity pass — the cost/latency balance favours a cheap model.

**User override:**

| User wording | Resolved tier |
|--------------|---------------|
| nothing specified | `cheap` (default) |
| "hard", "deep", "thorough", "rigorous", "careful" | `smart` |
| "default", "balanced" | `default` |
| Explicit model name (e.g., `opus`, `sonnet`) | Use verbatim — do not remap |

**Mismatch check:** if the user picks `cheap` for `freeform` (nuanced argument review) or `smart` for `facts` (grep/read verification work), ask before dispatching. See the `agents-delegate` reference's Mismatched Choice section.

## Process

1. **Parse the invocation.** Extract:
   - Artifact type(s) — one or more of `plan` / `dag` / `facts` / `freeform`.
   - Artifact content or file path.
   - Tier override (if any).
   - "Hard" / "deep" / "thorough" keyword → upgrade tier.

2. **For each artifact:**
   - Read the artifact content (from file, or inline from the user's message).
   - Build a self-contained review prompt using the type's template (see Prompt Templates below).
   - Resolve the tier per artifact (default `cheap`; user override wins; mismatch check if needed).

3. **Dispatch in parallel.** Single message, one subagent dispatch per artifact. Parameters:
   - An exploration (read-only) subagent.
   - `description` — short summary, e.g., `"Fact-check auth claims"`.
   - `prompt` — the self-contained review prompt.
   - `model` — resolved tier.
   - No worktree isolation (not needed).
   - No `mode: "bypassPermissions"` — reviewers don't modify files, so permission bubbling is fine.
   - No `run_in_background` — blocking dispatch.

4. **Collect verdicts.** This turn blocks until every reviewer returns.

5. **Relay to the user.** Present results as labeled sections per artifact — no cross-artifact merging. See the Output Format section below.

## Prompt Templates

**Common structure** (used for every dispatch):

```
You are a review agent. Another model produced the artifact below; your job is to independently verify it against the codebase (or, for freeform, against first principles).

## Artifact type
[plan | dag | facts | freeform]

## Artifact content
[verbatim artifact — paste the plan file / DAG table / claim list / prose here]

## Your checklist
[type-specific checklist — inserted from the appropriate section below]

## Output format

Respond with exactly:

VERDICT: APPROVED | CONCERNS | REJECTED
SUMMARY: <one-line summary>
FINDINGS:
- <concern or claim>: <PASS/FAIL/QUESTION>, <evidence or suggestion>
SUGGESTIONS:
- <optional list of specific changes — one per line; omit the section if none>

## Rules
- Verify claims against the codebase where possible — use Grep, Read, Glob, LSP tools.
- Be specific: cite file paths and line numbers.
- Distinguish FAIL (verifiably wrong) from CONCERN (risky but not wrong) from QUESTION (unclear, needs author clarification).
- Do NOT modify files. You are a reader and commenter only.
```

**Type-specific checklists:**

**`plan` checklist:**

```
1. Does the plan cover every requirement stated in the Context section? List gaps.
2. Are there missing steps, unclear acceptance criteria, or overlooked edge cases?
3. Is the file list realistic and scoped? Flag paths that don't exist or seem wrong.
4. Are the verification commands appropriate for the project's tooling?
5. Any risks the plan doesn't name?
```

**`dag` checklist:**

```
1. Are all declared `depends_on` relationships necessary? Flag redundant ones.
2. Are any semantic dependencies missing? Look for cases where task B reads output from task A even though their `files` lists don't overlap.
3. Within each layer, do any two tasks write the same file? Flag collisions.
4. Is the layering optimal? Could tasks be parallelised further, or should any be sequentialised further?
5. Any assumptions baked into the DAG that aren't stated?
```

**`facts` checklist:**

```
For each claim below, verify against the codebase and report:
- PASS — claim is true, cite evidence (file path, line number, git log entry).
- FAIL — claim is false or misleading, explain what's actually true.
- QUESTION — cannot verify from available evidence, explain what's missing.

If a claim is partially true, prefer FAIL with a clarifying note over QUESTION.
```

**`freeform` checklist:**

```
1. What's the strongest counter-argument to the artifact's conclusion?
2. What alternatives are being dismissed without justification?
3. What assumptions are load-bearing but not stated?
4. What's the failure mode of the proposed approach?
5. What would change your verdict from the artifact's position?
```

## Output Format

When one artifact: relay the reviewer's verdict verbatim, wrapped in a single heading.

When multiple artifacts: label each section by type, present verdicts in order.

```
## Review: plan
VERDICT: CONCERNS
SUMMARY: Plan misses migration step for existing sessions.
FINDINGS:
- Step 3 assumes cookies are absent: CONCERN, cookies exist in 30% of active sessions.
SUGGESTIONS:
- Add a migration step before Step 3 that invalidates legacy cookies.

## Review: dag
VERDICT: APPROVED
SUMMARY: DAG is well-formed with no collisions.
FINDINGS:
- task-c depends_on task-a: PASS, task-c imports token generation from task-a.
```

No merging across artifacts — each review keeps its own context.

## Key Principles

- **Cheap by default.** The skill is the "quick second opinion" tool. Default tier is cheap; opt up explicitly for hard reviews.
- **One reviewer per artifact.** No ensemble. If the user wants multiple reviewers on the same artifact, they invoke the skill multiple times.
- **Parallel fan-out over artifacts.** Multiple artifacts = single message, multiple subagent dispatches, blocking.
- **Read-only.** Reviewers never modify files. An exploration subagent enforces the read-only disposition.
- **Structured output.** The `VERDICT` / `FINDINGS` shape is machine-parseable so `plan-hard` can extract FAILs for its correction loop.
- **Don't auto-apply suggestions.** The reviewer suggests; the user (or the inviting skill) decides what to do.
- **Cite evidence.** Every finding should name a file path, line number, or concrete piece of evidence. Unsourced claims are themselves a review failure.

## Related Skills

- **`agents-delegate`** — for running a task (not reviewing an artifact). Uses the same dispatch mechanism with a different prompt shape.
- **`agents-plan`** — multi-task DAG execution. `agents-review` can sanity-check the DAG before launching.
- **`plan-hard`** — auto-invokes `agents-review` type=`facts` at the end of its interview to fact-check self-answered claims before writing the plan file.
