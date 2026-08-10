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
