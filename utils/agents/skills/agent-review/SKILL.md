---
name: agent-review
description: agent-review Dispatch review subagents to cross-check an artifact - a plan, a DAG, a set of factual claims, or an argument - against the codebase or a devil's-advocate lens. Tier follows what the review demands; multiple artifacts review in parallel. Use on "review this", "fact-check", "second opinion". Not for running the work itself, or re-reading code you already have.
argumentHint: '[type=plan|dag|facts|freeform] [artifact or path] [optional: ''thorough'' or a model name]'
references:
  - ../references/agent/agent-delegate.md
  - ../references/scm/scm-detect.md
  - ../references/harness/agent-delegate-harness-claude.md
  - ../references/harness/agent-delegate-harness-codex.md
  - ../references/harness/agent-delegate-harness-opencode.md
---

## Review Subagent Dispatch

Subagent dispatch parameters and mechanics per `agent-delegate`. Load the `agent-harness` skill to resolve tiers to concrete models. Reviewers write nothing, so a review dispatch needs no approval gate of its own.

## Context

This skill externalises review: instead of self-evaluating an artifact you produced, you hand it to another agent with a review-specific prompt and collect a structured verdict. The reviewer is read-only — it verifies, flags, and suggests, but never modifies files.

**When to use:**

- Fact-checking self-answered claims (often invoked automatically by `plan-hard`).
- Sanity-checking a DAG schedule before running `agent-plan`.
- Peer-reviewing a plan before committing to it.
- Getting a devil's-advocate take on a recommendation or analysis.

**When NOT to use:**

- Running a task (use `agent-delegate`).
- Multi-task plans with file edits (use `agent-plan`).
- Reading code you haven't looked at (just use `Read` / `Grep`).

## Artifact Types

Four typed templates, each with a different checklist. The skill picks the right template from the user's invocation (`type=plan`, `type=dag`, etc., or inferred from the artifact shape).

| Type | Use case | Reviewer's focus |
|------|----------|------------------|
| `plan` | Plan file or plan section | Requirement coverage, missing steps, overlooked risks, unclear acceptance criteria. |
| `dag` | Layer schedule from `agent-plan` | Dependency correctness, missed semantic deps, file collisions within layers, layering optimality. |
| `facts` | List of factual claims | Per-claim verification against the codebase. PASS / FAIL / QUESTION with evidence. |
| `freeform` | Analysis, recommendation, rationale | Devil's-advocate: counter-arguments, dismissed alternatives, load-bearing assumptions, failure modes. |

## Model Tier

**Pick the tier from what the review actually demands — there is no blanket default.** A cheap model can grep, cite, and check a claim against a file; it cannot weigh a trade-off, spot the missing dependency in a DAG, or build the strongest counter-argument. Under-tiering a judgment review produces a confident `APPROVED` that means nothing — worse than no review, because it gets trusted.

Starting points by artifact type:

| Type | Starting tier | Why |
|------|---------------|-----|
| `facts` | `cheap` | Mechanical verification — grep, read, cite. Escalate when the claims are architectural rather than factual. |
| `plan` | `default` | Coverage and gap-finding needs the whole plan held in view at once. |
| `dag` | `default` | Dependency and collision reasoning; escalate to `smart` for a large or heavily coupled DAG. |
| `freeform` | `smart` | Counter-arguments, load-bearing assumptions, failure modes — the reasoning IS the product. |

Then adjust for the artifact in front of you: its size, how coupled it is, and how expensive a wrong verdict would be. State the chosen tier and the reason in the dispatch summary.

**User override:**

| User wording | Resolved tier |
|--------------|---------------|
| nothing specified | per-type starting tier above |
| "hard", "deep", "thorough", "rigorous", "careful" | `smart` |
| "default", "balanced" | `default` |
| Explicit model name (e.g., `opus`, `sonnet`) | Use verbatim — do not remap |

**Mismatch check:** if the user picks a tier the artifact will defeat — `cheap` for `freeform` or for a large coupled plan — say so before dispatching; likewise flag `smart` for plain `facts` grep work as overspend. Ask on mismatch per `agent-delegate`.

## Process

1. **Parse the invocation.** Extract:
   - Artifact type(s) — one or more of `plan` / `dag` / `facts` / `freeform`.
   - Artifact content or file path.
   - Tier override (if any).
   - "Hard" / "deep" / "thorough" keyword → upgrade tier.

2. **For each artifact:**
   - Read the artifact content (from file, or inline from the user's message). When the review needs git context — a diff or a historical change — resolve the platform per `scm-detect`.
   - Build a self-contained review prompt using the type's template (see Prompt Templates below).
   - Resolve the tier per artifact from what that review demands (see Model Tier; user override wins; mismatch check if needed).

3. **Dispatch in parallel.** Single message, one subagent dispatch per artifact. Parameters:
   - **Fetch `agent-delegate-harness-<provider>` before the first dispatch** — a missed read is silent. Parameters per that reference.
   - An exploration (read-only) subagent, with a short description (e.g., `"Fact-check auth claims"`), the self-contained review prompt, and the resolved tier.
   - No worktree isolation (not needed), and no permission setting — reviewers are read-only and run under the session's own posture.
   - **Make sure the verdict can arrive.** A reviewer's verdict *is* its entire deliverable. Collect it however the runtime delivers a finished agent's report — blocking where the runtime offers it, a completion in a later turn where it does not — and add a delivery instruction to the review prompt only where the harness reference says the runtime needs one.

4. **Collect every verdict before relaying.** A reviewer that goes quiet or reports itself idle has **not** failed and has **not** returned an empty verdict — it has most likely answered where you cannot see it. Steer it per `agent-delegate` and the harness reference's ladder before considering it failed, and never substitute your own judgement for a verdict that has not arrived.

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

- **Reap the reviewer once its verdict is in**, per `agent-delegate` Reaping — including before re-dispatching a reviewer on a revised artifact, so an old verdict cannot arrive after the new one and be mistaken for it.
- **Tier by demand, not by habit.** Mechanical verification goes cheap; judgment work does not. A cheap reviewer on a nuanced artifact returns a verdict it was never able to reach.
- **One reviewer per artifact.** No ensemble. If the user wants multiple reviewers on the same artifact, they invoke the skill multiple times.
- **Parallel fan-out over artifacts.** Multiple artifacts = single message, one subagent dispatch per artifact.
- **Read-only.** Reviewers never modify files. An exploration subagent enforces the read-only disposition.
- **Structured output.** The `VERDICT` / `FINDINGS` shape is machine-parseable so `plan-hard` can extract FAILs for its correction loop.
- **Don't auto-apply suggestions.** The reviewer suggests; the user (or the inviting skill) decides what to do.
- **Cite evidence.** Every finding should name a file path, line number, or concrete piece of evidence. Unsourced claims are themselves a review failure.

## Related Skills

- **`agent-delegate`** — running a task rather than reviewing an artifact.
- **`agent-plan`** — its DAG is a `dag` artifact to review before launch.
- **`plan-hard`** — invokes a `facts` review to fact-check self-answered claims.
