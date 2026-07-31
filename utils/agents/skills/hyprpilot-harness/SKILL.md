---
name: hyprpilot-harness
description: 'hyprpilot-harness Delegate a task to a separate hyprpilot agent session (claude/codex/opencode) over the hyprpilot_harness MCP server, then steer it across turns. Use on "delegate this to hyprpilot", "spawn a hyprpilot agent", "send this to personal/claude/opus", "list hyprpilot sessions", "steer that session", "kill that agent". Covers profile discovery, spawning, multi-turn steering, following output, and cleanup. Do NOT use for subagents inside this harness (use /agents-delegate) or to reload the skill catalog (use /hyprpilot-reload).'
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

3. **Present, then spawn.** Show the resolved profile, the cwd, and the prompt. On approval call `spawn { profile, prompt, cwd?, wait?, timeout_seconds? }`.
   - `wait` defaults `true`; `timeout_seconds` defaults `300`.
   - Set `cwd` deliberately — it defaults to the profile's, not yours.
   - `with_config` accepts **only** `model`, `effort`, `mode`. Anything else is rejected by design.
   - `args` forwards raw flags to the vendor CLI, equivalent to the CLI's trailing `-- <args>`.
   - Record the returned `session` handle and report it to the user. It is how every later turn addresses this agent.

4. **⛔ A timeout is NOT a failure and NOT a cancellation.**
   - If the turn outlives `timeout_seconds` the result returns `status: running` and **the agent keeps working.**
   - **Poll or follow `session_read` with the handle. NEVER call `spawn` again** — that starts a second, unrelated agent and abandons the first. This is the single most common way to get this wrong.
   - Follow live with `session_read { session, wait: true, offset: <nextOffset> }`; pass the previous call's `nextOffset` to stream only new output instead of re-reading the whole transcript.

5. **Steer across turns with `session_send`, not `spawn`.**
   - **A conversation is ONE session.** `session_send { session, prompt }` reuses the handle and appends to the same transcript, so the agent retains everything from earlier turns.
   - It is **state-aware**: on a finished session it resumes the vendor session first, so a session that already exited is woken rather than lost.
   - It inherits only the **profile**. `cwd`, `mode`, `with_config` and `args` are NOT carried forward — pass them again on each turn if the work needs them.
   - **One turn at a time.** A `session_send` against a session that is still working is rejected rather than interleaved. Wait for the current turn, or `session_read` until it exits.

6. **Recover a lost handle with `session_list`.** It returns every session this server owns — handle, profile, status, exit code, timestamps. Use it when the user refers to "that agent" and the handle is not in context, and present the list so they can pick.

7. **Finish deliberately with `session_kill`.**
   - **Running** → terminates the agent and everything it started, **keeping the transcript** so you can still read why.
   - **Already finished** → reaps the session and its transcript.
   - Calling it twice is the natural stop-then-clean-up; the result's `action` says which happened.
   - Kill runaway sessions, and kill a finished one to free a slot when `spawn` reports the concurrency ceiling.

8. **Report back.** Give the user the outcome, the handle (so they can continue), and the exit status. If the session is still running, say so plainly and tell them it can be followed or steered — do not present a timed-out turn as a finished result.

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

1. Resolve the profile, present, then `spawn { …, wait: true, timeout_seconds: 300 }`.
2. Result returns `status: running` — the agent is still working.
3. Report: still running, handle `s-91c4`, followable.
4. On "how's it going?" → `session_read { session: "s-91c4", offset: <nextOffset> }`. **Not** a second `spawn`.

**Result:** Long job tracked to completion without abandoning or duplicating it.

## Key Principles

- **`list_profiles` first, always.** Never hardcode an id; never guess an ambiguous fragment.
- **`spawn` once per conversation; `session_send` for every follow-up.**
- **A timeout means still working.** Follow it; never re-spawn.
- **Self-contained prompts.** The agent cannot see this conversation.
- **Present before spawning.** It runs commands as this user.
- **Report the handle.** A handle the user does not have is a session they cannot steer.
