# Opening an Artifact

When a finished artifact — an MR, a PR, an issue, a file — is put in front of the captain with `hyprpilot__open`.

## The lead opens, never a delegated agent

**A subagent must never call `open`.** Timing is a judgment about what the captain is ready to look at, and a subagent cannot make it — it does not know what else is still running, what still needs verifying, or what the captain said they would handle themselves. The lead opens once, after collecting the result.

## Default — hold until everything is done

**Open last.** Finish the changes, the verification, and any remaining task in the same request first. An artifact opened mid-flow puts a half-done thing on screen and reads as finished. Then open once, and say what was verified.

## Exception — the captain said they will check it themselves

When they say they will look at it, review it, or check it themselves, **open it early so they can start** — and **warn in the same breath** that the work is not done and what is still outstanding. The warning is what makes the early open safe; without it the artifact reads as complete.
