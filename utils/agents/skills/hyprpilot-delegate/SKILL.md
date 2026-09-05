---
name: hyprpilot-delegate
description: 'hyprpilot-delegate Hand a task to a SEPARATE hyprpilot agent session and steer it across turns - profile discovery, spawning blocking or detached, following output live, cleanup. Only on an explicit request: it is never inferred from a task''s shape. Use on "delegate this to hyprpilot", "spawn a hyprpilot agent", "steer that session". Not for subagents inside this harness, or for reloading the skill catalog.'
disableModelInvocation: true
argumentHint: '[task] [optional: profile name or fragment]'
scripts:
  # Relative to this skill's own directory: resolve against the `bundleDir` the
  # skill metadata carries, never a hardcoded absolute path, because the tree
  # sits at a different root on every runtime that serves this catalog.
  - ./scripts/hyprpilot-harness.py
references:
  - ./references/hyprpilot-sessions.md
  - ../references/agent/agent-conventions.md
  - ../references/project-tooling.md
  - ../references/agent/agent-completion.md
  - ../references/agent/agent-watchers.md
  - ../references/harness/agent-background-harness-claude.md
  - ../references/harness/agent-background-harness-codex.md
  - ../references/harness/agent-background-harness-opencode.md
---

## Hyprpilot Delegation

> **Runs on explicit user request only.** Spawning a hyprpilot session starts a SEPARATE agent process under this user's credentials, and only the user decides that it should exist. Never infer it from the shape of a task, never fall back to it because in-harness dispatch (`agent-delegate`, `agent-plan`) is inconvenient or refused, and never use it to reach a posture — a mode, a model, a permission — that the current session does not have. If the user has not asked for hyprpilot or named a profile, this skill does not run.

> **A hyprpilot session is NOT an in-harness subagent.** The `agent-*` rule that dispatched work wakes you does not apply here; nothing pushes a completion to you. Session surface, completion signals, and per-vendor answer extraction per `hyprpilot-sessions`.

## ABSOLUTE — arm the turn's watcher before reporting the session as running

**Every detached turn is followed, in the same turn, by arming exactly one runtime-managed watcher on that turn's own `done.json`.** This binds to `spawn` and to every `session_send` alike — each starts a turn, each returns that turn's own path, and each finishes into silence otherwise.

The call hands you the exact path in `sessionInfo.files.turnDir`. There is nothing left to discover and nothing to wait for, so there is no state in which arming is premature and no reason to defer it to a later turn.

The sequence, in order, no step skippable:

1. **Take `sessionInfo.files.turnDir` from the call that just returned.** It names this turn and nothing else. Never carry a previous turn's path forward and never reconstruct one by hand.
2. **Read `agent-background-harness-<provider>` for the runtime's background-exec facility.** `<provider>` is the runtime this session runs on (`claude`, `opencode`, `codex`); the rest of the path is literal. It is undeclared, so a missed read is silent — the watcher simply never fires.
3. **Launch one watcher through that facility**, on the two-condition check below. Backgrounding inside the command (`&`, `nohup`, `disown`, `setsid`) hands the process to the OS and wakes nobody.
4. **Confirm the launch returned a watcher handle.** No handle means you detached instead of arming: take a branch from *No wake available* below before going further.
5. **Record and announce three identifiers together** — the session handle, the exact `turnDir` path being watched, and the watcher handle — as the armed row `agent-watchers` defines. A session handle reported without a watcher handle is an unwatched session, and the user cannot see a background loop to notice.

**Only after step 5 is "the session is running" a true statement.** Report it with all three identifiers, never with the session handle alone.

### The check

**The watcher payload is this skill's own script, not a loop written fresh per watch.** `hyprpilot-harness.py wait` is the turn waiter; resolve it against the `bundleDir` in this skill's metadata (the `scripts` frontmatter key lists the relative path):

```sh
"<bundleDir>/scripts/hyprpilot-harness.py" wait \
  --turn-dir "<sessionInfo.files.turnDir>" \
  --label "<task or issue id>" \
  --stall-after 600
```

Launch that through the runtime's background facility. Pass `--turn-dir` **verbatim from the response that just returned** — the verb appends `done.json` itself and refuses a turn index you worked out, at arm time, before anything is armed.

**Its exit code is the wake, and each one has one next action:**

| Exit | Means | Next |
|---|---|---|
| 0 | the turn ended, which is not the same as succeeded | `session_status` to audit, then collect |
| 10 | the session directory vanished — reap, eviction, or a sidecar restart | `session_status`, then `session_list` |
| 11 | with `--stall-after`: the transcript stopped growing while the marker is still absent | `session_status`, then **report the wedge**. A diagnosis, never a kill trigger. |
| 1 | the ceiling was reached | `session_status` **first** — most of these are a stale path, not a stalled agent |
| 2 | bad input; nothing was armed | fix the argument |

**Both halves of the test are required, and the script does both.** Reap, eviction and sidecar shutdown delete the whole session directory, so testing only for the file waits forever on a session that was cleaned up — a missing **directory** means finished-and-gone.

**`--stall-after` belongs on every turn watcher.** Without it a wedged turn never writes its marker and never wakes you at all; with it, exit 11 is the wedge report.

**Why a script rather than an inlined loop.** A loop authored at the moment it is needed arms unverified, and the failure is silent in the worst direction: a payload carrying nested quotes or a JSON body dies at the shell's parser and arrives as an *unarmed* watcher, which reads exactly like a quiet one. The script takes its condition as argv, refuses a relative or globbed path, and has an exit-code contract the suite covers. Discipline, cadence and the announce tables per `agent-watchers`.

**Where the script is unavailable** — a runtime that serves this catalog over MCP without the tree on disk — fall back to the equivalent inline loop, keeping both halves of the test:

```python
python3 -c '
import os, sys, time
d = "<sessionInfo.files.turnDir>"
for i in range(1, 61):
    if not os.path.isdir(d) or os.path.exists(os.path.join(d, "done.json")):
        print(f"RESULT: turn finished after {i} cycle(s)")
        sys.exit(0)
    time.sleep(30)
print("RESULT: still running after 60 cycles")
'
```

### No wake available — poll or block, never proceed

Where the runtime offers no facility that wakes you, or the launch returned no handle, silence is not an option and neither is carrying on. Take one of these in the same turn and say which:

1. **Bounded explicit poll on the main loop.** Repeat `session_status { session }` yourself at the cadence `agent-watchers` gives, under a stated cap, until `exited` — then audit and collect. It reads no transcript, so it is cheap to repeat.
2. **Blocking wait.** Re-issue the turn with `wait: true` and a `timeout_seconds` sized to the job, accepting the raw-transcript cost knowingly. A turn outliving the timeout still returns `running`, which still means working.

Never end a turn reporting a detached session as running with neither a watcher handle nor one of these two in place.

### On wake — audit the completion state, then collect

**A wake is the runtime's own notification firing on the watcher you armed, and nothing else.** A live OS process is not a wake, and a watcher's log or output file is not a wake. If you are reading either to find out whether the turn finished, nothing is waking you — that is a detached process, and the watch must be re-armed through the runtime facility before you rely on it again.

On a real wake, in order:

1. **Audit the completion state through the harness.** `session_status { session }` for `status`, `exitCode` and `hasResult`. `done.json` says the turn ended, never that it succeeded, and a missing directory says it was cleaned up rather than that it worked.
2. **Collect the result** per step 6, before any further steering. `exitCode: 0` and `hasResult: true` describe the turn, not the brief.
3. **Reap the watcher** and record its outcome in the ending row `agent-watchers` defines. A watcher that fired and was left running double-wakes the next turn.

## Context

This skill delegates to a **separate hyprpilot agent process** — a different CLI (`claude` / `codex` / `opencode`), a different model, its own session and transcript — reached over the `hyprpilot-harness` MCP server.

**This is not the same as `/agent-delegate`.** That spawns a subagent *inside the current harness*, sharing this runtime and its model tiers. This spawns an independent hyprpilot session that survives your turn, keeps its own conversation, and can be steered across many turns. Reach for this one when the user names hyprpilot or a profile, when the work wants a different vendor or model than the current session, or when the job needs to be driven over time rather than answered once.

**Availability.** The tools live on the `hyprpilot-harness` MCP server. If they are absent, the harness is not enabled for this session — say so and stop; do not fall back to shelling out to the `hyprpilot` CLI, which is one-shot and cannot be steered.

## Tools

| Tool | Purpose |
|------|---------|
| `hyprpilot-harness__list_profiles` | Discover launchable profiles. Always first. |
| `hyprpilot-harness__spawn` | Start a NEW session from a profile. Returns a `session` handle. |
| `hyprpilot-harness__session_send` | Send another turn to an existing session. The steering tool. |
| `hyprpilot-harness__session_read` | Read or follow a session's transcript. |
| `hyprpilot-harness__session_status` | **The cheap poll.** State without reading the transcript. |
| `hyprpilot-harness__session_list` | List sessions — recover a handle you lost. |
| `hyprpilot-harness__session_kill` | Stop a running session, or reap a finished one. |

**Reading a session is a RESOURCE read, not a tool call.** `hyprpilot://sessions/<handle>/result` is the answer, already extracted per vendor; `hyprpilot://sessions/<handle>` lists every turn with its outcome and URI. The tools above start, steer and poll — the resource tree is how you collect. Full tree, the three tiers, and when to drop to `session_read` or `jq`: `hyprpilot-sessions`.

## Process

1. **Discover the profile — never hardcode an id.**
   - Call `list_profiles` first, every time. Profile ids are captain-defined and change; a hardcoded id silently breaks.
   - **The listing is the whole available set, and a profile can be missing for either of two reasons.** The harness is opt-in per profile (`[profiles.harness]`), and separately the *launching* profile's `[mcp.harness].includeProfiles` / `excludeProfiles` globs scope who it may delegate to. Both gates also refuse `spawn`, with distinct messages — read the refusal rather than guessing, because the fixes differ: one is the target profile opting in, the other is this launcher's scope. If the user names a profile that is missing, say it is not reachable from here rather than guessing a neighbour.
   - **Match the user's phrasing loosely.** Ids are path-like (`personal/claude/opus`, `work/claude/sonnet`, `personal/kilic/glm-5.2:cloud`) and users say them in fragments. "delegate this to hyprpilot personal glm-5.2" means the id containing both `personal` and `glm-5.2`.
   - **Ambiguous match → ask.** If a fragment matches two profiles, list the candidates and ask; do not guess. If it matches none, show what is available.
   - **A row carrying an `error` field failed to resolve — do not launch it.** Report the error instead.
   - **What the listing returns is `id`, `agent`, `provider`, `model`, `effort`, `mode`, `cwd`, `headless`, `harnessEnabled`, `isDefault`, and `error` on a row that failed to resolve.** `model`, `effort`, `mode` and `cwd` are **omitted when the profile does not set them**, so an absent key means unset rather than unsupported — do not read one missing row as proof the field does not exist. Use what is there to sanity-check the pick and to warn the user when a profile is `headless` (it cannot be driven interactively). A listed `cwd` is the profile's own; the directory actually launched into is `sessionInfo.cwd` in the `spawn` result, which is what a relative or absent `cwd` resolves to.

2. **Brief the agent properly.** The spawned agent has NO access to this conversation. Its prompt must be self-contained: the goal, the repo/paths, the constraints, and what "done" looks like. If it writes code, carry the local patterns from `agent-conventions` and the verification commands from `project-tooling` into the prompt. A thin prompt produces a thin result and costs a whole session.

3. **Present, then spawn.** Show the resolved profile, the working directory, and the prompt. `spawn` runs the profile's `command` as this user, so it is never a silent action — present it and wait for approval. On approval call `spawn { profile, prompt|file, cwd?, mode?, wait?, timeout_seconds?, args?, with_config? }`.
   - **Use the dedicated parameters first.** `cwd`, `mode`, `file`, and `args` are all top-level parameters — reach for them directly. `with_config` is the last resort, for the settings that have no dedicated parameter of their own (`model`, `effort`). (`wait` / `timeout_seconds` are also top-level, but they describe how *you* wait, not the agent — see below.)
   - **`wait` defaults `false` — detached — and that is the right default. Leave it alone.** Opting into `wait: true` returns the **entire raw event stream inline**, every `tool_use` payload included, with no `tail` and no `cursor` to trim it: the same trivial three-item read-only task produced a **14 kB** transcript on opencode and a **121 kB** one on claude, all of it pushed through your context to deliver three lines of answer. It does not even buy certainty — a turn outliving `timeout_seconds` (default `300`) comes back `running` anyway. Reserve it for a genuinely short turn whose full trace you actually want; otherwise detach and collect just the answer (step 6).
   - **`prompt` and `file` are mutually exclusive.** `file` takes a path (`~` and `$VAR` expanded) whose contents become the prompt — prefer it for a long brief instead of inlining one.
   - **`mode` overrides the profile's mode.** `mode: "plan"` yields a read-only agent that refuses to edit — the cheapest safety lever here, and the default for a delegation that only needs to look. **Verified twice on opencode: plan-mode strips nothing from the registry.** The plan agent listed its MCP servers and every one it was configured with was there, *and* it still listed `edit`, `write` and `task` — opencode gates it at call time through `OPENCODE_PERMISSION`, it does not remove tools. So on opencode a read-only delegation keeps full MCP reach, and "the agent can see `write`" is not evidence the mode failed to apply. Do not generalise either half to claude or codex, where a mode can gate whole tool groups — on an unverified vendor, have the agent report its own tool registry in its first turn rather than assuming.
   - **A plan-mode agent also refuses on its OWN judgement, before the enforcement layer is ever reached.** Asked to call `hyprpilot-harness__spawn` and report the error verbatim, a plan-mode opencode agent declined outright: it reasoned that `spawn` is side-effecting, that plan-mode forbids side effects, and reported "exists, not invoked" instead. `OPENCODE_PERMISSION` never got a say. **Consequence: a plan-mode delegate cannot be used to probe whether a hard limit works** — a refusal proves the agent is behaving, never that the harness would have stopped it. Test enforcement from a `build`-mode session, or not at all.
   - `with_config` is an **array of overlay objects** — `with_config: [{ "model": "…" }]`, not a flat object. It accepts **only** `model`, `effort`, `mode`; every other key is refused by design, because an overlay reaching the command, its arguments, its environment, or the MCP servers it launches would turn `spawn` into arbitrary command execution. To run something else, add a profile for it.
   - **An overridden model is not visible as the profile.** Results and `session_list` keep reporting the profile id; only `sessionInfo.model` carries what actually ran. Check it before reporting which model did the work. **`sessionInfo.mode` has the same blind spot in reverse:** it echoes the profile's mode, so a mode you imposed through `args` (opencode `--agent plan`) still reads `build` there. `sessionInfo.argv` is the only honest record of what launched.
   - **Address files by absolute path in the prompt.** Do not make the agent's output depend on resolving anything relative to the working directory.
   - **codex refuses to launch outside a Git repository**, so its `cwd` must be a real checkout or worktree. The failure is not a hang: the spawn exits 1 on turn 1 with a zero-byte transcript and `Not inside a trusted directory and --skip-git-repo-check was not specified` in `files.stderr`. `args: ["--skip-git-repo-check"]` permits a non-Git working directory, for the case where no Git directory applies — it is not a substitute for a worktree when the agent writes code. As of codex-cli 0.153.4.
   - Record the returned `session` handle and report it to the user. It is how every later turn addresses this agent.

4. **Detached is the normal mode, and the default.** It suits anything long, fanning out several agents at once, and every "check on it later".
   - It returns immediately with `status: running`, the `session` handle, and a `nextCursor` to resume reading from. **The handle is the whole identity** — minted before the agent produces a byte, unchanged across turns, and the only thing any tool accepts. There is no second id to wait for.
   - **Unless your client speaks SEP-2663 Tasks**, in which case the same `spawn` returns `resultType: "task"` and a `taskId` instead. That is the standard-protocol path to the same session, and it changes which tools you poll with. **Check the result, do not assume** — `resultType: "task"` means you are on it. No vendor CLI declares the extension today, so normally you are not. Full comparison and the rules that differ: `hyprpilot-sessions`.
   - **Nothing will wake you. There is no completion push here.** The harness emits one, but it only lands on an interactive Claude Code lead with the channel registered, and nothing registers it. A client without it **drops the event silently, with no error**, which looks exactly like a hung agent. The harness also emits `resources/updated` per turn, but arming that needs `subscriptions/listen`, which is a **client** capability with no tool exposed to you. Plan for silence from the moment the call returns, and never treat "no news" as "still working".
   - **So arm the turn's `done.json` watcher now, per the ABSOLUTE section above.** That section owns the sequence, the handle requirement, the announce, the no-wake fallback, and what counts as a wake. Nothing in this step replaces it — the spawn is not finished until it has been run.
   - **Want progress, not just completion? Stream the turn's `turns.jsonl` in addition.** It is append-only, so tailing it gives an event per step while the agent works — no blocking call, no raw payloads in context. `tail -F` it from the start: the file belongs to this turn alone, so there is no byte offset to capture. The filter and opencode's event field paths are in `hyprpilot-sessions`; whether it can run in the background at all is in `agent-background-harness-<provider>`. This is a second watcher for progress, never a substitute for the completion one.
   - Leaving a detached agent unread is how a finished result gets thrown away and the job re-run.

5. **A timeout is NOT a failure and NOT a cancellation.**
   - If the turn outlives `timeout_seconds` the result returns `status: running` and **the agent keeps working.**
   - **Poll with the handle. NEVER call `spawn` again** — that starts a second, unrelated agent and abandons the first. This is the single most common way to get this wrong.
   - **`session_status { session }` is the poll.** It reads no transcript, so it costs almost nothing to repeat: `status`, `exitCode`, `transcriptBytes`, `hasResult`. Reach for `session_read` when you want the *output*, not to answer "is it done".
   - On the Tasks path this is `tasks/get` instead, honouring its `pollIntervalMs`. Same discipline, different method.
   - **`transcriptBytes` tells you working from wedged.** It climbs while the agent produces output and plateaus while it thinks or runs a long tool. Flat for minutes with `status: running` is a hung agent — something `status` alone can never show you. Report it; do not kill on it reflexively.
   - Follow live instead with `session_read { session, wait: true, cursor: <nextCursor>, timeout_seconds? }` when you actually want the stream. A follow ends when the agent finishes, when the request is cancelled, or at `timeout_seconds`. **It blocks your own turn while it runs**, and you cannot ask for it to run detached — no MCP call takes a background parameter. Some runtimes auto-background an MCP call past a threshold (the harness file named in step 4 says whether yours does), **but that only stops the stall — the same untrimmed payload still arrives, just later.** A follow is the right tool only when you genuinely want the entire raw stream; for progress, stream the turn's `turns.jsonl` per step 4, and for the answer, read `/result` per step 6.

6. **Collect the result deliberately — this is where the work gets lost.**
   - **Read `hyprpilot://sessions/<handle>/result`. That is the collection step.** It performs the per-vendor extraction server-side and hands back the answer at the answer's own size — a measured probe returned 22 bytes where the transcript was 1 049. It slices by event, so a multi-line answer survives whole, and an `error` event outranks text, so an upstream failure is reported as the error rather than as silence.
   - **It never comes back blank on a finished session.** The three no-answer shapes — an `error` event, a launch failure with an empty transcript, or neither — land in different places, and `/result` falls through transcript, stderr and exit code, then names which one happened. That is why it replaces the hand-rolled query: a query can only see one of the three.
   - **An earlier turn is `…/turns/<n>/result`,** and `hyprpilot://sessions/<handle>` lists every turn with its outcome and URI in one read — so you never walk turn numbers probing for the end.
   - **Want something the views do not define? `jq` on `files.transcript`.** "Every tool it called", "just the errors", "how many files it read". Its advantage is structural: it filters **before** the bytes reach your context, which no resource read can do. Reach for it to keep context pure on a large transcript, not to find the answer — `/result` already did that, correctly.
   - **`session_read` stays a legitimate choice — it is situational, not banned.** Page it when you want the raw event stream, when the run was small enough that the difference does not matter, when you are diagnosing the vendor's own shape, or when no shell is available. Just know which one you are paying for.
   - **The gap is not small, and it grows with the agent's tool use rather than its output.** opencode inlines each file it reads into the event *and* re-attaches the loaded instruction files on every call: a measured ten-file survey left a 389 kB transcript whose answer was twelve lines. `session_read` would have paged that; `/result` returns the twelve lines.
   - **Page with `nextCursor`.** MCP pagination: pass a result's `nextCursor` back **verbatim** as `cursor` to continue exactly where that read stopped. It is opaque — never parse or construct one. **No `nextCursor` means the session is finished and you have all of it**; a running session always returns one, so a poller never loses its place. An unrecognised cursor is an error, not a silent reset.
   - **`exitCode: 0` + `hasResult: true` says the turn ended cleanly, NOT that the task was done.** Neither field inspects whether the agent answered what you asked. A measured run handed a 4-step prompt to a small model, got steps 1 and 2, and exited 0 with `hasResult: true` and no error event — the harness reported that success accurately. Check the answer against the brief before relaying it, and `session_send` the remainder rather than treating exit status as an acceptance test.
   - **Every turn keeps its own answer.** A new turn writes into its own directory, so turn 1's `/result` still returns turn 1's answer after turn 5 — reading in order is good practice, not a deadline.
   - `tail` (default 200 lines) returns the trailing lines when `cursor` is omitted — the quick way to see *what it said*. For *whether it is done*, `session_status` is cheaper.

7. **Steer across turns with `session_send`, not `spawn`.**
   - **A conversation is ONE session.** `session_send { session, prompt }` reuses the handle and appends to the same transcript, so the agent retains everything from earlier turns.
   - **A detached `session_send` starts a turn, so it arms a watcher exactly like a spawn does.** Its result carries that turn's own `sessionInfo.files.turnDir` — a fresh directory with no marker in it — so run the ABSOLUTE sequence again against the new path and the new watcher handle. Reap the previous turn's watcher before arming the replacement; two loops on one session wake you twice and can report different turns.
   - Each turn runs as a **fresh process resumed against the vendor's own session store** — the pid changes, `startedAt` stays put, `lastTurnAt` moves. That is why a session that already exited can still be steered rather than lost; the result's `delivery` field reports what happened (`resumed`).
   - **It replays the original launch and will not let you change it.** `cwd`, `args` and `with_config` are inherited from the `spawn` and are **rejected** if you pass them — how a conversation was launched is part of its identity. Only `prompt`/`file`, `mode`, `wait` and `timeout_seconds` are per-turn. To launch differently, start a new session.
   - **One turn at a time, and detaching makes this the easy mistake.** A `session_send` against a session that is still working comes back as a tool **error** — "already has a turn in flight" — not a queued message. `spawn` returns while the agent is still thinking, so "spawn, then immediately send the next instruction" is a refusal every time. Poll `session_status` until `exited`, or `session_kill` it first.

8. **Recover a lost handle with `session_list`.** It returns every session this server owns — handle, profile, status, exit code, cwd, timestamps. Use it when the user refers to "that agent" and the handle is not in context, and present the list so they can pick.

9. **Finish deliberately with `session_kill`.**
   - **Running** → `action: "terminated"`. The agent and everything it started is stopped, and **the transcript is kept** so you can still read why.
   - **Already finished** → `action: "reaped"`. The transcript and the handle both go, and any later read fails with `unknown session`.
   - Calling it twice is the natural stop-then-clean-up. Read anything you care about before the reap.
   - Kill runaway sessions, and reap a finished one to free a slot when `spawn` reports the concurrency ceiling.
   - **Reaping the session deletes the directory the watcher tests, so reap the watcher too.** A loop left on a reaped session's `turnDir` fires on the missing-directory half and reports a finish that is really a cleanup. Stop the watcher through the runtime facility and record its ending row before or with the `session_kill`.

10. **Report back.** Give the user the outcome, the handle (so they can continue), and the exit status. If the session is still running, say so plainly and tell them it can be followed or steered — do not present a timed-out turn as a finished result. **A non-zero `exitCode` is not automatically the agent's fault**: the transcript may carry an upstream `error` event (auth, quota, model availability). Read it and say which before re-dispatching. If the user wants to commit/push/PR from the result, hand off per `agent-completion`.

## Restricting the spawned agent

**Prefer `with_config`.** It is a hyprpilot config overlay, so hyprpilot projects it onto whichever vendor the profile runs — you state the intent once and it lands correctly on claude, opencode, or codex. Reach for it for anything it covers.

**What it covers today is `model`, `effort`, `mode`.** Every other profile key (`command`, `args`, `env`, `agent`, `mcps`, `mcp`, `system_prompt`, `harness`, `headless`, `cwd`) and every `$`-directive is refused, because an overlay reaching them turns `spawn` into arbitrary command execution. A refused key fails the whole spawn — it does not degrade to "setting ignored".

**`args` covers everything hyprpilot does not model — where the vendor exposes a flag for it at all.** It is forwarded verbatim to the vendor CLI, so it is per-vendor by nature and hyprpilot converts nothing. **Read the target's `provider` from `list_profiles` first**; a flag the vendor does not know is a launch error, not a warning — the spawn exits non-zero with the usage dump in `files.stderr` and a zero-byte transcript.

**Confirm the flag against the vendor's own `--help` before passing it** — spelling, argument shape, and whether the knob exists at all differ per vendor and change between releases. Never assume a knob exists because another vendor has one.

**opencode is the worked counter-example.** `opencode run --help` offers `--pure`, `--agent`, `--variant`, `--model`, `--dir`, `--session` and little else: **no tool allow/deny list, no spend cap, no sandbox mode.** A job that must be narrowed further than `mode` narrows it cannot be narrowed there through `args` at all — restrict it through a profile that already carries the policy, or send it to a vendor whose CLI has the knob, and say which. Never delegate unrestricted and call it restricted.

**codex read-only is `mode: "read-only"`, never `mode: "plan"`.** Its sandbox vocabulary is `read-only`, `workspace-write` and `danger-full-access` (`codex --sandbox`); `plan` is not one of them, so passing it selects nothing and the agent runs at whatever the profile already had. The `codex` agent in `~/.config/hyprpilot/config.yaml` also passes `--approve-for-me`, documented as routing approvals *"through automatic review using the workspace-write sandbox"* — so an explicit `mode` conflicts with it, and a job that must be read-only wants a profile that sets the sandbox rather than a `mode` override on top. Whether a codex sandbox mode drops tools from the registry or gates them at call time is still unmeasured, so the rule above — ask what the agent *can call*, not what it can see — still applies here. As of codex-cli 0.153.4.

Rules that hold whichever vendor you target:

- **A flag you pass REPLACES the one hyprpilot would have generated — it does not add to it.** The launcher suppresses its own flag when yours is present, so a narrow-looking restriction can silently discard the profile's whole policy and end up *widening* the agent's authority. State the complete value you want, not the delta.
- **Not every vendor exposes every knob.** When the target has no flag for what you need, restrict through a profile that already carries the policy, or send the job to a vendor that does — and say which, rather than delegating unrestricted and calling it restricted.
- **`args` is launch identity.** `session_send` rejects it, so what you set at spawn governs every later turn of that conversation. Changing it means a new session.
- **`args` is unvalidated and cuts both ways.** Every vendor has flags that bypass its guardrails entirely. Use `args` to narrow what the captain granted, never to reach past it.
- **How a restriction lands is per-vendor — do not assume it removes the tool.** An `args`-level restriction usually drops the tool from the registry, so the agent reports it missing rather than refused; do not read that as a broken MCP server. But `mode` is the counter-example: **opencode plan-mode leaves `edit`/`write`/`task` and every MCP server in the registry** and refuses at call time instead. Both shapes are real, so ask the agent what it *can call*, never what it can *see*, when you need to confirm a restriction applied.
- **But "ask it to call" does not confirm enforcement either, under a mode.** A restricted agent refuses on its own judgement first — measured on opencode plan-mode, which declined a `spawn` call it was explicitly asked to attempt and report the error from, without the permission layer being consulted. So a refusal under `mode` tells you the agent is well-behaved and nothing about the guardrail behind it. To test the guardrail, drop the mode and rely on the layer you are actually testing.

## Scripts

`scripts/hyprpilot-harness.py` turns the checks this skill describes in prose into argument-validated verbs with exit-code contracts a caller can branch on. Resolve it against this skill's `bundleDir`; `--help` lists the verbs and `VERB --help` documents one.

| Verb | Stage | Answers |
|---|---|---|
| `wait` | while running, **the watcher** | Has this one turn ended, has its session vanished, or has its transcript stopped growing, within a bounded number of polls. |
| `resolve` | before spawn | Which profile the user meant, and whether the spawn arguments pass the contract. |
| `verdict` | on wake | Collect, poll again, wedged, inspect, or steer — from one `session_status` reading plus a ledger of earlier ones. |
| `result` | fallback | What did the agent finally say, and if nothing, why. |
| `inspect` | fallback | Which turn is current, did it finish, what did the terminal event say, is a result recoverable. |
| `teardown` | before reap | What is still uncollected, still running, or still polling this session. |

**One script, one subject: the whole life of a session.** It calls no MCP, spawns nothing, kills nothing, writes outside no path you name, and refuses a globbed or relative path rather than false-firing on a sibling turn. Standard library only, so it runs wherever `python3` does — including as a background watcher payload, which is the one context that has no MCP client at all.

**The resource read stays the collection path.** `result` and `inspect` are the exception rather than a parallel route, and two situations put them on it:

- **A claude `error_max_turns` exit.** That event carries no `result` field, so a query keyed on one prints an empty line and reads as "the agent produced nothing". `result` falls back to the last assistant text and labels its source, which is what tells you whether the agent committed or pushed before it ran out of turns.
- **A context with no MCP surface at all**, such as a shell step in a job carrying no MCP toolset. There the transcript on disk is the only route, and these read it without paging the whole stream into context.

`inspect` withholds by design: it reports `stderr.log` by size with the content suppressed, and every `session.json` key outside `handle` and `startedAt` by name only. Read stderr yourself when you need it, and quote the failing line rather than the file.

Run the suite with `task test:python` from the repository root; `task lint:python` covers ruff and formatting. Add a fixture under `scripts/tests/fixtures/` when a vendor changes shape.

## Semantics that bite

- **Sessions die with the MCP server and do not survive a restart.** There is no persistence. If the sidecar restarts, running agents are killed and transcripts are lost. Treat a chain as living only as long as this MCP connection — capture anything that must outlive it before the turn ends.
- **Bounded retention.** The oldest **finished** sessions are evicted along with their transcripts (default ceiling 64). A running session is never evicted. Read a transcript you care about before it ages out.
- **Bounded breadth and depth.** A ceiling of **8 concurrently running** sessions bounds breadth; `[mcp.harness].maxDepth` bounds nesting at **1** by default (stamped as `HYPRPILOT_SPAWN_DEPTH`), so an agent you spawn cannot spawn its own — you delegate, it works. Hitting either returns an error — free a slot with `session_kill` rather than retrying blindly.
- **Detaching removes the natural brake on breadth.** A blocking `spawn` could not overrun the concurrency ceiling because it finished before you called the next one. Detached calls return instantly, so a fan-out of nine is nine calls in one turn and the ninth is refused. Count what is already running — `session_list` — before firing a batch, and reap finished ones to free slots.
- **So the fan-out is yours to run.** A delegate cannot sub-delegate, and asking it to would just earn a refusal it has to report back. Split the work here and spawn the pieces yourself, where `session_list` sees them and `session_kill` can stop them.
- **`spawn` executes as this user.** A profile's `command` is an arbitrary binary and its `provider` picks a flag projection, not a sandbox. This is why the skill is manual, requested by the user, and presented before it spawns.

## Examples

**User says:** "delegate this to hyprpilot personal glm-5.2 — refactor the retry logic in src/api/client.ts"

1. `list_profiles` → the fragment matches `personal/kilic/glm-5.2:cloud` (opencode, mode `build`).
2. Build a self-contained prompt naming the file, the neighbouring patterns from `agent-conventions`, and the test command from `project-tooling`.
3. Present the profile, cwd, and prompt → user approves.
4. `spawn { profile: "personal/kilic/glm-5.2:cloud", prompt: "…", cwd: "…" }` → returns at once with handle `3b5ce010-…`, `status: running`, and `sessionInfo.files.turnDir` for turn 1.
5. Arm the `done.json` watcher on that exact `turnDir` through the runtime's background exec; the launch returns watcher handle `task_01H…`. Announce the session handle, the watched path, and the watcher handle, and only then say the session is running.
6. On wake, `session_status` reports `exited` / `hasResult: true`; read `hyprpilot://sessions/3b5ce010-…/result`, reap the watcher, then report the answer and the handle.

**Result:** Work done in a separate opencode session; handle available for follow-ups.

---

**User says:** "that's not quite right, tell it to keep the existing backoff"

1. Reuse the handle from the previous exchange — `session_send { session: "3b5ce010-…", prompt: "Keep the existing backoff curve; only change the retry ceiling." }`.
2. The session had exited, so it is resumed; the agent still has turn 1's context.
3. The result carries turn 2's own `turnDir`. Arm a fresh watcher on it, quote the new watcher handle, and reap turn 1's.

**Result:** Correction applied in the same conversation — no re-briefing, no second agent, and turn 2 is watched from the moment it starts.

---

**User says:** "delegate this to hyprpilot and check on it later"

1. Resolve the profile, present, then `spawn { …, mode: "plan" }` — detached by default, and read-only because the job only needs to look.
2. Returns instantly: handle `9c4de0a8-…`, `status: running`, plus turn 1's `turnDir`.
3. Arm the `done.json` watcher on that exact path through the runtime's background exec, and confirm it returned watcher handle `task_01H…`. Nothing wakes you here, so without a handle the session finishes into silence.
4. Report it running, naming the session handle, the watched path, and the watcher handle.
5. On wake: `session_status` → `exited`, `hasResult: true`. **Not** a second `spawn`, and not a read of the watcher's own log.
6. Read `hyprpilot://sessions/9c4de0a8-…/result` — one read covers the answer and any upstream error — relay it, reap the watcher, and only then send any further turn.

**Result:** Long job tracked to completion without abandoning it, duplicating it, or burying its result under a later turn.

## Key Principles

- **`list_profiles` first, always.** Never hardcode an id; never guess an ambiguous fragment.
- **`spawn` once per conversation; `session_send` for every follow-up.**
- **Dedicated parameters before `with_config`.** Reach for `with_config` only for `model` and `effort`.
- **`with_config` before `args`.** hyprpilot converts an overlay onto the target vendor; `args` is raw vendor argv you have to get right yourself. Drop to `args` only for knobs hyprpilot does not model, and check the vendor's `--help` first.
- **`mode: "plan"` for anything read-only.** Free, and it removes write authority instead of asking for it.
- **Stay detached, and collect through the resource.** `wait` already defaults false; opting into a blocking call dumps the whole raw transcript into your context with no way to trim it, and still returns `running` on a long turn. Poll `session_status`, then read `/result`.
- **`/result` for the answer, `jq` for a projection, `session_read` for the raw stream.** Three tools, three jobs — the ranking is about cost, not permission. `jq` earns its place by filtering before the bytes reach your context; nothing else can do that.
- **A runtime that auto-backgrounds slow MCP calls changes nothing here.** It stops the turn stalling; the untrimmed payload still arrives. Deferred cost is still cost.
- **The handle is the only id.** It arrives with the first result and never changes. Nothing else addresses a session — and on the Tasks path it still rides `_meta`, so you never parse a task id to recover it.
- **A timeout means still working.** Follow it; never re-spawn.
- **Detached work finishes into silence.** There is no completion push you can arm — every detached `spawn` and every detached `session_send` gets its own `done.json` watcher, armed before the session is reported as running.
- **A watcher exists when a launch returned a handle.** No handle means you detached instead of arming: drop to a bounded `session_status` poll or a blocking `wait: true`, and say which.
- **Announce the session handle, the watched `turnDir`, and the watcher handle together.** Any of the three missing makes the other two unverifiable.
- **A wake is the runtime's notification, never a log.** Reading a watcher's output file to find out whether the turn finished means nothing is waking you.
- **Watch the TURN's directory.** `sessionInfo.files.turnDir` names the turn the call just started, and each turn owns its own marker — so there is no stale state to race and no rule about when to arm.
- **Audit before collecting.** `session_status` first for `status` / `exitCode` / `hasResult`, then `/result`. A marker file is an end, not an outcome.
- **A clean exit is not a finished task.** `exitCode: 0` and `hasResult: true` describe the turn, not the brief. Check the answer against what you asked.
- **`/result` already checks both failure locations** — launch failures land in `stderr.log`, runtime ones as an `error` event in the transcript, and it names which happened. A bare exit code is never the report.
- **Self-contained prompts, absolute paths.** The agent cannot see this conversation.
- **Present before spawning.** It runs commands as this user.
- **Report the handle.** A handle the user does not have is a session they cannot steer.
