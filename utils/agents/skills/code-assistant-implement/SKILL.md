---
name: code-assistant-implement
description: Implement the next agreed-upon step from an assistant plan, self-evaluate, then stop for user review. Always manually invoked. Do NOT use for planning (code-assistant) or evaluating progress (code-assistant-evaluate).
interaction: chat
disable-model-invocation: true
---

## system

### Counterassistant Mode: Step-by-Step Implementation with Review Gates

> **DO NOT enter plan mode. Exit plan mode immediately if currently in it.**
>
> - Use `ExitPlanMode` if you are in plan mode.
> - This skill is the implementation counterpart to the `code-assistant` skill.
> - A plan from `code-assistant` mode MUST already exist before invoking this skill.

### Prerequisites

- The `code-assistant` skill must have been used to create and agree on a plan.
- A plan file must exist in `~/.claude/plans/` for the current task.
- If no plan exists, STOP and tell the user to run `code-assistant` first.

### Process

1. **Read the plan.** Find the current plan file in `~/.claude/plans/`. Identify the next incomplete step.
2. **Implement the next step only.** Execute exactly one step from the plan. Do not look ahead or implement anything beyond the current step.
3. **Self-evaluate.** Invoke the `code-assistant-evaluate` skill on your own changes to assess correctness and alignment with the plan.
4. **Stop and present results.** Output what you implemented, the evaluation findings, and ask the user to review.
5. **Wait for user decision.** After the user reviews:
   - If the user approves and asks to continue → repeat from step 1 for the next step.
   - If the user rejects or wants to refine → enter plan mode and invoke the `code-assistant` skill to bring the next step up in detail before attempting it again.

### Key Principles

- **One step at a time.** Never implement more than the current step.
- **Always self-evaluate.** Never skip the evaluate step.
- **Stop after each step.** Never continue to the next step without explicit user approval.
- **Defer to assistant on rejection.** If the user is not satisfied, go back to planning — do not retry implementation on your own.

### Related Skills

- **`code-assistant`** (resource: `skills://skill/code-assistant`) — prerequisite. A plan from assistant MUST exist before this skill runs. Auto-invoke if no plan file exists and the user requests step-by-step implementation.
- **`code-assistant-evaluate`** (resource: `skills://skill/code-assistant-evaluate`) — self-evaluation after each step. Invoked automatically as part of the code-assistant-implement process.
