---
name: agent-resolve
description: agent-resolve Drive a plan to a fixed point with no interview - plan it yourself, review it, fan research agents out on every open question, fold answers back and re-review until nothing moves, then one final pass over the settled plan. Use on "resolve the plan", "plan until settled", "converge the plan". Not for a guided interview, one review pass, or executing a plan.
disableModelInvocation: true
argumentHint: '[the task or an existing plan path]'
references:
  - ../references/plan-mode.md
  - ../references/long-running-work.md
  - ../references/mode-toggle.md
  - ../references/output-status.md
  - ../references/agent/agent-fan-out.md
  - ../references/agent/agent-delegate.md
  - ../references/harness/agent-delegate-harness-claude.md
  - ../references/harness/agent-delegate-harness-codex.md
  - ../references/harness/agent-delegate-harness-opencode.md
  - ../references/harness/provider-paths.md
---

**Enter plan mode for the whole run** per `plan-mode`, including the `plan-hard` draft; the plan file is the only write.

## Context

A plan with open questions in it is not finished. `plan-hard` auto mode drafts, reviews once, and hands the residual to the user. This skill keeps going: every open question the draft or a reviewer raises becomes a research unit, the answers are folded back, and the plan is reviewed again — until a round produces no new findings. Only what no agent can answer from evidence reaches the user.

State that spans rounds is written durably per `long-running-work`; the plan file is the anchor, and each round's ledger lives in it.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** `/agent-resolve`, "resolve the plan", "plan until settled", "converge the plan".
- **Off:** the plan is presented after the final pass, or any stop or park signal.
- **Survives disengage:** the plan file with its round ledger. Research agents do not — reap each once its answer is in.

## Process

1. **Draft.** Load `plan-hard` and run its auto mode to produce the first draft — no interview, and still inside this run's plan mode. When given an existing plan path instead, that file is the draft. Write it to the internal plans directory per `provider-paths`.
2. **Review.** Load `agent-review` and dispatch `type=plan` on the draft, plus `type=facts` on the claims it rests on; both lenses go out in one message.
3. **Collect the open set.** Every reviewer FAIL, CONCERN and QUESTION, every branch the draft left as an assumption, and every unknown the draft names, deduplicated. Classify each:
   - **Researchable** — evidence exists somewhere: the codebase, another repo, docs, the live system, the web.
   - **Intent** — only the user can answer it. Park it in the residual; never research a preference.
4. **Research.** Fan the researchable set out per `agent-fan-out`: one unit per question, independent units in one wave, read-only agents. Dispatch mechanics per `agent-delegate`; fetch `agent-delegate-harness-<provider>` before the first dispatch, and collect every answer the way that reference says the runtime delivers it — diagnose a silent agent before re-dispatching it. Each brief asks for the answer, its evidence with paths or URLs, and a confidence; answers come back to you and you write the plan.
5. **Fold back.** Revise the plan from the answers. An answer that contradicts a decision re-opens that branch; an answer that raises a new question adds it to the next round's open set. Record the round in the plan's ledger: what was asked, what was found, what changed.
6. **Loop.** Return to step 2 on the revised plan, reviewing only what this round changed plus anything it touched. The plan has **settled** when a round's review and research change nothing — no new findings, no re-opened branch, an empty researchable set. Report each round's close per `output-status`; mid-round progress is one line.
7. **Cap the loop.** Three rounds without settling means the plan is oscillating or the question is underspecified. Stop looping, and carry the still-moving items into the residual with what each round found.
8. **Final pass.** Once settled, read the whole plan top to bottom yourself, end to end, as its executor would: every step has a target, every decision a reason, no step contradicts another, verification covers every requirement, and the skill chain the executor runs is named. Fix what the pass finds; a fix that changes a decision runs one more review round instead.
9. **Present and stand down.** The plan, the rounds it took, and the residual in one batch — intent questions each with a recommended answer, plus the items the cap carried over. Stay in plan mode until the user gives a proceed signal, unless the run was invoked as `autopilot`.

## Key Principles

- **Evidence closes a question, a reviewer's opinion does not.** A CONCERN is closed by research or by a recorded decision, never by dropping it.
- **Research is read-only.** Agents gather and cite; only you edit the plan.
- **Review what moved.** A full re-review every round spends tokens rediscovering settled branches.
- **The user sees the residual once**, at the end — not a question per round.

## Example

**Trigger:** "/agent-resolve move the session store from cookies to Redis."

1. `plan-hard` auto drafts it; the draft assumes the Redis client supports TTL refresh and leaves eviction policy open.
2. Review returns CONCERNS: no migration path for live sessions; QUESTION on whether another service reads the cookie.
3. Research wave of three: client TTL behaviour from its docs, cross-repo readers of the cookie, current session count from the live system.
4. Fold back: one other service reads the cookie, so a dual-read migration step is added; the TTL claim holds.
5. Round 2 review on the migration step finds the dual-read window unbounded; one research unit finds the max session lifetime, bounding it.
6. Round 3 changes nothing. Final pass catches a verification step missing for the second service; added.
7. Present: settled plan in three rounds, one intent question — cut over on a weekday or the weekend window.

**Result:** a plan whose every open question was closed with evidence, and one decision left for the user.
