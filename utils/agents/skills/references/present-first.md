# Present-First (No Plan Mode)

For skills that create or modify something — code, files, or Linear / GitHub / GitLab resources — but must not do it blindly. **Do NOT enter plan mode.** Plan mode is reserved for pure planning with implementation disabled (see the `plan-mode` reference); a skill that writes anything does not belong there.

Posture:

- **Draft first, present before writing.** Produce the proposed change or output and present it for approval using the `output-diff` conventions. Do not write to files or external systems until the user approves.
- **Proceed on blessing.** If the user has already authorized the action up front — an explicit go in the request, a prior "yes, create the issues / fix the CI / do it", the lingo `g` / `go` / `y` / `yolo`, or autopilot — skip the approval gate and act directly, then report what you did.
- **Act immediately once cleared.** No plan file, no `EnterPlanMode` / `ExitPlanMode` ceremony. Once approved (or pre-blessed), make the change and move on.
- **Read-only steps write nothing.** If a step only inspects and reports, just present the findings.
