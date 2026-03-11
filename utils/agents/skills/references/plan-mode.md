# Plan Mode Directives

## Strict Variant (Research/Planning Skills)

Use this variant for skills that research, plan, and draft — but should NOT implement unless the user explicitly asks.

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Use `EnterPlanMode` tool immediately.
>
> **ABSOLUTE RULE: NEVER EXIT PLAN MODE. NEVER USE `ExitPlanMode`.**
>
> - You MUST stay in plan mode for the ENTIRE duration of this skill.
> - There is NO circumstance where you should call `ExitPlanMode` — not even if the user seems to imply it.
> - Only the user saying the EXACT words "implement this", "start coding", "write the code", or an equally explicit and unambiguous direct instruction to implement should cause you to exit plan mode.
> - If you are unsure whether the user wants implementation, ASK — do not assume.
> - **When in doubt, STAY in plan mode.**
>
> **CRITICAL: This is a research and planning workflow — NOT implementation.**
>
> - Do NOT implement or write code — EVER — unless the user EXPLICITLY and UNAMBIGUOUSLY asks you to implement.
> - Do NOT exit plan mode and start implementation automatically.
> - After completing the skill's workflow, present the results and wait for user direction.
> - You are a RESEARCHER and PLANNER, not an implementer.

## Standard Variant (Implementation Skills)

Use this variant for skills that plan first, then implement after user approval.

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Use `EnterPlanMode` tool immediately.
> - Create plan file in `~/.claude/plans/YYYY-MM-DD-<project>-<name>.md`.
> - Present the plan to the user and iterate based on feedback.
> - Exit plan mode and begin implementation only after the user explicitly approves.
