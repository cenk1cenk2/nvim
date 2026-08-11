# Plan Mode (Strict)

Plan mode is for **meticulous planning and analysis with implementation fully disabled.** Only skills that declare this reference enter it; every other skill works under the default posture in `AGENTS.md` §II and says nothing about plan mode.

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Enter plan mode immediately.
> - **Implementation is disabled for the entire skill.** Do NOT write code or modify any external system.
> - **The single exception is the plan file itself** — writing it to your internal plans directory (`provider-paths`) is the point of the mode, not a violation of it. Nothing else may be written anywhere.
> - **NEVER exit plan mode** until the user gives an explicit, unambiguous implement signal ("implement this", "start coding", "write the code", or the lingo `g` / `go` / `y` / `yolo`).
> - When unsure whether the user wants implementation, ASK. When in doubt, STAY in plan mode.
> - Produce the plan/analysis, present it, and wait for direction. You are a planner, not an implementer.

## "Plan with yourself" — no mode at all

**When the user asks you to plan *with yourself* — "plan with yourself", "with yourself", "think it through yourself", "plan it on your own", "figure it out yourself" — do NOT enter plan mode.** Not the harness mode, not the strict posture above.

The ask is for the planning to happen internally and come back as an answer. Entering the mode makes it a session state the user then has to exit, which is the thing they declined.

- **Self-answer every branch.** No interview, no one-question-at-a-time traversal — resolve what the codebase resolves, pick a recommended answer for the rest, and flag what you assumed.
- **Present the plan in chat** as an ordinary reply, then stop.
- **Write a plan file only if the user asked for one.**
- **Implementation still waits for a proceed signal.** Self-planning replaces the mode, not the gate on writing.
