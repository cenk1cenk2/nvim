# Present-First

The posture for a skill that declares it — one whose writes publish to people, shape every later session, or create a project. Every other skill acts, then reports what changed. The `present-first` skill toggles it.

- **Draft, present per `output-diff`, then write.** Not before approval.
- **One gate per artifact, not per file.** Fifteen files, one presentation.
- **Once cleared, act.** No re-confirming.
- **Reads never gate.** A step that only inspects just reports.

**Already approval** — skip the gate, act, report: an explicit go ("do it", "go ahead"), the lingo `g` / `go` / `y` / `yolo` / `blessed`, a prior yes covering this same change, `autopilot`, or **the user invoking the skill explicitly** (`/name`, or naming it) for the writes it performs on the target they gave. An approval also covers the follow-up adjustments that same change needs in that run. A blessing is **scoped to the run it was given in** — not the next separate change — unless the captain widened it to the session ("blessed for the session"), which then stands for the same or similar actions until they say otherwise.

## Destructive actions are outside all of that

Irreversible: force pushes, discarding uncommitted work, deleting or overwriting non-reproducible data, dropping resources others depend on, publishing to an external audience.

**No general go authorizes one** — not `yolo`, not autopilot, not a prior yes, not the toggle being off. Each needs explicit approval, either:

- **per case** — confirmation naming the exact target and what is lost, or
- **per scope** — a standing exception the user scoped themselves ("force pushing is fine on this repo"), valid for that scope only.

Rewrites and cleanup on an agent's own branch are a standing per-scope exception, per `agent-owned`.

Cannot tell if it's reversible? Treat it as not.

## Toggle off

"just write it" / "skip the gates". The skill still drafts and reports; it stops pausing. Unaffected: destructive actions (above), any skill's own stricter gate, and the fact that off removes a pause rather than granting authorization.
