---
name: hyprpilot-delegate
description: 'hyprpilot-delegate Delegate a task to a separate hyprpilot agent session (claude/codex/opencode) over the hyprpilot_harness MCP server, then steer it across turns. Use on "delegate this to hyprpilot", "spawn a hyprpilot agent", "send this to personal/claude/opus", "list hyprpilot sessions", "steer that session", "kill that agent". Covers profile discovery, spawning blocking or detached, multi-turn steering, following output live, and cleanup. Do NOT use for subagents inside this harness (use /agents-delegate) or to reload the skill catalog (use /hyprpilot-reload).'
disableModelInvocation: true
argumentHint: "[task] [optional: profile name or fragment, e.g. 'personal glm-5.2']"
references:
  - ../references/present-first.md
  - ../references/hyprpilot-sessions.md
  - ../references/agents-conventions.md
  - ../references/project-tooling.md
  - ../references/agents-completion.md
---

## Hyprpilot Delegation

> **Present-first.** Read the `present-first` reference — draft the delegation and present it before spawning; proceed on approval or upfront blessing. `spawn` runs a profile's `command` as this user, so it is never a silent action.

> Read the `hyprpilot-sessions` reference for the full session surface — the two ways to drive a session (the session tools, and the SEP-2663 Tasks path for clients that support it), the completion signals and which applies to you, `sessionInfo.files`, per-vendor answer extraction, and the limits. **Read it before arming any wait**: a hyprpilot session is NOT an in-harness subagent, so the `agent-*` rule that dispatched work wakes you does not apply here.

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
| `hyprpilot_harness__session_status` | **The cheap poll.** State without reading the transcript. |
| `hyprpilot_harness__session_list` | List sessions — recover a handle you lost. |
| `hyprpilot_harness__session_kill` | Stop a running session, or reap a finished one. |

## Process

1. **Discover the profile — never hardcode an id.**
   - Call `list_profiles` first, every time. Profile ids are captain-defined and change; a hardcoded id silently breaks.
   - **The listing is the whole available set.** The harness is opt-in per profile (`[profiles.harness]`), so a profile the captain configured but did not nominate is absent here AND refused by `spawn`. If the user names one that is missing, say it is not on the harness rather than guessing a neighbour.
   - **Match the user's phrasing loosely.** Ids are path-like (`personal/claude/opus`, `work/claude/sonnet`, `personal/kilic/glm-5.2:cloud`) and users say them in fragments. "delegate this to hyprpilot personal glm-5.2" means the id containing both `personal` and `glm-5.2`.
   - **Ambiguous match → ask.** If a fragment matches two profiles, list the candidates and ask; do not guess. If it matches none, show what is available.
   - **A row carrying an `error` field failed to resolve — do not launch it.** Report the error instead.
   - **What the listing actually returns is `id`, `provider`, `agent`, `model`, `mode`, `headless`, `harnessEnabled`, `isDefault` — and nothing else.** There is no `cwd`, no `effort`, and no MCP/skill counts. Use what is there to sanity-check the pick and to warn the user when a profile is `headless` (it cannot be driven interactively). A profile's own working directory is **not knowable before launch**: it first appears as `sessionInfo.cwd` in the `spawn` result.

2. **Brief the agent properly.** The spawned agent has NO access to this conversation. Its prompt must be self-contained: the goal, the repo/paths, the constraints, and what "done" looks like. If it writes code, include the conventions and verification commands from the references above. A thin prompt produces a thin result and costs a whole session.

3. **Present, then spawn.** Show the resolved profile, the working directory, and the prompt. On approval call `spawn { profile, prompt|file, cwd?, mode?, wait?, timeout_seconds?, args?, with_config? }`.
   - **Use the dedicated parameters first.** `cwd`, `mode`, `file`, and `args` are all top-level parameters — reach for them directly. `with_config` is the last resort, for the settings that have no dedicated parameter of their own (`model`, `effort`). (`wait` / `timeout_seconds` are also top-level, but they describe how *you* wait, not the agent — see below.)
   - **`wait` defaults `false` — detached — and that is the right default. Leave it alone.** Opting into `wait: true` returns the **entire raw event stream inline**, every `tool_use` payload included, with no `tail` and no `cursor` to trim it: the same trivial three-item read-only task produced a **14 kB** transcript on opencode and a **121 kB** one on claude, all of it pushed through your context to deliver three lines of answer. It does not even buy certainty — a turn outliving `timeout_seconds` (default `300`) comes back `running` anyway. Reserve it for a genuinely short turn whose full trace you actually want; otherwise detach and collect just the answer (step 6).
   - **`prompt` and `file` are mutually exclusive.** `file` takes a path (`~` and `$VAR` expanded) whose contents become the prompt — prefer it for a long brief instead of inlining one.
   - **`mode` overrides the profile's mode.** `mode: "plan"` yields a read-only agent that refuses to edit — the cheapest safety lever here, and the default for a delegation that only needs to look. **Verified on opencode: plan mode strips nothing from the registry.** The plan agent listed every MCP server (24 of them, more than the same profile's build agent saw) *and* still listed `edit`, `write` and `task` — opencode gates plan mode at call time through `OPENCODE_PERMISSION`, it does not remove tools. So on opencode a read-only delegation keeps full MCP reach, and "the agent can see `write`" is not evidence the mode failed to apply. Do not generalise either half to claude or codex, where a mode can gate whole tool groups — on an unverified vendor, have the agent report its own tool registry in its first turn rather than assuming.
   - `with_config` is an **array of overlay objects** — `with_config: [{ "model": "…" }]`, not a flat object. It accepts **only** `model`, `effort`, `mode`; every other key is refused by design, because an overlay reaching the command, its arguments, its environment, or the MCP servers it launches would turn `spawn` into arbitrary command execution. To run something else, add a profile for it.
   - **An overridden model is not visible as the profile.** Results and `session_list` keep reporting the profile id; only `sessionInfo.model` carries what actually ran. Check it before reporting which model did the work. **`sessionInfo.mode` has the same blind spot in reverse:** it echoes the profile's mode, so a mode you imposed through `args` (opencode `--agent plan`) still reads `build` there. `sessionInfo.argv` is the only honest record of what launched.
   - **Address files by absolute path in the prompt.** Do not make the agent's output depend on resolving anything relative to the working directory.
   - Record the returned `session` handle and report it to the user. It is how every later turn addresses this agent.

4. **Detached is the normal mode, and the default.** It suits anything long, fanning out several agents at once, and every "check on it later".
   - It returns immediately with `status: running`, the `session` handle, and a `nextCursor` to resume reading from. **The handle is the whole identity** — minted before the agent produces a byte, unchanged across turns, and the only thing any tool accepts. There is no second id to wait for.
   - **Unless your client speaks SEP-2663 Tasks**, in which case the same `spawn` returns `resultType: "task"` and a `taskId` instead. That is the standard-protocol path to the same session, and it changes which tools you poll with. **Check the result, do not assume** — `resultType: "task"` means you are on it. No vendor CLI declares the extension today, so normally you are not. The `hyprpilot-sessions` reference has the full comparison and the rules that differ.
   - **⛔ Nothing will wake you. There is no completion push here.** The harness emits one, but it only lands on an interactive Claude Code lead with the channel registered — and registration was tried on this setup, did not work, and has been reverted. A client without it **drops the event silently, with no error**, which looks exactly like a hung agent. Plan for silence from the moment you spawn: arm a watcher or poll. Never treat "no news" as "still working".
   - **So watch `done.json` yourself.** A turn ending writes `done.json` into the session directory (`sessionInfo.files.dir`), and it is the one MCP-only truth a plain shell can reach. Arm it through your runtime's **own** background-exec facility — the one that re-invokes you when the command exits. Backgrounding inside the command (`&`, `nohup`, `disown`, `setsid`) hands the process to the OS and wakes nobody.

     ```bash
     D=<sessionInfo.files.dir>
     for i in $(seq 1 60); do
       if [ ! -d "$D" ] || [ -f "$D/done.json" ]; then echo "RESULT: turn finished"; exit 0; fi
       sleep 30
     done
     echo "RESULT: still running after 30 cycles"
     ```

     **Both halves of the test are required.** Reap, eviction and sidecar shutdown delete the whole directory, so testing only for the file waits forever on a session that was cleaned up — a missing **directory** means finished-and-gone.

     **⛔ Arm the watcher AFTER `spawn` / `session_send` returns, never before.** The marker is cleared when a turn *starts*, so anything armed ahead of the call still sees the previous turn's `done.json` and fires instantly on stale state — measured: a watcher armed before a `session_send` reported "turn finished" before the new turn emitted one event. The call returns once the turn is running and the marker is already gone, which makes its result the correct arming point.
   - **Want progress, not just completion? Stream `turns.jsonl`.** It is append-only, so tailing it gives an event per step while the agent works — no blocking call, no raw payloads in context. Arm it the same way and on the same schedule as the `done.json` watcher, capturing the file's byte offset *before* the send so the head of the turn is not lost. The `hyprpilot-sessions` reference carries the filter and opencode's event field paths; your runtime's `harness-<provider>-agent-background` reference owns whether it can run in the background at all.
   - **On wake, confirm through the harness.** `done.json` says the turn ended, not that it succeeded — read `session_status` for `exitCode` and `hasResult`, then collect per step 6.
   - Where no watcher can be armed, poll `session_status` by hand; it is cheap enough to repeat. What you must never do is leave a detached agent unread — that is how a finished result gets thrown away and the job re-run.

5. **⛔ A timeout is NOT a failure and NOT a cancellation.**
   - If the turn outlives `timeout_seconds` the result returns `status: running` and **the agent keeps working.**
   - **Poll with the handle. NEVER call `spawn` again** — that starts a second, unrelated agent and abandons the first. This is the single most common way to get this wrong.
   - **`session_status { session }` is the poll.** It reads no transcript, so it costs almost nothing to repeat: `status`, `exitCode`, `transcriptBytes`, `hasResult`. Reach for `session_read` when you want the *output*, not to answer "is it done".
   - On the Tasks path this is `tasks/get` instead, honouring its `pollIntervalMs`. Same discipline, different method.
   - **`transcriptBytes` tells you working from wedged.** It climbs while the agent produces output and plateaus while it thinks or runs a long tool. Flat for minutes with `status: running` is a hung agent — something `status` alone can never show you. Report it; do not kill on it reflexively.
   - Follow live instead with `session_read { session, wait: true, cursor: <nextCursor>, timeout_seconds? }` when you actually want the stream. A follow ends when the agent finishes, when the request is cancelled, or at `timeout_seconds`. **It blocks your own turn while it runs**, and you cannot ask for it to run detached — no MCP call takes a background parameter. Some runtimes auto-background an MCP call that outlives a threshold, which makes a follow tolerable for a genuinely long wait; check the active runtime's `harness-<provider>-agent-background` reference rather than assuming either way. It still returns the whole unfiltered stream, so for progress you want filtered, stream `turns.jsonl` per step 4.

6. **Collect the result deliberately — this is where the work gets lost.**
   - **`hasResult` on `session_status` already did the per-vendor scan** — tail-scoped to the latest turn. Use it instead of hand-rolling one; getting it wrong is easy, because opencode emits a `text` part for every completed sentence and has no terminal event at all.
   - `session_read` returns the vendor's raw JSON event stream, and **the answer sits in a different event per vendor**. The `tool_use` events between can be enormous.
   - **Or skip the paging entirely.** `sessionInfo.files.transcript` is the path to `turns.jsonl` — `jq` the answer straight out rather than pulling 60 kB of tool traffic through your context. The `hyprpilot-sessions` reference carries a one-liner per vendor.
   - **⛔ A failure hides in one of two places and you must check both.** A **launch** failure (a flag the vendor rejects) writes the usage text to `files.stderr` and leaves `turns.jsonl` **empty**. A **runtime** failure (auth, quota, model unavailable) leaves `stderr` **empty** and lands as an `error` event inside `turns.jsonl` — a real 402 from the model provider produced exactly that, with a zero-byte `stderr.log`. Checking only `stderr` reports "no output" for a billing error. Report the message, never the bare exit code.
   - **Page with `nextCursor`.** MCP pagination: pass a result's `nextCursor` back **verbatim** as `cursor` to continue exactly where that read stopped. It is opaque — never parse or construct one. **No `nextCursor` means the session is finished and you have all of it**; a running session always returns one, so a poller never loses its place. An unrecognised cursor is an error, not a silent reset.
   - **⛔ `exitCode: 0` + `hasResult: true` says the turn ended cleanly, NOT that the task was done.** Neither field inspects whether the agent answered what you asked. A measured run handed a 4-step prompt to a small model, got steps 1 and 2, and exited 0 with `hasResult: true` and no error event — the harness reported that success accurately. Check the answer against the brief before relaying it, and `session_send` the remainder rather than treating exit status as an acceptance test.
   - **Read the result BEFORE sending the next turn.** A new turn appends to the same transcript and pushes the previous answer out of the tail.
   - `tail` (default 200 lines) returns the trailing lines when `cursor` is omitted — the quick way to see *what it said*. For *whether it is done*, `session_status` is cheaper.

7. **Steer across turns with `session_send`, not `spawn`.**
   - **A conversation is ONE session.** `session_send { session, prompt }` reuses the handle and appends to the same transcript, so the agent retains everything from earlier turns.
   - Each turn runs as a **fresh process resumed against the vendor's own session store** — the pid changes, `startedAt` stays put, `lastTurnAt` moves. That is why a session that already exited can still be steered rather than lost; the result's `delivery` field reports what happened (`resumed`).
   - **It replays the original launch and will not let you change it.** `cwd`, `args` and `with_config` are inherited from the `spawn` and are **rejected** if you pass them — how a conversation was launched is part of its identity. Only `prompt`/`file`, `mode`, `wait` and `timeout_seconds` are per-turn. To launch differently, start a new session.
   - **⛔ One turn at a time, and detaching makes this the easy mistake.** A `session_send` against a session that is still working comes back as a tool **error** — "already has a turn in flight" — not a queued message. Because `spawn` now returns while the agent is still thinking, "spawn, then immediately send the next instruction" is a refusal every time; a blocking spawn used to hide this by finishing first. Poll `session_status` until `exited`, or `session_kill` it first.

8. **Recover a lost handle with `session_list`.** It returns every session this server owns — handle, profile, status, exit code, cwd, timestamps. Use it when the user refers to "that agent" and the handle is not in context, and present the list so they can pick.

9. **Finish deliberately with `session_kill`.**
   - **Running** → `action: "terminated"`. The agent and everything it started is stopped, and **the transcript is kept** so you can still read why.
   - **Already finished** → `action: "reaped"`. The transcript and the handle both go, and any later read fails with `unknown session`.
   - Calling it twice is the natural stop-then-clean-up. Read anything you care about before the reap.
   - Kill runaway sessions, and reap a finished one to free a slot when `spawn` reports the concurrency ceiling.

10. **Report back.** Give the user the outcome, the handle (so they can continue), and the exit status. If the session is still running, say so plainly and tell them it can be followed or steered — do not present a timed-out turn as a finished result. **A non-zero `exitCode` is not automatically the agent's fault**: the transcript may carry an upstream `error` event (auth, quota, model availability). Read it and say which before re-dispatching.

## Restricting the spawned agent

**Prefer `with_config`.** It is a hyprpilot config overlay, so hyprpilot projects it onto whichever vendor the profile runs — you state the intent once and it lands correctly on claude, opencode, or codex. Reach for it for anything it covers.

**What it covers today is `model`, `effort`, `mode`.** Every other profile key (`command`, `args`, `env`, `agent`, `mcps`, `mcp`, `system_prompt`, `harness`, `headless`, `cwd`) and every `$`-directive is refused, because an overlay reaching them turns `spawn` into arbitrary command execution. A refused key fails the whole spawn — it does not degrade to "setting ignored".

**`args` covers everything hyprpilot does not model — where the vendor exposes a flag for it at all.** It is forwarded verbatim to the vendor CLI, so it is per-vendor by nature and hyprpilot converts nothing. **Read the target's `provider` from `list_profiles` first**; a flag the vendor does not know is a launch error, not a warning — the spawn exits non-zero with the usage dump in `files.stderr` and a zero-byte transcript.

**Confirm the flag against the vendor's own `--help` before passing it** — spelling, argument shape, and whether the knob exists at all differ per vendor and change between releases. Never assume a knob exists because another vendor has one.

**opencode is the worked counter-example.** `opencode run --help` offers `--pure`, `--agent`, `--variant`, `--model`, `--dir`, `--session` and little else: **no tool allow/deny list, no spend cap, no sandbox mode.** A job that must be narrowed further than `mode` narrows it cannot be narrowed there through `args` at all — restrict it through a profile that already carries the policy, or send it to a vendor whose CLI has the knob, and say which. Never delegate unrestricted and call it restricted.

Rules that hold whichever vendor you target:

- **A flag you pass REPLACES the one hyprpilot would have generated — it does not add to it.** The launcher suppresses its own flag when yours is present, so a narrow-looking restriction can silently discard the profile's whole policy and end up *widening* the agent's authority. State the complete value you want, not the delta.
- **Not every vendor exposes every knob.** When the target has no flag for what you need, restrict through a profile that already carries the policy, or send the job to a vendor that does — and say which, rather than delegating unrestricted and calling it restricted.
- **`args` is launch identity.** `session_send` rejects it, so what you set at spawn governs every later turn of that conversation. Changing it means a new session.
- **`args` is unvalidated and cuts both ways.** Every vendor has flags that bypass its guardrails entirely. Use `args` to narrow what the captain granted, never to reach past it.
- **How a restriction lands is per-vendor — do not assume it removes the tool.** An `args`-level restriction usually drops the tool from the registry, so the agent reports it missing rather than refused; do not read that as a broken MCP server. But `mode` is the counter-example: **opencode plan mode leaves `edit`/`write`/`task` and every MCP server in the registry** and refuses at call time instead. Both shapes are real, so ask the agent what it *can call*, never what it can *see*, when you need to confirm a restriction applied.

## Semantics that bite

- **Sessions die with the MCP server and do not survive a restart.** There is no persistence. If the sidecar restarts, running agents are killed and transcripts are lost. Treat a chain as living only as long as this MCP connection — capture anything that must outlive it before the turn ends.
- **Bounded retention.** The oldest **finished** sessions are evicted along with their transcripts (default ceiling 64). A running session is never evicted. Read a transcript you care about before it ages out.
- **Bounded breadth and depth.** A ceiling of **8 concurrently running** sessions bounds breadth; `HYPRPILOT_SPAWN_DEPTH` bounds nesting at **1**, so an agent you spawn cannot spawn its own — you delegate, it works. Hitting either returns an error — free a slot with `session_kill` rather than retrying blindly.
- **Detaching removes the natural brake on breadth.** A blocking `spawn` could not overrun the concurrency ceiling because it finished before you called the next one. Detached calls return instantly, so a fan-out of nine is nine calls in one turn and the ninth is refused. Count what is already running — `session_list` — before firing a batch, and reap finished ones to free slots.
- **So the fan-out is yours to run.** A delegate cannot sub-delegate, and asking it to would just earn a refusal it has to report back. Split the work here and spawn the pieces yourself, where `session_list` sees them and `session_kill` can stop them.
- **`spawn` executes as this user.** A profile's `command` is an arbitrary binary and its `provider` picks a flag projection, not a sandbox. This is why the skill is present-first and manual.

## Examples

**User says:** "delegate this to hyprpilot personal glm-5.2 — refactor the retry logic in src/api/client.ts"

1. `list_profiles` → the fragment matches `personal/kilic/glm-5.2:cloud` (opencode, mode `build`).
2. Read the conventions/tooling references; build a self-contained prompt naming the file, the neighbouring patterns, and the test command.
3. Present the profile, cwd, and prompt → user approves.
4. `spawn { profile: "personal/kilic/glm-5.2:cloud", prompt: "…", cwd: "…" }` → returns at once with handle `s-3f2a`, `status: running`.
5. Watch `done.json` in `sessionInfo.files.dir` through the runtime's background exec; on wake, `session_status` reports `exited` / `hasResult: true`.
6. `jq` the answer out of `files.transcript`, then report the result and the handle.

**Result:** Work done in a separate opencode session; handle available for follow-ups.

---

**User says:** "that's not quite right, tell it to keep the existing backoff"

1. Reuse the handle from the previous exchange — `session_send { session: "s-3f2a", prompt: "Keep the existing backoff curve; only change the retry ceiling." }`.
2. The session had exited, so it is resumed; the agent still has turn 1's context.

**Result:** Correction applied in the same conversation — no re-briefing, no second agent.

---

**User says:** "delegate this to hyprpilot and check on it later"

1. Resolve the profile, present, then `spawn { …, mode: "plan" }` — detached by default, and read-only because the job only needs to look.
2. Returns instantly: handle `s-91c4`, `status: running`. Report that it is running and followable, and by which handle.
3. Arm the `done.json` watcher on `sessionInfo.files.dir` through the runtime's background exec — nothing wakes you here, so without it the session finishes into silence.
4. On wake: `session_status` → `exited`, `hasResult: true`. **Not** a second `spawn`.
5. `jq` the answer out of `files.transcript` (plus the `error` query), relay it, and only then send any further turn.

**Result:** Long job tracked to completion without abandoning it, duplicating it, or burying its result under a later turn.

## Key Principles

- **`list_profiles` first, always.** Never hardcode an id; never guess an ambiguous fragment.
- **`spawn` once per conversation; `session_send` for every follow-up.**
- **Dedicated parameters before `with_config`.** Reach for `with_config` only for `model` and `effort`.
- **`with_config` before `args`.** hyprpilot converts an overlay onto the target vendor; `args` is raw vendor argv you have to get right yourself. Drop to `args` only for knobs hyprpilot does not model, and check the vendor's `--help` first.
- **`mode: "plan"` for anything read-only.** Free, and it removes write authority instead of asking for it.
- **Stay detached.** `wait` already defaults false; opting into a blocking call dumps the whole raw transcript into your context with no way to trim it, and still returns `running` on a long turn. Poll `session_status`, then `jq` the answer out of `files.transcript`.
- **The handle is the only id.** It arrives with the first result and never changes. Nothing else addresses a session — and on the Tasks path it still rides `_meta`, so you never parse a task id to recover it.
- **A timeout means still working.** Follow it; never re-spawn.
- **Detached work finishes into silence.** There is no completion push here — watch `done.json` or poll. Read every session you start, and collect the answer before steering it again.
- **Arm watchers after the call, never before.** The `done.json` marker clears at turn start, so anything armed earlier fires on the previous turn's leftover.
- **A clean exit is not a finished task.** `exitCode: 0` and `hasResult: true` describe the turn, not the brief. Check the answer against what you asked.
- **Check both failure locations.** `stderr` holds launch failures, `turns.jsonl` holds runtime ones. A bare exit code is never the report.
- **Self-contained prompts, absolute paths.** The agent cannot see this conversation.
- **Present before spawning.** It runs commands as this user.
- **Report the handle.** A handle the user does not have is a session they cannot steer.
