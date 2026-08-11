---
name: agent-autopilot
description: agent-autopilot Autonomous posture: drive the whole workflow end to end after one upfront discovery pass, asking every blocking question at the start and then proceeding without interruption. Use on "autopilot", "finish this PR", "take it all the way". Not for pushing through a stuck task by force, and not for routing work to subagents while staying hands-off.
disableModelInvocation: true
references:
  - ../references/mode-toggle.md
---

## Autopilot

Permission to drive the whole workflow after an upfront discovery pass. The trade is front-loaded questions for an uninterrupted run: every intent and blocking question gets asked at the beginning, and after that you proceed independently.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** the lingo `autopilot`, or natural language that plainly means it — "take it all the way", "finish this without asking me", "drive it end to end".
- **Off:** "stop", "hold", any park signal, or the stated scope completing. Report and stand down.
- **Survives disengage:** nothing armed by this mode. Account for spawned agents and watchers before standing down, per `mode-toggle`.
- Layers under every other mode. It does not turn coordinator, supervisor, or bulldozer on.

## The Upfront Pass

Three steps before any implementation. On work below the plan-mode threshold in `AGENTS.md` §II, a short scoping pass replaces steps 1 and 2.

1. **Plan with yourself — never enter plan mode.** Load `plan-hard` and run its delegated refinement mode: self-answer every branch the codebase can answer and pick your recommended answer for the rest. An interview and an approval gate are exactly what this mode exists to avoid, so the plan-mode carve-out in `plan-mode` applies.
2. **Review the plan at a higher tier.** Dispatch `agent-review` with `type=plan` at the `smart` tier or above, and `type=facts` as well when the plan rests on factual claims. Tier-to-model resolution and dispatch mechanics per `agent-harness`, loaded before the first dispatch. Fold the findings back in and re-open any branch the reviewer faults.
3. **Ask everything blocking, once.** Bring only the residual to the user: the genuine intent and preference questions the reviewer could not resolve, plus the assumptions you made. This is the only place the mode spends the user's attention, so spend it in one batch.

## While Running

- **Minimize interruptions.** Stop only for genuinely blocking ambiguity, destructive actions, credentials or secrets, or an external approval the user did not authorize.
- **Use subagents freely** for research, independent implementation slices, validation, and plan review when they materially reduce risk.
- **Verify before declaring completion.** On non-trivial work run `agent-review` or an equivalent validation pass.
- **Carry an end-to-end framing all the way.** "Finish this PR/MR/issue" means understand, plan, implement, verify, update durable context, and report the final state.
- **Record deviations, do not interrupt for them.** When implementation diverges from the plan or the conversation, note it and report it at the end with rationale and verification.
- **Keep repository guidance current** through `config-repository` when additive, obvious, durable learnings emerge.

## What Autopilot Does Not Authorize

**Destructive actions still need their own blessing** — force pushes, discarding uncommitted work, deleting non-reproducible data, dropping resources others depend on, publishing externally. The mode removes pauses on ordinary work; it grants nothing irreversible. Anything you cannot confirm is reversible is irreversible.

External writes the user never authorized are the same: autopilot covers the class of write the task obviously implies, not a new audience.
