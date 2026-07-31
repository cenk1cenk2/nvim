---
name: hyprpilot-harness
description: 'hyprpilot-harness Delegate a task to a separate hyprpilot agent session (claude/codex/opencode) over the hyprpilot_harness MCP server, then steer it across turns. Use on "delegate this to hyprpilot", "spawn a hyprpilot agent", "send this to personal/claude/opus", "list hyprpilot sessions", "steer that session", "kill that agent". Covers profile discovery, spawning blocking or detached, multi-turn steering, following output live, and cleanup. Do NOT use for subagents inside this harness (use /agents-delegate) or to reload the skill catalog (use /hyprpilot-reload).'
disableModelInvocation: true
argumentHint: "[task] [optional: profile name or fragment, e.g. 'personal glm-5.2']"
references:
  - ../references/present-first.md
  - ../references/agents-conventions.md
  - ../references/project-tooling.md
  - ../references/agents-completion.md
---

## Hyprpilot Agent Harness

> **Present-first.** Read the `present-first` reference — draft the delegation and present it before spawning; proceed on approval or upfront blessing. `spawn` runs a profile's `command` as this user, so it is never a silent action.

> Read the `agents-conventions` reference when the delegated task writes code — the spawned agent needs the local patterns named in its prompt.
> Read the `project-tooling` reference when the task writes code — for the verification commands to hand the agent.
> Read the `agents-completion` reference if the user wants to commit/push/PR after the session reports back.

## Context

This skill delegates to a **separate hyprpilot agent process** — a different CLI (`claude` / `codex` / `opencode`), a different model, its own session and transcript — reached over the `hyprpilot_harness` MCP server.

**This is not the same as `/agents-delegate`.** That spawns a subagent *inside the current harness*, sharing this runtime and its model tiers. This spawns an independent hyprpilot session that survives your turn, keeps its own conversation, and can be steered across many turns. Reach for this one when the user names hyprpilot or a profile, when the work wants a different vendor or model than the current session, or when the job needs to be driven over time rather than answered once.

**Availability.** The tools live on the `hyprpilot_harness` MCP server. If they are absent, the harness is not enabled for this session — say so and stop; do not fall back to shelling out to the `hyprpilot` CLI, which is one-shot and cannot be steered.

## Tools

| Tool | Purpose |
|------|---------|
| `hyprpilot_harness__list_profiles` | Discover launchable profiles. Always first. |
| `hyprpilot_harness__spawn` | Start a NEW session from a profile. Returns a `session` handle. |
| `hyprpilot_harness__session_send` | Send another turn to an existing session. The steering tool. |
| `hyprpilot_harness__session_read` | Read or follow a session's transcript. |
| `hyprpilot_harness__session_list` | List sessions — recover a handle you lost. |
| `hyprpilot_harness__session_kill` | Stop a running session, or reap a finished one. |

## Process

1. **Discover the profile — never hardcode an id.**
   - Call `list_profiles` first, every time. Profile ids are captain-defined and change; a hardcoded id silently breaks.
   - **Match the user's phrasing loosely.** Ids are path-like (`personal/claude/opus`, `work/claude/sonnet`, `personal/kilic/glm-5.2:cloud`) and users say them in fragments. "delegate this to hyprpilot personal glm-5.2" means the id containing both `personal` and `glm-5.2`.
   - **Ambiguous match → ask.** If a fragment matches two profiles, list the candidates and ask; do not guess. If it matches none, show what is available.
   - **A row carrying an `error` field failed to resolve — do not launch it.** Report the error instead.
   - `list_profiles` also carries `provider`, `model`, `effort`, `mode`, `cwd`, and MCP/skill counts. Use them to sanity-check the pick, and to warn the user when a profile is `headless` (it cannot be driven interactively) or points somewhere unexpected.

2. **Brief the agent properly.** The spawned agent has NO access to this conversation. Its prompt must be self-contained: the goal, the repo/paths, the constraints, and what "done" looks like. If it writes code, include the conventions and verification commands from the references above. A thin prompt produces a thin result and costs a whole session.

3. **Present, then spawn.** Show the resolved profile, the working directory, and the prompt. On approval call `spawn { profile, prompt|file, cwd?, mode?, wait?, timeout_seconds?, args?, with_config? }`.
   - **Use the dedicated parameters first.** `cwd`, `mode`, `wait`, `timeout_seconds`, `file`, and `args` are all top-level parameters — reach for them directly. `with_config` is the last resort, for the settings that have no dedicated parameter of their own (`model`, `effort`).
   - `wait` defaults `true`; `timeout_seconds` defaults `300`.
   - **`prompt` and `file` are mutually exclusive.** `file` takes a path (`~` and `$VAR` expanded) whose contents become the prompt — prefer it for a long brief instead of inlining one.
   - **`mode` overrides the profile's mode.** `mode: "plan"` yields a genuinely read-only agent that refuses to edit. **Reach for it on every read-only delegation** — it is the cheapest safety lever this tool has and costs nothing to add.
   - `with_config` is an **array of overlay objects** — `with_config: [{ "model": "…" }]`, not a flat object. It accepts **only** `model`, `effort`, `mode`; every other key is refused by design, because an overlay reaching the command, its arguments, its environment, or the MCP servers it launches would turn `spawn` into arbitrary command execution. To run something else, add a profile for it.
   - **An overridden model is not visible as the profile.** Results and `session_list` keep reporting the profile id; only `sessionInfo.model` carries what actually ran. Check it before reporting which model did the work.
   - **Address files by absolute path in the prompt.** Do not make the agent's output depend on resolving anything relative to the working directory.
   - Record the returned `session` handle and report it to the user. It is how every later turn addresses this agent.

4. **Run detached with `wait: false`** — when the job is long, when fanning out several agents at once, or when the user says "check on it later".
   - It returns immediately with `status: running`, `nextOffset: 0`, and **`vendorSessionId: null`** — the vendor id does not exist until the turn produces it. The handle itself is usable straight away.
   - **Nothing wakes you when it finishes.** Detached work completes into silence; you must come back with `session_read` or block on a follow. Never leave a detached agent unread — that is how a finished result gets thrown away and the job re-run.

5. **⛔ A timeout is NOT a failure and NOT a cancellation.**
   - If the turn outlives `timeout_seconds` the result returns `status: running` and **the agent keeps working.**
   - **Poll or follow `session_read` with the handle. NEVER call `spawn` again** — that starts a second, unrelated agent and abandons the first. This is the single most common way to get this wrong.
   - Follow live with `session_read { session, wait: true, offset: <nextOffset>, timeout_seconds? }`. A follow returns everything it saw and ends when the agent finishes, when the request is cancelled, or at `timeout_seconds`.

6. **Collect the result deliberately — this is where the work gets lost.**
   - `session_read` returns the vendor's raw JSON event stream, and **the answer sits in a different event per vendor** — a terminal `type: "result"` event carrying the final text and run totals on some, the last `type: "text"` event on others. Scan from the end for whichever the vendor emits; the `tool_use` events in between can be enormous.
   - **Read in modest windows.** A read caps its own payload and reports `truncated: true`; when it trims it keeps the newest part of the window and drops the oldest, while `nextOffset` still advances past what was dropped. Offsets only move forward, so follow with a short `timeout_seconds` or page with `tail` rather than pulling one huge window.
   - **Read the result BEFORE sending the next turn.** A new turn appends to the same transcript and pushes the previous answer out of the tail.
   - `tail` (default 200 lines) returns the trailing lines when `offset` is omitted — the quick way to ask "is it done, and what did it say".

7. **Steer across turns with `session_send`, not `spawn`.**
   - **A conversation is ONE session.** `session_send { session, prompt }` reuses the handle and appends to the same transcript, so the agent retains everything from earlier turns.
   - Each turn runs as a **fresh process resumed against the vendor's own session store** — the pid changes, `startedAt` stays put, `lastTurnAt` moves. That is why a session that already exited can still be steered rather than lost; the result's `delivery` field reports what happened (`resumed`).
   - It inherits only the **profile**. `cwd`, `mode`, `with_config` and `args` are NOT carried forward — pass them again on each turn if the work needs them.
   - **One turn at a time.** A `session_send` against a session that is still working comes back as a tool **error** — "already has a turn in flight" — not a queued message. Poll `session_read` until it exits, or `session_kill` it first.

8. **Recover a lost handle with `session_list`.** It returns every session this server owns — handle, profile, status, exit code, cwd, timestamps. Use it when the user refers to "that agent" and the handle is not in context, and present the list so they can pick.

9. **Finish deliberately with `session_kill`.**
   - **Running** → `action: "terminated"`. The agent and everything it started is stopped, and **the transcript is kept** so you can still read why.
   - **Already finished** → `action: "reaped"`. The transcript and the handle both go, and any later read fails with `unknown session`.
   - Calling it twice is the natural stop-then-clean-up. Read anything you care about before the reap.
   - Kill runaway sessions, and reap a finished one to free a slot when `spawn` reports the concurrency ceiling.

10. **Report back.** Give the user the outcome, the handle (so they can continue), and the exit status. If the session is still running, say so plainly and tell them it can be followed or steered — do not present a timed-out turn as a finished result. **A non-zero `exitCode` is not automatically the agent's fault**: the transcript may carry an upstream `error` event (auth, quota, model availability). Read it and say which before re-dispatching.

## Semantics that bite

- **Sessions die with the MCP server and do not survive a restart.** There is no persistence. If the sidecar restarts, running agents are killed and transcripts are lost. Treat a chain as living only as long as this MCP connection — capture anything that must outlive it before the turn ends.
- **Bounded retention.** The oldest **finished** sessions are evicted along with their transcripts (default ceiling 64). A running session is never evicted. Read a transcript you care about before it ages out.
- **Bounded breadth and depth.** A session-count ceiling bounds concurrency; `HYPRPILOT_SPAWN_DEPTH` bounds how deep a spawned agent can itself spawn. Hitting either returns an error — free a slot with `session_kill` rather than retrying blindly.
- **`spawn` executes as this user.** A profile's `command` is an arbitrary binary and its `provider` picks a flag projection, not a sandbox. This is why the skill is present-first and manual.

## Examples

**User says:** "delegate this to hyprpilot personal glm-5.2 — refactor the retry logic in src/api/client.ts"

1. `list_profiles` → the fragment matches `personal/kilic/glm-5.2:cloud` (opencode, mode `build`).
2. Read the conventions/tooling references; build a self-contained prompt naming the file, the neighbouring patterns, and the test command.
3. Present the profile, cwd, and prompt → user approves.
4. `spawn { profile: "personal/kilic/glm-5.2:cloud", prompt: "…", cwd: "…" }` → handle `s-3f2a`, `status: exited`.
5. Report the result and the handle.

**Result:** Work done in a separate opencode session; handle available for follow-ups.

---

**User says:** "that's not quite right, tell it to keep the existing backoff"

1. Reuse the handle from the previous exchange — `session_send { session: "s-3f2a", prompt: "Keep the existing backoff curve; only change the retry ceiling." }`.
2. The session had exited, so it is resumed; the agent still has turn 1's context.

**Result:** Correction applied in the same conversation — no re-briefing, no second agent.

---

**User says:** "delegate this to hyprpilot and check on it later"

1. Resolve the profile, present, then `spawn { …, wait: false, mode: "plan" }` — detached, and read-only because the job only needs to look.
2. Returns instantly: handle `s-91c4`, `status: running`, `vendorSessionId: null`. Report that it is running and followable.
3. On "how's it going?" → `session_read { session: "s-91c4", offset: <nextOffset> }`. **Not** a second `spawn`.
4. When `status` reads `exited`, read the tail for the final `text` event and relay the answer before sending any further turn.

**Result:** Long job tracked to completion without abandoning it, duplicating it, or burying its result under a later turn.

## Key Principles

- **`list_profiles` first, always.** Never hardcode an id; never guess an ambiguous fragment.
- **`spawn` once per conversation; `session_send` for every follow-up.**
- **Dedicated parameters before `with_config`.** Reach for `with_config` only for `model` and `effort`.
- **`mode: "plan"` for anything read-only.** Free, and it removes write authority instead of asking for it.
- **A timeout means still working.** Follow it; never re-spawn.
- **Detached work finishes into silence.** Read every session you start; collect the answer before steering it again.
- **Self-contained prompts, absolute paths.** The agent cannot see this conversation.
- **Present before spawning.** It runs commands as this user.
- **Report the handle.** A handle the user does not have is a session they cannot steer.
