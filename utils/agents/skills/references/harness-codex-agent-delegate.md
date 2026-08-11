# Harness: Codex — agent-delegate

Runtime mechanics for delegation on Codex — how subagent dispatch behaves, plus the model roles. Read this before the first dispatch of a session running on Codex. For waiting and waking, see `harness-codex-agent-background`.

**Dispatch:** Codex's own task/subagent spawning. Set the resolved `gpt-*` model.

## Model roles

No cheap→max ladder is configured — two role models, both `reasoningEffort: high`:

| Role | Model |
|------|-------|
| general (default) | `gpt-5.5` |
| coding-specialized | `gpt-5.3-codex-spark` |

Mirrors the `personal/codex/*` profiles in `~/.config/hyprpilot/config.yaml` and the `openai` provider in `~/.config/opencode/opencode.jsonc`. Keep in sync when those change. If a cheap/default/smart/max ladder is needed later, add it here and to those profiles.

## Background work does NOT wake you

**This is the defining difference from Claude Code.** A background subprocess or subagent on Codex completes without informing the calling agent — no notification, no re-invocation (`openai/codex` #15723, open, filed against codex-cli 0.116.0). The caller either polls for the result or waits for the user to ask.

Everything follows from that:

- **Never dispatch detached and end the turn expecting a wake.** Nothing will arrive. The pattern that works on Claude Code silently drops the work here.
- **Poll explicitly** — a background terminal is checked by writing an empty string to its stdin and reading what comes back.
- **Prefer blocking dispatch** whenever the result matters, since blocking is the only delivery you can count on.
- **Have long work write to a file**, so a lost result is recoverable by reading the artifact rather than by re-running the task.

Because completion never re-invokes the session, a Codex run has no equivalent of "arm a watcher and stop thinking about it": every wait is either a blocking call or an explicit poll you must remember to make.

## Collecting a report — poll or block, and write to a file

Since completion never re-invokes the session, **there is no notification carrying a result and no post-hoc channel to a finished agent**. The collection ladder in `agent-delegate` loses its nudge rung here for the same reason it does on OpenCode: nothing is listening once the work ends.

- **Blocking dispatch is the only delivery you can count on** when the report matters.
- **Specify the report's shape in the prompt**, since there is no follow-up round to ask for the diff you actually wanted.
- **Have the work write its report to a file.** On this runtime the file is the primary artifact rather than a backup — a result you never polled for is simply lost, and the file is what makes it recoverable without re-running.
- **A quiet background task is not a failed one.** It finished into silence by design. Poll it before concluding anything.

When a report is thin, the fallbacks are the file, the artifact on disk, and a re-dispatch with a tighter deliverable — never assuming the work did not happen.

## Waiting and scheduling

- **No native deferred-wakeup and no cron.** For recurring runs, wrap `codex exec` in an OS cron job or a CI schedule.
- Codex offers a first-class interruptible sleep primitive suitable for a bounded sleep-loop, unlike harnesses where foreground sleeping is blocked.

> **Unverified — confirm against the installed build.** The exact tool names for background terminals and sleep are unconfirmed against current Codex documentation; upstream issue text uses `exec_command` for that capability. Codex ships fast (700+ releases), so check the running version's own tool list rather than trusting a name from this file.
