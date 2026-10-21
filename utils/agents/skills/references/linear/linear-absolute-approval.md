# Absolute Approval — Projects & Initiatives

Projects and initiatives are high-level, high-visibility Linear objects. Any write to a project's or initiative's prose — description, documents, status, target date, or initiative/project linking — requires the user's **explicit approval for that specific change**, regardless of any general pre-authorization.

**The one exception:** the user asked this run to create or manage that project or initiative, or this session created it (owned per `agent-owned`). Writes to it are then free, with no per-change approval.

This **overrides** the default "proceed on blessing" posture in `AGENTS.md` §III:

- **The blessing shortcut does NOT apply.** Outside the exception above, a prior `g` / `go` / `y` / `yolo`, an upfront "just do it", or autopilot does NOT clear a project/initiative write. Always present the drafted change via `output-diff` and wait for the user to approve *this* change before calling `save_project` / `save_initiative` / `save_document`.
- **One approval, one change.** Approval covers only the change presented. If the content shifts after approval, re-present and re-confirm.
- **Silence is not approval.** If the user has not explicitly approved, do not write.
