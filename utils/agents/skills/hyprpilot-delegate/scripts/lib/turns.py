"""Parsing helpers for Hyprpilot `turns.jsonl` transcripts, imported by the session verbs."""

from __future__ import annotations

import json
import os

# A Hyprpilot session directory:
#
#     <session-dir>/session.json
#     <session-dir>/turns/<N>/turns.jsonl
#     <session-dir>/turns/<N>/done.json
#     <session-dir>/turns/<N>/stderr.log
#
# One `turns.jsonl` holds ONE turn, so "the final result of a turn" is the
# last terminal event of that single file.

PROVIDERS = ("claude", "codex", "opencode")

# Event payload keys that may carry credentials or full tool traffic. Nothing in
# this module ever prints a raw event; these names exist so callers can report
# "a key was present" without echoing the value.
WITHHELD_KEYS = ("env", "envKeys", "argv", "command", "headers", "authorization")


class TranscriptError(Exception):
    """Raised for an input the caller supplied wrongly."""


def resolve_transcript(path):
    """Accept a `turns.jsonl` file or a turn directory holding one.

    Never globs. A directory resolves to exactly `<dir>/turns.jsonl`.
    """
    if not path:
        raise TranscriptError("no transcript path given")
    for ch in "*?[":
        if ch in path:
            raise TranscriptError(
                f"path contains the glob character {ch!r}; pass the exact path from "
                "sessionInfo.files.transcript instead"
            )
    path = os.path.abspath(os.path.expanduser(path))
    if os.path.isdir(path):
        path = os.path.join(path, "turns.jsonl")
    if not os.path.exists(path):
        raise TranscriptError(f"transcript does not exist: {path}")
    if not os.path.isfile(path):
        raise TranscriptError(f"transcript is not a regular file: {path}")
    if not os.access(path, os.R_OK):
        raise TranscriptError(f"transcript is not readable: {path}")
    return path


def read_events(path):
    """Yield (lineno, event_or_None) for every non-blank line.

    A line that will not parse yields None rather than aborting the read; a
    transcript can be truncated mid-write while the turn is still running.
    """
    with open(path, encoding="utf-8", errors="replace") as handle:
        for lineno, line in enumerate(handle, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                event = json.loads(line)
            except ValueError:
                yield lineno, None
                continue
            yield lineno, event if isinstance(event, dict) else None


def event_label(event):
    """Short type label for counting, e.g. `item.completed/agent_message`."""
    kind = event.get("type", "<no-type>")
    if kind == "item.completed":
        item = event.get("item")
        if isinstance(item, dict):
            return "item.completed/{}".format(item.get("type", "<no-item-type>"))
    return str(kind)


def detect_provider(events):
    """Infer the vendor from event shapes alone.

    `session.json` does not record the provider, so shape is the only
    evidence available on disk. Scored rather than first-match, because a
    truncated transcript can carry a single ambiguous event.
    """
    score = {name: 0 for name in PROVIDERS}
    for event in events:
        kind = event.get("type")
        if kind == "result" and "subtype" in event:
            score["claude"] += 3
        elif (
            kind in ("assistant", "user")
            and isinstance(event.get("message"), dict)
            or kind == "system"
            and "session_id" in event
        ):
            score["claude"] += 1
        elif kind in ("item.completed", "item.started") or kind == "turn.completed":
            score["codex"] += 3
        elif kind == "text" and isinstance(event.get("part"), dict):
            score["opencode"] += 3
        elif isinstance(kind, str) and kind.startswith("step_"):
            score["opencode"] += 2
    best = max(score, key=lambda name: score[name])
    if score[best] == 0:
        return None, score
    return best, score


def _claude_text_blocks(event):
    message = event.get("message")
    if not isinstance(message, dict):
        return []
    content = message.get("content")
    if isinstance(content, str):
        return [content]
    out = []
    if isinstance(content, list):
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                text = block.get("text")
                if isinstance(text, str) and text.strip():
                    out.append(text)
    return out


def scan(path):
    """Read one transcript and return everything the callers need.

    Returns a dict with the detected provider, the final agent result (or
    None), why a result is missing, and per-type event counts. Raw event
    payloads are never included.
    """
    events = []
    unparsable = 0
    counts = {}
    for _lineno, event in read_events(path):
        if event is None:
            unparsable += 1
            continue
        events.append(event)
        label = event_label(event)
        counts[label] = counts.get(label, 0) + 1

    info = {
        "transcript": path,
        "bytes": os.path.getsize(path),
        "events": len(events),
        "unparsableLines": unparsable,
        "eventCounts": counts,
        "provider": None,
        "providerScores": {},
        "result": None,
        "resultSource": None,
        "hasResult": False,
        "isError": None,
        "subtype": None,
        "terminalReason": None,
        "numTurns": None,
        "errors": [],
        "explanation": None,
        "terminalEventSeen": False,
    }

    if not events:
        info["explanation"] = (
            "transcript is empty: the vendor CLI never emitted an event. This is "
            "the launch-failure shape (a flag the vendor rejected) - read the "
            "turn's stderr.log for the real message."
        )
        return info

    provider, scores = detect_provider(events)
    info["provider"] = provider
    info["providerScores"] = scores

    # A runtime failure (auth, quota, model unavailable) lands as an event in
    # the transcript while stderr.log stays empty.
    for event in events:
        if event.get("type") == "error":
            message = event.get("message") or event.get("error") or ""
            if isinstance(message, dict):
                message = message.get("message", "")
            info["errors"].append(str(message)[:500])

    if provider == "claude":
        _scan_claude(events, info)
    elif provider == "codex":
        _scan_codex(events, info)
    elif provider == "opencode":
        _scan_opencode(events, info)
    else:
        info["explanation"] = "no event matched a known Claude, Codex or OpenCode shape. Event types seen: %s" % (
            ", ".join(sorted(counts)) or "none"
        )

    info["hasResult"] = bool(info["result"] and info["result"].strip())
    return info


def _scan_claude(events, info):
    terminal = None
    for event in events:
        if event.get("type") == "result":
            terminal = event
    if terminal is not None:
        info["terminalEventSeen"] = True
        info["subtype"] = terminal.get("subtype")
        info["isError"] = terminal.get("is_error")
        info["terminalReason"] = terminal.get("terminal_reason")
        info["numTurns"] = terminal.get("num_turns")
        for err in terminal.get("errors") or []:
            info["errors"].append(str(err)[:500])
        text = terminal.get("result")
        if isinstance(text, str) and text.strip():
            info["result"] = text
            info["resultSource"] = "result.result"
            return

    # `error_max_turns` omits the `result` key entirely. The agent's work is
    # still in the transcript, so fall back to its last assistant text.
    for event in reversed(events):
        if event.get("type") == "assistant":
            blocks = _claude_text_blocks(event)
            if blocks:
                info["result"] = "\n\n".join(blocks)
                info["resultSource"] = "last assistant text block (fallback)"
                break

    if terminal is None:
        info["explanation"] = (
            "no terminal `result` event: the turn is still running, or it was "
            "killed before Claude could finish. Confirm with session_status "
            "before treating it as a failure."
        )
    elif info["subtype"] == "error_max_turns":
        info["explanation"] = (
            "Claude ended with subtype=error_max_turns (terminal_reason={}, "
            "num_turns={}) and emits no `result` text in that case. The agent "
            "still holds its full context - steer the SAME session with "
            "session_send rather than re-spawning.".format(info["terminalReason"], info["numTurns"])
        )
    elif not info["result"]:
        info["explanation"] = "terminal `result` event carried no text (subtype={}, is_error={}).".format(
            info["subtype"],
            info["isError"],
        )


def _scan_codex(events, info):
    for event in reversed(events):
        if event.get("type") != "item.completed":
            continue
        item = event.get("item")
        if isinstance(item, dict) and item.get("type") == "agent_message":
            text = item.get("text")
            if isinstance(text, str) and text.strip():
                info["result"] = text
                info["resultSource"] = "item.completed/agent_message.text"
                info["terminalEventSeen"] = True
                return
    for event in reversed(events):
        if event.get("type") == "turn.completed":
            info["terminalEventSeen"] = True
            break
    info["explanation"] = (
        "no `item.completed` event of item type `agent_message` carried text. "
        "Codex emits the answer only when the turn reaches an agent message - "
        "an aborted or sandbox-rejected turn has none. Check stderr.log and "
        "session_status."
    )


def _scan_opencode(events, info):
    for event in reversed(events):
        if event.get("type") != "text":
            continue
        part = event.get("part")
        if isinstance(part, dict):
            text = part.get("text")
            if isinstance(text, str) and text.strip():
                info["result"] = text
                info["resultSource"] = "last text/part.text"
                break
    for event in events:
        if str(event.get("type", "")).startswith("step_finish"):
            info["terminalEventSeen"] = True
    if info["result"]:
        info["explanation"] = (
            "OpenCode emits no terminal event - this is the LAST `text` part, "
            "not proof the turn finished. Only session_status `status: exited` "
            "proves that."
        )
    else:
        info["explanation"] = (
            "no `text` event carried a `part.text` string. The turn produced no "
            "assistant prose - check stderr.log and session_status."
        )


SCANNERS = {
    "claude": _scan_claude,
    "codex": _scan_codex,
    "opencode": _scan_opencode,
}


def rescan_as(path, provider):
    """Re-read a transcript forcing one vendor's extraction.

    For the case where shape detection came out ambiguous and the operator
    already knows which CLI ran. Returns the same dict shape as `scan`, with
    `providerDetected` recording what detection would have said.
    """
    if provider not in SCANNERS:
        raise TranscriptError("unknown provider {!r}; expected one of {}".format(provider, ", ".join(PROVIDERS)))
    info = scan(path)
    detected = info["provider"]
    info["result"] = None
    info["resultSource"] = None
    info["explanation"] = None
    info["terminalEventSeen"] = False
    events = [event for _lineno, event in read_events(path) if event is not None]
    SCANNERS[provider](events, info)
    info["provider"] = provider
    info["providerDetected"] = detected
    info["hasResult"] = bool(info["result"] and info["result"].strip())
    return info
