---
name: labrat-background
description: labrat-background Follow labrat sessions in the background through the labrat server's own event stream - one watcher per session that wakes on labrat's next reply, or when a handed-off session opens. Use on "watch labrat", "tell me when labrat replies", "follow the labrat thread". Not for reading a session once, handing work over, or waiting on CI or MRs.
references:
  - ../references/long-running-work.md
  - ../references/agent/agent-watchers.md
  - ../references/identifier-legibility.md
---

Load `labrat` before the first call; it owns the server, the session keys and how to judge a session's state. Load `agent-background` before arming; its `watch.py` runs every watcher here, and its harness reference says how a finished watcher wakes you.

## Context

labrat pushes nothing to this session. Its server keeps one event stream for every session: each message is an event with `cursor`, `session_key`, `role`, `type` and truncated `content`, paged oldest first by `events_poll` past an `after_cursor`. `watch.py`'s `mcp-stream` condition follows that cursor natively: it drains to the head on its first poll, reads past it on every later one, and fires on the first matching event, so a burst of narration between polls never hides the reply after it. When the bridge restarts, the cursors reset and the stream stops returning the event the watch anchored on; the watch fires on that too, because the events in the gap are gone from the stream.

## Arm

Arm first in the turn, one watcher per session, launched through the runtime's background facility per `agent-background`, with its ledger row per `agent-watchers`. The server and its headers come from the agent's own MCP config (`--server labrat --config <path>`).

| Waiting for | Condition |
|---|---|
| labrat's next reply in a session | `mcp-stream --tool events_poll --arguments '{"session_key":"<key>","limit":100}' --items result.events --match role=assistant --show content` |
| A handed-off session opening | `mcp-new --tool conversations_list --arguments '{"platform":"slack","search":"<thread ts>"}' --items result.conversations --id session_key --show session_key` |

- `--match role=assistant` skips the gateway's internal notifications and your own steers, which arrive as `role: user`.
- Cadence 30 s: labrat replies on a human timescale, and a quiet poll is one call.
- The thread ts is the handoff post's own ts, so the session watch starts from zero sessions and fires on the first.
- Pre-flight once in the foreground with `--max-polls 1` before detaching. A `head at cursor N` or `0 item(s) at baseline` line proves the server, the credentials and the key.

## On wake

1. Read the full message with `messages_read` on the session; the event's content is truncated.
2. Judge it per `labrat`. A verdict, a checkpoint, an MR link or a question is terminal; a progress narration means it is still working.
3. A `lost its place` wake means the bridge restarted. Read the session's latest messages to cover the gap, then re-arm.
4. Verify what a terminal reply claims (MR state, pipeline, issue) before relaying it, every identifier a titled link per `identifier-legibility`.
5. Re-arm the same session unless the work is done or handed back, and record the re-arm command durably per `long-running-work`.

## Reap

Stop a session's watcher when labrat stood down, the work moved here, or you read the answer another way. At the end of a flow, list every labrat watcher as stopped, or as still armed with what it waits for.

## Example

**Trigger:** "hand KEDA to labrat and tell me when it reaches a checkpoint."

1. Post the handoff, then arm the session watch with the post's ts; it fires when labrat opens the session.
2. Arm the reply watch on the new session key.
3. A wake names "Dispatched: building chart-keda"; it is narration, so re-arm.
4. The next wake names the checkpoint message. Read it, check the MR it links, report it with titled links, and re-arm for the next checkpoint.

**Result:** one silent watcher per session, and the user hears about labrat's progress at its checkpoints.
