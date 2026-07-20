# Absolute Approval — Projects & Initiatives

Projects and initiatives are high-level, high-visibility Linear objects. Any write to a project's or initiative's prose — description, documents, status, target date, or initiative/project linking — requires the user's **explicit approval for that specific change**, regardless of any general pre-authorization.

This **overrides** the `present-first` "proceed on blessing" clause:

- **The blessing shortcut does NOT apply.** A prior `g` / `go` / `y` / `yolo`, an upfront "just do it", or autopilot does NOT clear a project/initiative write. Always present the drafted change via `output-diff` and wait for the user to approve *this* change before calling `save_project` / `save_initiative` / `save_document`.
- **One approval, one change.** Approval covers only the change presented. If the content shifts after approval, re-present and re-confirm.
- **Silence is not approval.** If the user has not explicitly approved, do not write.
