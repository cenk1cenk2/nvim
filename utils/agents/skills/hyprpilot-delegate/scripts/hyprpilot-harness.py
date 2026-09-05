#!/usr/bin/env python3
"""Wait on, resolve, judge, collect and tear down hyprpilot sessions from a shell, without calling MCP."""

from __future__ import annotations

import argparse
import json
import logging
import os
import sys
import time
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import turns as ht  # noqa: E402
from lib.cli import EarlyExit, ScriptError, create_logger  # noqa: E402

GLOB_CHARS = "*?["


def absolute_path(value: str, what: str) -> str:
    """Refuse a relative or globbed path; a glob false-positives on a sibling turn."""
    for ch in GLOB_CHARS:
        if ch in value:
            raise ScriptError(f"{what} contains the glob character {ch!r}; pass the exact path")
    if not value.startswith("/"):
        raise ScriptError(f"{what} must be an absolute path, got: {value}")
    return value


def positive_int(value: str) -> int:
    if not value.isdigit() or int(value) <= 0:
        raise argparse.ArgumentTypeError(f"must be a positive integer, got: {value}")
    return int(value)


def non_negative_number(value: str) -> float:
    try:
        number = float(value)
    except ValueError:
        raise argparse.ArgumentTypeError(f"must be a number of seconds, got: {value}") from None
    if number < 0:
        raise argparse.ArgumentTypeError(f"must not be negative, got: {value}")
    return number


def non_negative_int(value: str) -> int:
    if not value.isdigit():
        raise argparse.ArgumentTypeError(f"must be a non-negative integer, got: {value}")
    return int(value)


def load_json(source: str, what: str) -> Any:
    try:
        if source == "-":
            return json.load(sys.stdin)
        with open(source, encoding="utf-8") as handle:
            return json.load(handle)
    except OSError as err:
        raise ScriptError(f"cannot read {what}: {err}") from err
    except ValueError as err:
        raise ScriptError(f"{what} is not JSON: {err}") from err


# --- wait -----------------------------------------------------------------------------------------


class TurnWaiter:
    """Poll one turn's done.json under a ceiling. The watcher payload: it is what wakes the session."""

    log = logging.getLogger("harness.wait")

    def __init__(self, args: argparse.Namespace):
        self.args = args
        self.flat_since: float | None = None
        self.flat_size: int | None = None
        if args.turn_dir and args.done_file:
            raise ScriptError("pass exactly one of --turn-dir and --done-file, not both")
        if args.turn_dir:
            absolute_path(args.turn_dir, "--turn-dir")
            self.done_file = args.turn_dir.rstrip("/") + "/done.json"
        elif args.done_file:
            absolute_path(args.done_file, "--done-file")
            if not args.done_file.endswith("/done.json"):
                raise ScriptError(f"--done-file must end in /done.json, got: {args.done_file}")
            self.done_file = args.done_file
        else:
            raise ScriptError("--turn-dir is required (use sessionInfo.files.turnDir verbatim)")
        self.turn_dir = os.path.dirname(self.done_file)
        self.transcript = os.path.join(self.turn_dir, "turns.jsonl")
        # The standard layout is SESSION/turns/N/done.json, so the session root is
        # three levels up. --session-dir overrides it from sessionInfo.files.dir.
        if args.session_dir:
            absolute_path(args.session_dir, "--session-dir")
            self.session_dir = args.session_dir
        else:
            self.session_dir = os.path.dirname(os.path.dirname(self.turn_dir))
        if self.session_dir in ("", "/"):
            raise ScriptError("refusing to watch / as a session directory")
        # The harness creates a turn's directory before the spawn or session_send
        # call returns, so an absent turnDir under a session that is still there is
        # a guessed turn index rather than a real turn. Polling it to the ceiling is
        # how a mis-armed watcher goes quiet for an hour; refusing it is immediate.
        # A session directory that is gone too is eviction, not a guess - the first
        # poll reports that as the dir-gone ending instead.
        if not os.path.isdir(self.turn_dir) and os.path.isdir(self.session_dir):
            raise ScriptError(
                f"turn directory does not exist: {self.turn_dir}\n"
                f"Its session directory {self.session_dir} does exist, so this is a derived turn index, "
                "not a turn. Take sessionInfo.files.turnDir verbatim from the spawn or session_send "
                "response that just returned; never compute the turn number."
            )

    def probe(self) -> tuple[bool, str]:
        if os.path.isfile(self.done_file):
            return True, "done.json present"
        if not os.path.isdir(self.session_dir):
            raise EarlyExit(
                10,
                f"session directory gone: {self.session_dir}",
                "session_status, then session_list - the transcript may already be evicted. "
                "The result outlives the directory; the marker does not.",
            )
        if self.args.stall_after is None:
            return False, "running"
        # The transcript's byte count is the shell-side transcriptBytes. Flat for
        # --stall-after while the marker is absent is a wedge. A transcript the
        # vendor has not started writing is not a stall.
        try:
            size = os.path.getsize(self.transcript)
        except OSError:
            self.flat_since = None
            self.flat_size = None
            return False, "running, transcript absent"
        now = time.monotonic()
        if size != self.flat_size:
            self.flat_size = size
            self.flat_since = now
            return False, f"running, {size} bytes"
        flat_for = now - (self.flat_since or now)
        if flat_for >= self.args.stall_after:
            raise EarlyExit(
                11,
                f"transcript flat at {size} bytes for {flat_for:.0f}s, turn not done",
                "session_status. Running with transcriptBytes unchanged is a wedged agent - "
                "report it, do not kill on it reflexively.",
            )
        return False, f"running, {size} bytes"

    def run(self) -> int:
        a = self.args
        label = a.label or self.done_file
        if not a.quiet:
            print(f"watching {label}")
            print(f"done file:   {self.done_file}")
            print(f"session dir: {self.session_dir}")
            if a.stall_after is not None:
                print(f"stall:       {a.stall_after}s without transcript growth")
            print(f"ceiling:     {a.max_polls} polls at {a.interval:g}s")
            sys.stdout.flush()
        # An already-evicted session ends the watch now rather than at the ceiling.
        if not os.path.isdir(self.session_dir):
            print(f"RESULT: {label} session directory {self.session_dir} is already gone before the first poll")
            print(
                "next: session_status, then session_list - the transcript may already be evicted. "
                "The result outlives the directory; the marker does not."
            )
            return 10
        for i in range(1, a.max_polls + 1):
            try:
                met, value = self.probe()
            except EarlyExit as err:
                print(f"RESULT: {label} {err.result} after {i} poll(s)")
                print(f"next: {err.advice}")
                return err.exit_code
            self.log.debug("poll %d met=%s value=%s", i, met, value)
            if met:
                print(f"RESULT: {label} done after {i} poll(s)")
                print("next: session_status for exitCode and hasResult, then read the turn result")
                return 0
            if i < a.max_polls:
                time.sleep(a.interval)
        print(f"RESULT: {label} not done after {a.max_polls} poll(s)")
        print("next: session_status first. A ceiling hit is usually a stale done path, not a failed agent.")
        print(
            "If status is running, re-arm against the turnDir from the CURRENT session_status response. "
            "Never glob for done.json, and never compute the turn number."
        )
        return 1


# --- resolve --------------------------------------------------------------------------------------


class SpawnResolver:
    """Match a profile from a `list_profiles` listing and validate the spawn arguments."""

    log = logging.getLogger("harness.resolve")

    CLAUDE_MODES = ("auto", "default", "acceptEdits", "dontAsk")
    OPENCODE_MODES = ("build", "plan")
    WITH_CONFIG_KEYS = ("model", "effort", "mode")
    # Claude's own gate-removing mode. Narrowing is a skill decision; widening never is.
    REFUSED_CLAUDE_MODES = ("bypassPermissions",)
    THIN_PROMPT_CHARS = 120

    def __init__(self, rows: list[dict[str, Any]]):
        self.rows = rows
        self.warnings: list[str] = []

    @classmethod
    def from_listing(cls, source: str) -> SpawnResolver:
        data = load_json(source, "--profiles")
        if isinstance(data, dict) and isinstance(data.get("profiles"), list):
            rows = data["profiles"]
        elif isinstance(data, list):
            rows = data
        else:
            raise ScriptError('--profiles must be the list_profiles result ({"profiles": [...]})')
        rows = [r for r in rows if isinstance(r, dict) and isinstance(r.get("id"), str)]
        if not rows:
            raise ScriptError("--profiles carries no profile rows with an id")
        return cls(rows)

    @staticmethod
    def vendor_of(row: dict[str, Any]) -> str:
        provider = str(row.get("provider") or row.get("agent") or "").lower()
        for name in ("claude", "opencode", "codex"):
            if provider.startswith(name):
                return name
        return provider or "unknown"

    def match(self, want: str) -> list[dict[str, Any]]:
        exact = [r for r in self.rows if r["id"] == want]
        if exact:
            return exact
        tokens = [t for t in want.lower().split() if t]
        found = [r for r in self.rows if all(t in r["id"].lower() for t in tokens)]
        self.log.debug("%r matched %d of %d profiles", want, len(found), len(self.rows))
        return found

    def pick(self, want: str) -> dict[str, Any]:
        matches = self.match(want)
        if not matches:
            lines = [f"no profile matches {want!r}. Available:"]
            lines += [f"  {r['id']}  ({r.get('provider', '?')})" for r in self.rows]
            lines.append("next: show the user what is available; do not guess a neighbour.")
            raise ScriptError("\n".join(lines), exit_code=3)
        if len(matches) > 1:
            lines = [f"{want!r} is ambiguous between:"]
            lines += [f"  {r['id']}  ({r.get('provider', '?')})" for r in matches]
            lines.append("next: ask the user which one; do not guess.")
            raise ScriptError("\n".join(lines), exit_code=3)
        row = matches[0]
        if row.get("error"):
            raise ScriptError(
                f"profile {row['id']} failed to resolve: {row['error']}\nnext: report the error; do not launch it.",
                exit_code=3,
            )
        return row

    def check_tool_spelling(self, token: str) -> None:
        """A --disallowedTools entry is parsed by the spawned claude CLI, which keeps the
        catalog's kebab server keys. An underscored server component is the Hermes wire
        spelling and matches nothing there, which blocks nothing and raises nothing."""
        value = token.split("=", 1)[1] if "=" in token else token
        for entry in value.split(","):
            entry = entry.strip()
            if not entry.startswith("mcp__"):
                continue
            parts = entry.split("__")
            if len(parts) < 3:
                self.warnings.append(f"{entry!r} is not a server__tool name; it matches nothing")
            elif "_" in parts[1]:
                self.warnings.append(
                    f"{entry!r} spells the server with underscores; the spawned CLI keeps the kebab key, "
                    "so this entry blocks nothing"
                )

    def validate(self, args: argparse.Namespace, row: dict[str, Any]) -> dict[str, Any]:
        vendor = self.vendor_of(row)
        call: dict[str, Any] = {"profile": row["id"]}

        if args.prompt is not None and args.prompt_file is not None:
            raise ScriptError("--prompt and --prompt-file are mutually exclusive")
        if args.prompt is not None:
            if not args.prompt.strip():
                raise ScriptError("--prompt is empty")
            if len(args.prompt) < self.THIN_PROMPT_CHARS:
                self.warnings.append(
                    f"prompt is {len(args.prompt)} characters; the agent cannot see this conversation, "
                    "so a thin brief costs a whole session"
                )
            call["prompt"] = args.prompt
        elif args.prompt_file is not None:
            path = absolute_path(args.prompt_file, "--prompt-file")
            if not os.path.isfile(path):
                raise ScriptError(f"--prompt-file does not exist: {path}")
            call["file"] = path
        else:
            self.warnings.append("no prompt given; the call is incomplete until --prompt or --prompt-file is added")

        if args.cwd is not None:
            path = absolute_path(args.cwd, "--cwd")
            if not os.path.isdir(path):
                self.warnings.append(f"--cwd {path} is not a directory on this host; a launch there fails")
            call["cwd"] = path

        mode = args.mode
        if args.read_only:
            if vendor == "claude":
                mode = mode or "auto"
                if mode == "plan":
                    raise ScriptError(
                        "claude read-only is mode auto plus a --disallowedTools write block, never "
                        "mode plan: plan gates the skill discovery the agent must run on turn one"
                    )
                if not any(a.startswith("--disallowedTools") for a in args.arg):
                    raise ScriptError(
                        "--read-only on claude needs a --disallowedTools write block in --arg; "
                        "mode alone restricts nothing"
                    )
            elif vendor == "opencode":
                mode = mode or "plan"
                if mode != "plan":
                    raise ScriptError(f"opencode read-only is mode plan, got: {mode}")
            elif vendor == "codex":
                raise ScriptError(
                    "codex has no plan mode and no tool allow list in the harness; restrict "
                    "through a profile that already carries the policy"
                )

        if mode is not None:
            if vendor == "claude":
                if mode in self.REFUSED_CLAUDE_MODES:
                    raise ScriptError(f"mode {mode} widens the agent's authority; refused")
                if mode == "plan":
                    raise ScriptError(
                        "mode plan on claude gates the skill discovery the spawned agent runs on "
                        "turn one; use mode auto plus a --disallowedTools write block"
                    )
                if mode not in self.CLAUDE_MODES:
                    raise ScriptError(f"claude mode must be one of {', '.join(self.CLAUDE_MODES)}, got: {mode}")
            elif vendor == "opencode":
                if mode not in self.OPENCODE_MODES:
                    raise ScriptError(f"opencode mode must be one of {', '.join(self.OPENCODE_MODES)}, got: {mode}")
            elif vendor == "codex":
                raise ScriptError("codex profiles carry no mode; the listing shows none, so --mode is refused")
            call["mode"] = mode

        if args.arg:
            for token in args.arg:
                if "--disallowedTools" in token or "--allowedTools" in token:
                    self.check_tool_spelling(token)
                if "dangerously" in token or token == "--yolo" or "bypass" in token.lower():
                    raise ScriptError(f"argument {token!r} widens the agent's authority; refused")
            if vendor == "opencode":
                self.warnings.append(
                    "opencode run exposes no tool allow or deny list through args; confirm each "
                    "flag against `opencode run --help` before launching"
                )
            call["args"] = list(args.arg)

        if args.with_config is not None:
            try:
                overlay = json.loads(args.with_config)
            except ValueError as err:
                raise ScriptError(f"--with-config is not JSON: {err}") from err
            if not isinstance(overlay, list) or not all(isinstance(o, dict) for o in overlay):
                raise ScriptError('--with-config must be an array of objects, e.g. [{"model": "..."}]')
            for obj in overlay:
                bad = sorted(k for k in obj if k not in self.WITH_CONFIG_KEYS)
                if bad:
                    raise ScriptError(
                        f"--with-config key(s) {', '.join(bad)} are refused by spawn; only "
                        f"{', '.join(self.WITH_CONFIG_KEYS)} are accepted, and a refused key fails the whole launch"
                    )
            call["with_config"] = overlay
            if any("model" in o for o in overlay):
                self.warnings.append("an overridden model is reported only in sessionInfo.model, never as the profile")

        if args.wait:
            self.warnings.append(
                "wait: true returns the whole raw event stream inline and still comes back running "
                "past timeout_seconds; detach and collect through the result resource instead"
            )
            call["wait"] = True

        if row.get("headless"):
            self.warnings.append("profile is headless; it cannot be driven interactively")
        return call

    def run(self, args: argparse.Namespace) -> int:
        row = self.pick(args.want)
        call = self.validate(args, row)
        if not args.json:
            sys.stderr.write(
                f"profile: {row['id']}  vendor={self.vendor_of(row)}  model={row.get('model', '<unset>')}  "
                f"mode={row.get('mode', '<unset>')}  headless={row.get('headless', False)}\n"
            )
            for w in self.warnings:
                sys.stderr.write(f"warning: {w}\n")
            sys.stderr.write(
                "next: present profile, cwd and prompt to the user, then hyprpilot-harness spawn "
                "with the call below. Take sessionInfo.files.turnDir from its response.\n"
            )
        json.dump(call, sys.stdout, indent=2, sort_keys=True)
        sys.stdout.write("\n")
        return 0


# --- verdict --------------------------------------------------------------------------------------


class SessionVerdict:
    """Turn one `session_status` reading, plus a ledger of earlier ones, into the next action."""

    log = logging.getLogger("harness.verdict")
    EXIT = {"collect": 0, "running": 4, "wedged": 5, "inspect": 6, "steer": 7}

    def __init__(self, args: argparse.Namespace):
        self.args = args
        self.reading = self.parse_reading(args)

    @staticmethod
    def parse_bool(value: Any, what: str) -> bool:
        if isinstance(value, bool):
            return value
        text = str(value).lower()
        if text in ("true", "1", "yes"):
            return True
        if text in ("false", "0", "no"):
            return False
        raise ScriptError(f"{what} must be true or false, got: {value}")

    @staticmethod
    def parse_int(value: Any, what: str) -> int | None:
        if value is None:
            return None
        try:
            return int(value)
        except (TypeError, ValueError):
            raise ScriptError(f"{what} must be an integer, got: {value}") from None

    def parse_reading(self, args: argparse.Namespace) -> dict[str, Any]:
        status, exit_code, has_result, transcript_bytes, turn = (
            args.status,
            args.exit_code,
            args.has_result,
            args.transcript_bytes,
            args.turn,
        )
        if args.json is not None:
            if status is not None:
                raise ScriptError("pass --json or the field flags, not both")
            data = load_json(args.json, "--json")
            if not isinstance(data, dict):
                raise ScriptError("--json must be the session_status object")
            status = data.get("status")
            exit_code = data.get("exitCode")
            has_result = data.get("hasResult")
            transcript_bytes = data.get("transcriptBytes")
            turn = data.get("turn")
        if status not in ("running", "exited"):
            raise ScriptError(f"--status must be running or exited, got: {status}")
        reading = {
            "ts": time.time(),
            "status": status,
            "exitCode": self.parse_int(exit_code, "--exit-code"),
            "hasResult": self.parse_bool(has_result, "--has-result") if has_result is not None else None,
            "transcriptBytes": self.parse_int(transcript_bytes, "--transcript-bytes"),
            "turn": self.parse_int(turn, "--turn"),
        }
        if reading["status"] == "exited" and reading["exitCode"] is None:
            raise ScriptError("an exited turn carries an exit code; pass --exit-code")
        if args.ledger is not None:
            absolute_path(args.ledger, "--ledger")
        if args.turn_dir is not None:
            absolute_path(args.turn_dir, "--turn-dir")
        return reading

    @staticmethod
    def read_ledger(path: str) -> list[dict[str, Any]]:
        entries: list[dict[str, Any]] = []
        if not os.path.isfile(path):
            return entries
        with open(path, encoding="utf-8", errors="replace") as handle:
            for line in handle:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except ValueError:
                    continue
                if isinstance(entry, dict):
                    entries.append(entry)
        return entries

    @staticmethod
    def append_ledger(path: str, entry: dict[str, Any]) -> None:
        try:
            with open(path, "a", encoding="utf-8") as handle:
                handle.write(json.dumps(entry, sort_keys=True) + "\n")
        except OSError as err:
            raise ScriptError(f"cannot write --ledger: {err}") from err

    @staticmethod
    def flat_span(entries: list[dict[str, Any]], current: dict[str, Any]) -> float:
        """Seconds since the earliest consecutive running reading with the same bytes on the same turn."""
        if current.get("transcriptBytes") is None:
            return 0.0
        earliest = current["ts"]
        for entry in reversed(entries):
            if entry.get("turn") != current.get("turn") or entry.get("status") != "running":
                break
            if entry.get("transcriptBytes") != current["transcriptBytes"]:
                break
            earliest = entry.get("ts", earliest)
        return max(0.0, current["ts"] - earliest)

    def decide(self, span: float) -> tuple[str, str]:
        r = self.reading
        if r["status"] == "running":
            if span >= self.args.flat_after:
                return "wedged", (
                    f"transcriptBytes {r['transcriptBytes']} unchanged for {int(span)}s with status running. "
                    "That is a wedged agent, which status alone cannot show. Report it; kill only on a decision."
                )
            return "running", "the turn is in flight; poll session_status again, and do not spawn again"
        if r["exitCode"] == 0:
            note = "read the result resource, then check the answer against the brief"
            if r["hasResult"] is False:
                note += "; hasResult is false on a clean exit, so the resource will name which no-answer shape it was"
            return "collect", note
        if self.args.turn_dir:
            try:
                info = ht.scan(ht.resolve_transcript(self.args.turn_dir))
            except ht.TranscriptError as err:
                self.log.debug("turn dir unreadable: %s", err)
                info = None
            if info and info.get("subtype") == "error_max_turns":
                return "steer", (
                    f"claude ended on error_max_turns (num_turns={info.get('numTurns')}). The agent holds its "
                    "context: read what landed, then session_send only the remaining work to the SAME handle. "
                    "Do not re-spawn; do not reap."
                )
            if info and info.get("errors"):
                return "inspect", "runtime failure in the transcript: " + "; ".join(info["errors"][:3])
        return "inspect", (
            f"exit code {r['exitCode']}. The result resource names the failure; a launch failure is in stderr "
            "with an empty transcript, a runtime one is an error event with stderr empty. Read before re-dispatching."
        )

    def run(self) -> int:
        span = 0.0
        readings = 0
        if self.args.ledger:
            entries = self.read_ledger(self.args.ledger)
            readings = len(entries) + 1
            span = self.flat_span(entries, self.reading)
            self.log.debug("ledger holds %d earlier reading(s), flat for %.0fs", len(entries), span)
            self.append_ledger(self.args.ledger, self.reading)
        verdict, note = self.decide(span)
        r = self.reading
        report = {
            "verdict": verdict,
            "note": note,
            "status": r["status"],
            "exitCode": r["exitCode"],
            "hasResult": r["hasResult"],
            "transcriptBytes": r["transcriptBytes"],
            "turn": r["turn"],
            "flatSeconds": int(span),
            "ledgerReadings": readings,
        }
        if self.args.output == "json":
            json.dump(report, sys.stdout, indent=2, sort_keys=True)
            sys.stdout.write("\n")
        else:
            sys.stdout.write(f"verdict: {verdict}\n")
            sys.stdout.write(
                f"status={r['status']} exitCode={r['exitCode']} hasResult={r['hasResult']} "
                f"transcriptBytes={r['transcriptBytes']} turn={r['turn']}\n"
            )
            if self.args.ledger:
                sys.stdout.write(f"ledger: {readings} reading(s), transcript flat for {int(span)}s\n")
            sys.stdout.write(f"next: {note}\n")
        return self.EXIT[verdict]


# --- result ---------------------------------------------------------------------------------------


class TurnResult:
    """Extract the final agent text from one turn transcript, and say why when there is none."""

    log = logging.getLogger("harness.result")

    def __init__(self, args: argparse.Namespace):
        self.args = args
        self.path = ht.resolve_transcript(args.transcript)

    @staticmethod
    def exit_code(info: dict[str, Any]) -> int:
        """0 = complete answer, 4 = partial (no terminal event), 3 = nothing found."""
        if not info["hasResult"]:
            return 3
        return 0 if info["terminalEventSeen"] else 4

    def run(self) -> int:
        args = self.args
        info = ht.scan(self.path)
        if args.provider != "auto" and info["provider"] != args.provider:
            self.log.debug("forcing provider %s over detected %s", args.provider, info["provider"])
            info = ht.rescan_as(self.path, args.provider)

        result = info["result"]
        if result and args.max_chars and len(result) > args.max_chars:
            result = result[: args.max_chars] + f"\n[truncated at {args.max_chars} characters]"

        if args.json:
            report = dict(info)
            report["result"] = result
            json.dump(report, sys.stdout, indent=2, sort_keys=True)
            sys.stdout.write("\n")
            return self.exit_code(info)

        if info["hasResult"]:
            # A partial answer must announce itself even under --quiet: handing back a
            # running turn's last sentence as "the result" is how a half-finished
            # delegation gets reported as done.
            if args.quiet and not info["terminalEventSeen"]:
                sys.stderr.write(
                    "warning: no terminal event in this transcript - the turn is still "
                    "running or was killed. This is a PARTIAL result.\n"
                )
            if not args.quiet:
                sys.stderr.write(
                    f"provider={info['provider']} source={info['resultSource']} "
                    f"events={info['events']} bytes={info['bytes']}\n"
                )
                if info["explanation"]:
                    sys.stderr.write(f"note: {info['explanation']}\n")
                if info["errors"]:
                    sys.stderr.write("errors in transcript: " + "; ".join(info["errors"]) + "\n")
            sys.stdout.write(result)
            if not result.endswith("\n"):
                sys.stdout.write("\n")
            return self.exit_code(info)

        sys.stderr.write(f"no agent result in {self.path}\n")
        sys.stderr.write(
            f"provider={info['provider']} events={info['events']} bytes={info['bytes']} "
            f"unparsable={info['unparsableLines']}\n"
        )
        if info["eventCounts"]:
            sys.stderr.write(
                "event types: " + ", ".join(f"{k}={v}" for k, v in sorted(info["eventCounts"].items())) + "\n"
            )
        if info["explanation"]:
            sys.stderr.write(f"reason: {info['explanation']}\n")
        if info["errors"]:
            sys.stderr.write("errors in transcript: " + "; ".join(info["errors"]) + "\n")
        sys.stderr.write(
            "next: session_status on the handle, then read the turn's stderr.log "
            "(a launch failure writes there and leaves this file empty).\n"
        )
        return 3


# --- inspect --------------------------------------------------------------------------------------


class SessionInspector:
    """Report every turn of a session directory read-only: state, terminal event, recoverable result."""

    log = logging.getLogger("harness.inspect")
    SAFE_SESSION_KEYS = ("handle", "startedAt", "startTicks")

    def __init__(self, args: argparse.Namespace):
        self.args = args
        self.session_dir = self.resolve_session_dir(args.session_dir)

    @staticmethod
    def resolve_session_dir(path: str) -> str:
        absolute_path(path, "session directory")
        path = os.path.abspath(os.path.expanduser(path))
        if not os.path.exists(path):
            raise ScriptError(f"directory does not exist: {path}")
        if not os.path.isdir(path):
            raise ScriptError(f"not a directory: {path}")
        if os.path.basename(os.path.dirname(path)) == "turns":
            path = os.path.dirname(os.path.dirname(path))
        if not os.path.isdir(os.path.join(path, "turns")):
            raise ScriptError(f"{path} has no turns/ directory; this is not a Hyprpilot session root")
        return path

    def read_session_json(self) -> dict[str, Any]:
        """The safe subset of session.json, plus the names of what is held back."""
        path = os.path.join(self.session_dir, "session.json")
        out: dict[str, Any] = {"path": path, "present": os.path.isfile(path), "withheldKeys": []}
        if not out["present"]:
            return out
        try:
            with open(path, encoding="utf-8", errors="replace") as handle:
                data = json.load(handle)
        except (ValueError, OSError) as err:
            out["error"] = f"unreadable: {err}"
            return out
        if not isinstance(data, dict):
            out["error"] = "session.json is not an object"
            return out
        for key in self.SAFE_SESSION_KEYS:
            if key in data:
                out[key] = data[key]
        out["withheldKeys"] = sorted(k for k in data if k not in self.SAFE_SESSION_KEYS)
        return out

    @staticmethod
    def turn_numbers(session_dir: str) -> list[int]:
        turns_root = os.path.join(session_dir, "turns")
        return sorted(
            int(e) for e in os.listdir(turns_root) if e.isdigit() and os.path.isdir(os.path.join(turns_root, e))
        )

    def inspect_turn(self, number: int) -> dict[str, Any]:
        turn_dir = os.path.join(self.session_dir, "turns", str(number))
        report: dict[str, Any] = {
            "turn": number,
            "dir": turn_dir,
            "donePresent": False,
            "doneExitCode": None,
            "doneFinishedAt": None,
            "stderrBytes": None,
            "transcriptBytes": None,
            "transcriptPresent": False,
        }
        done_path = os.path.join(turn_dir, "done.json")
        if os.path.isfile(done_path):
            report["donePresent"] = True
            report["donePath"] = done_path
            try:
                with open(done_path, encoding="utf-8", errors="replace") as handle:
                    done = json.load(handle)
                if isinstance(done, dict):
                    report["doneExitCode"] = done.get("exitCode")
                    report["doneFinishedAt"] = done.get("finishedAt")
            except (ValueError, OSError) as err:
                report["doneError"] = f"unreadable: {err}"
        stderr_path = os.path.join(turn_dir, "stderr.log")
        if os.path.isfile(stderr_path):
            report["stderrPath"] = stderr_path
            report["stderrBytes"] = os.path.getsize(stderr_path)
        transcript_path = os.path.join(turn_dir, "turns.jsonl")
        if os.path.isfile(transcript_path):
            report["transcriptPresent"] = True
            report["transcriptPath"] = transcript_path
            report["transcriptBytes"] = os.path.getsize(transcript_path)
            scan = ht.scan(transcript_path)
            for key in (
                "provider",
                "events",
                "unparsableLines",
                "eventCounts",
                "hasResult",
                "resultSource",
                "subtype",
                "terminalReason",
                "numTurns",
                "errors",
                "explanation",
                "terminalEventSeen",
            ):
                report[key] = scan[key]
            report["resultChars"] = len(scan["result"] or "")
        report["verdict"] = self.verdict_for(report)
        return report

    @staticmethod
    def verdict_for(report: dict[str, Any]) -> str:
        if not report["transcriptPresent"]:
            return "no transcript on disk - the turn directory exists but the vendor wrote nothing"
        if report["transcriptBytes"] == 0:
            stderr = report["stderrBytes"] if report["stderrBytes"] is not None else "no"
            return (
                f"empty transcript with {stderr} bytes of stderr - launch failure shape; "
                "read stderr.log for the vendor's message"
            )
        if not report["donePresent"]:
            return (
                "no done.json - this turn is still running, or was killed mid-turn. "
                "Each turn owns its own directory, so absence never means error"
            )
        if report.get("subtype") == "error_max_turns":
            tail = (
                "A result is recoverable from the last assistant text."
                if report.get("hasResult")
                else "No assistant text to recover."
            )
            return (
                f"max_turns (num_turns={report.get('numTurns')}). The agent kept its full context: steer THIS "
                f"session with session_send and a short remaining-work prompt. Do not re-spawn. {tail}"
            )
        if report.get("doneExitCode") not in (0, None) and not report.get("hasResult"):
            return (
                f"exit code {report.get('doneExitCode')} and no result text - read stderr.log for a launch "
                "failure, or the transcript's error events for a runtime one"
            )
        if report.get("hasResult"):
            return (
                f"finished with a recoverable result ({report.get('resultChars', 0)} characters, "
                f"from {report.get('resultSource')})"
            )
        return "finished, but no agent result was found - see the reason line"

    def render_text(self, session: dict[str, Any], turns: list[dict[str, Any]], stream) -> None:
        stream.write(f"session dir: {self.session_dir}\n")
        if session["present"]:
            stream.write(f"handle:      {session.get('handle', '<absent from session.json>')}\n")
            stream.write(f"startedAt:   {session.get('startedAt', '<absent>')}\n")
            if session.get("error"):
                stream.write(f"session.json: {session['error']}\n")
            if session["withheldKeys"]:
                stream.write("session.json other keys (values withheld): " + ", ".join(session["withheldKeys"]) + "\n")
        else:
            stream.write("session.json: absent\n")
        stream.write("turns found: " + (", ".join(str(t["turn"]) for t in turns) or "none") + "\n\n")
        for report in turns:
            stream.write(f"turn {report['turn']}  {report['dir']}\n")
            stream.write(
                f"  transcript: {report.get('transcriptBytes', 'n/a')} bytes, {report.get('events', 'n/a')} events, "
                f"provider={report.get('provider', 'n/a')}, unparsable={report.get('unparsableLines', 'n/a')}\n"
            )
            done = (
                "absent"
                if not report["donePresent"]
                else (f"present (exitCode={report['doneExitCode']} finishedAt={report['doneFinishedAt']})")
            )
            stream.write(f"  done.json:  {done}\n")
            stderr = (
                f"{report['stderrBytes']} bytes (content not printed)"
                if report["stderrBytes"] is not None
                else "absent"
            )
            stream.write(f"  stderr.log: {stderr}\n")
            if report.get("eventCounts"):
                stream.write(
                    "  events:     " + ", ".join(f"{k}={v}" for k, v in sorted(report["eventCounts"].items())) + "\n"
                )
            if report.get("terminalEventSeen") is not None:
                stream.write(
                    f"  terminal:   seen={report.get('terminalEventSeen')} subtype={report.get('subtype')} "
                    f"terminal_reason={report.get('terminalReason')} num_turns={report.get('numTurns')}\n"
                )
            has = "yes" if report.get("hasResult") else "no"
            via = (
                f" ({report.get('resultChars', 0)} characters via {report.get('resultSource')})"
                if report.get("hasResult")
                else ""
            )
            stream.write(f"  result:     {has}{via}\n")
            for err in (report.get("errors") or [])[: self.args.max_errors]:
                stream.write(f"  error:      {err}\n")
            if report.get("explanation"):
                stream.write(f"  reason:     {report['explanation']}\n")
            stream.write(f"  verdict:    {report['verdict']}\n\n")
        stream.write(
            "reminder: this is disk evidence only. session_status on the handle is the "
            "authoritative view, and the transcript is the only place a runtime error "
            "(auth, quota, model unavailable) shows up when stderr.log is empty.\n"
        )

    def run(self) -> int:
        numbers = self.turn_numbers(self.session_dir)
        if self.args.turn is not None:
            if self.args.turn not in numbers:
                raise ScriptError(
                    f"turn {self.args.turn} not present; turns found: " + (", ".join(str(n) for n in numbers) or "none")
                )
            numbers = [self.args.turn]
        session = self.read_session_json()
        turns = [self.inspect_turn(n) for n in numbers]
        if self.args.json:
            json.dump(
                {"sessionDir": self.session_dir, "session": session, "turns": turns},
                sys.stdout,
                indent=2,
                sort_keys=True,
            )
            sys.stdout.write("\n")
        else:
            self.render_text(session, turns, sys.stdout)
        return 0 if turns else 3


# --- teardown -------------------------------------------------------------------------------------


class TeardownChecklist:
    """List what a session leaves behind before it is reaped: uncollected turns and live watcher processes."""

    log = logging.getLogger("harness.teardown")
    # This script both waits and tears down, so a marker match alone would find
    # the running teardown itself. A watcher is this script running `wait`, or a
    # generic watch.py armed on a session path by hand.
    WATCHER_MARKERS = ("hyprpilot-harness.py", "watch.py")

    def __init__(self, args: argparse.Namespace):
        self.args = args
        self.session_dir = self.resolve_session_dir(args.session_dir)

    @staticmethod
    def resolve_session_dir(path: str) -> str:
        absolute_path(path, "session directory")
        path = os.path.normpath(path)
        if path == "/":
            raise ScriptError("refusing to treat / as a session directory")
        # A turn directory resolves to its session root whether or not it still exists.
        parent = os.path.dirname(path)
        if os.path.basename(parent) == "turns":
            path = os.path.dirname(parent)
        return path

    def scan_turns(self) -> list[dict[str, Any]]:
        turns_root = os.path.join(self.session_dir, "turns")
        reports: list[dict[str, Any]] = []
        if not os.path.isdir(turns_root):
            return reports
        for number in SessionInspector.turn_numbers(self.session_dir):
            turn_dir = os.path.join(turns_root, str(number))
            report: dict[str, Any] = {
                "turn": number,
                "dir": turn_dir,
                "done": os.path.isfile(os.path.join(turn_dir, "done.json")),
                "exitCode": None,
                "hasResult": False,
                "subtype": None,
                "transcriptBytes": None,
            }
            if report["done"]:
                try:
                    with open(os.path.join(turn_dir, "done.json"), encoding="utf-8", errors="replace") as handle:
                        done = json.load(handle)
                    if isinstance(done, dict):
                        report["exitCode"] = done.get("exitCode")
                except (ValueError, OSError):
                    pass
            transcript = os.path.join(turn_dir, "turns.jsonl")
            if os.path.isfile(transcript):
                report["transcriptBytes"] = os.path.getsize(transcript)
                info = ht.scan(transcript)
                report["hasResult"] = info["hasResult"]
                report["subtype"] = info["subtype"]
            reports.append(report)
        return reports

    def scan_watchers(self) -> list[dict[str, Any]] | None:
        """Processes whose argv names a watcher script and a path under the session directory."""
        try:
            entries = os.listdir(self.args.proc)
        except OSError:
            return None
        prefix = self.session_dir.rstrip("/") + "/"
        found = []
        own_pid = str(os.getpid())
        for entry in entries:
            if not entry.isdigit() or entry == own_pid:
                continue
            try:
                with open(os.path.join(self.args.proc, entry, "cmdline"), "rb") as handle:
                    raw = handle.read()
            except OSError:
                continue
            argv = [a.decode("utf-8", errors="replace") for a in raw.split(b"\0") if a]
            script = next((a for a in argv if any(m in a for m in self.WATCHER_MARKERS)), None)
            if script is None:
                continue
            if "hyprpilot-harness.py" in script and "wait" not in argv:
                continue
            watched = [a for a in argv if a == self.session_dir or a.startswith(prefix)]
            if not watched:
                continue
            found.append({"pid": int(entry), "script": script, "watched": watched[0]})
        self.log.debug("scanned %d process entries, %d watcher(s) on this session", len(entries), len(found))
        return sorted(found, key=lambda w: w["pid"])

    @staticmethod
    def classify(
        watcher: dict[str, Any], session_present: bool, turns_by_dir: dict[str, dict[str, Any]]
    ) -> tuple[str, str]:
        target = watcher["watched"].rstrip("/")
        if target.endswith("/done.json"):
            target = os.path.dirname(target)
        if not session_present:
            return "orphan", "the session directory is gone; this watcher will report the cleanup as a finish"
        turn = turns_by_dir.get(target)
        if turn is None:
            return "unknown", "polls a path that is not a turn of this session"
        if turn["done"]:
            return "stale", f"turn {turn['turn']} already finished; left running it double-wakes the next turn"
        return "live", f"turn {turn['turn']} is still running; keep it until the turn ends, then reap it"

    def build(self) -> dict[str, Any]:
        session_present = os.path.isdir(self.session_dir)
        turns = self.scan_turns() if session_present else []
        watchers = self.scan_watchers()
        turns_by_dir = {t["dir"]: t for t in turns}
        for watcher in watchers or []:
            watcher["state"], watcher["note"] = self.classify(watcher, session_present, turns_by_dir)

        steps: list[str] = []
        for turn in turns:
            n = turn["turn"]
            if not turn["done"]:
                steps.append(f"turn {n} is still running: do not reap; wait for its watcher or poll session_status")
            elif turn["subtype"] == "error_max_turns":
                steps.append(f"turn {n} ended on error_max_turns: steer this session with session_send, do not reap")
            elif turn["hasResult"]:
                steps.append(
                    f"collect turn {n} before reaping (read the turn's result resource) unless already collected"
                )
            else:
                steps.append(
                    f"turn {n} finished with exit code {turn['exitCode']} and no result text: "
                    "read its result resource for the failure"
                )
        for watcher in watchers or []:
            if watcher["state"] in ("stale", "orphan", "unknown"):
                steps.append(
                    f"stop watcher pid {watcher['pid']} ({watcher['state']}: {watcher['note']}) through the "
                    "facility that launched it, then verify it is gone"
                )
            else:
                steps.append(
                    f"watcher pid {watcher['pid']} is live on {watcher['watched']}; reap it when that turn ends"
                )
        if watchers is None:
            steps.append("process table unreadable: enumerate armed watchers through the runtime facility instead")
        if session_present and all(t["done"] for t in turns) and not any(w["state"] == "live" for w in watchers or []):
            steps.append("then session_kill the handle to reap; the transcript and the handle go with it")
        if not session_present:
            steps.append(
                "session directory is gone: session_status, then session_list, to confirm the handle was reaped"
            )
        return {
            "sessionDir": self.session_dir,
            "sessionPresent": session_present,
            "handle": self.args.handle,
            "turns": turns,
            "watchers": watchers if watchers is not None else [],
            "processTableReadable": watchers is not None,
            "steps": steps,
        }

    @staticmethod
    def render(report: dict[str, Any], stream) -> None:
        gone = "" if report["sessionPresent"] else " (gone)"
        stream.write(f"session dir: {report['sessionDir']}{gone}\n")
        if report["handle"]:
            stream.write(f"handle:      {report['handle']}\n")
        stream.write("turns:\n" if report["turns"] else "turns:       none on disk\n")
        for turn in report["turns"]:
            state = "done" if turn["done"] else "RUNNING"
            subtype = f" subtype={turn['subtype']}" if turn["subtype"] else ""
            stream.write(
                f"  turn {turn['turn']}  {state}  exitCode={turn['exitCode']}  "
                f"result={'yes' if turn['hasResult'] else 'no'}{subtype}\n"
            )
        if not report["processTableReadable"]:
            stream.write("watchers:    process table unreadable\n")
        elif report["watchers"]:
            stream.write("watchers:\n")
            for w in report["watchers"]:
                stream.write(f"  pid {w['pid']}  {w['state']}  {w['watched']}  -> {w['note']}\n")
        else:
            stream.write("watchers:    none found polling this session\n")
        stream.write("checklist:\n")
        for i, step in enumerate(report["steps"], start=1):
            stream.write(f"  {i}. {step}\n")
        stream.write(
            "reminder: pids are OS pids; stop a watcher through the runtime facility under its announced handle.\n"
        )

    def run(self) -> int:
        report = self.build()
        if self.args.json:
            json.dump(report, sys.stdout, indent=2, sort_keys=True)
            sys.stdout.write("\n")
        else:
            self.render(report, sys.stdout)
        return 0


# --- cli ------------------------------------------------------------------------------------------

EPILOG = """\
exit codes:
  wait      0 turn done | 10 session dir gone | 11 transcript flat | 1 ceiling | 2 bad input
  resolve   0 spawn call on stdout | 3 no launchable match | 2 refused argument
  verdict   0 collect | 4 running | 5 wedged | 6 inspect | 7 steer | 2 bad input
  result    0 complete | 4 partial, no terminal event | 3 nothing to recover | 2 bad input
  inspect   0 inspected | 3 no readable turn | 2 bad input
  teardown  0 checklist produced | 2 bad input

`wait` is the watcher payload: launch it through the runtime's background
facility so its exit is the wake. On 1 or 10, call session_status before
concluding anything - most ceiling hits are a stale done path, not a failed
agent.

Reads only. Never spawns, kills, calls MCP, or globs; the verdict ledger is
the one file it writes, and only when asked to.
"""


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="hyprpilot-harness.py",
        description=__doc__,
        epilog=EPILOG,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("-v", "--verbose", action="store_true", help="Debug logging on stderr.")
    verbs = parser.add_subparsers(dest="verb", required=True, metavar="VERB")

    p = verbs.add_parser(
        "wait",
        help="Wait for one turn's done.json; the watcher payload.",
        description="Wait for exactly one hyprpilot turn to end. Takes the turn path verbatim from the "
        "spawn or session_send response - never a computed turn number. Bounded polling, one "
        "literal path, no globbing. Meant to be armed through the runtime's background "
        "facility so its exit wakes the session once.",
    )
    p.add_argument(
        "--turn-dir", metavar="PATH", help="sessionInfo.files.turnDir, verbatim; done.json is appended to it."
    )
    p.add_argument(
        "--done-file",
        metavar="PATH",
        help="sessionInfo.files.done, verbatim; must end in /done.json. "
        "Exactly one of --turn-dir and --done-file is required.",
    )
    p.add_argument(
        "--session-dir",
        metavar="PATH",
        help="sessionInfo.files.dir; defaults to three levels above the marker, "
        "which is the SESSION/turns/N/done.json layout.",
    )
    p.add_argument(
        "--interval", type=non_negative_number, default=30.0, metavar="SEC", help="Seconds between polls (default 30)."
    )
    p.add_argument(
        "--max-polls",
        type=positive_int,
        default=120,
        metavar="N",
        help="Poll ceiling (default 120, so 60 minutes at the default interval).",
    )
    p.add_argument("--label", metavar="NAME", help="Name printed in the RESULT line (default: the done path).")
    p.add_argument(
        "--stall-after",
        type=positive_int,
        metavar="SECONDS",
        help="Also exit 11 when turns.jsonl has not grown for this many seconds while the turn "
        "is not done. 600-900 for a delegate turn; a wedged turn never wakes you without it.",
    )
    p.add_argument("--quiet", action="store_true", help="Print only the RESULT lines.")

    p = verbs.add_parser(
        "resolve",
        help="Resolve a profile from a list_profiles listing and validate the spawn arguments.",
        description="Resolve a profile from a saved list_profiles listing and validate the spawn call "
        "before anything is launched. Prints the spawn call as JSON on stdout.",
    )
    p.add_argument(
        "--profiles",
        required=True,
        metavar="FILE",
        help="The list_profiles JSON saved to a file; - reads stdin. Never pin an id.",
    )
    p.add_argument(
        "--want", required=True, metavar="FRAGMENT", help="An exact profile id, or words that must all appear in it."
    )
    p.add_argument("--prompt", metavar="TEXT", help="The brief; mutually exclusive with --prompt-file.")
    p.add_argument("--prompt-file", metavar="PATH", help="Absolute path whose contents become the prompt.")
    p.add_argument("--cwd", metavar="PATH", help="Absolute working directory.")
    p.add_argument(
        "--mode",
        metavar="MODE",
        help="claude auto|default|acceptEdits|dontAsk; opencode build|plan; codex carries none.",
    )
    p.add_argument(
        "--arg",
        action="append",
        default=[],
        metavar="TOKEN",
        help="Raw vendor argv token, repeatable, forwarded verbatim.",
    )
    p.add_argument("--with-config", metavar="JSON", help="Array of overlay objects; keys model, effort, mode only.")
    p.add_argument("--read-only", action="store_true", help="Assert the per-vendor read-only shape.")
    p.add_argument("--wait", action="store_true", help="Note that the caller intends a blocking turn.")
    p.add_argument("--json", action="store_true", help="Print only the spawn call; no summary on stderr.")

    p = verbs.add_parser(
        "verdict",
        help="Turn a session_status reading into a verdict and the next action.",
        description="Turn one session_status reading into a verdict and the next action, keeping a "
        "ledger across readings so a wedged agent is visible. Pass the fields as flags, "
        "or the whole session_status object with --json.",
    )
    p.add_argument("--status", choices=("running", "exited"))
    p.add_argument("--exit-code", metavar="N", help="Integer; omitted while running.")
    p.add_argument("--has-result", metavar="BOOL", help="true or false.")
    p.add_argument("--transcript-bytes", metavar="N")
    p.add_argument("--turn", metavar="N")
    p.add_argument("--json", metavar="FILE", help="The session_status object; - reads stdin.")
    p.add_argument(
        "--ledger",
        metavar="PATH",
        help="Append this reading to a JSONL file and judge progress against the earlier ones.",
    )
    p.add_argument(
        "--flat-after",
        type=float,
        default=300.0,
        metavar="SECONDS",
        help="A running turn flat for this long is wedged (default 300).",
    )
    p.add_argument(
        "--turn-dir",
        metavar="PATH",
        help="sessionInfo.files.turnDir; an exited turn's transcript is read to tell max-turns apart.",
    )
    p.add_argument("--output", choices=("text", "json"), default="text")

    p = verbs.add_parser(
        "result",
        help="Extract the final agent text from one turn transcript.",
        description="Extract the final agent result from one turn transcript, or say why there is none. "
        "Takes sessionInfo.files.transcript, or the turn directory holding it.",
    )
    p.add_argument("transcript", help="turns.jsonl, or the turn directory.")
    p.add_argument("--provider", choices=("auto",) + ht.PROVIDERS, default="auto", help="Override shape detection.")
    p.add_argument("--json", action="store_true", help="Emit a JSON report instead of plain text.")
    p.add_argument("--max-chars", type=positive_int, default=0, metavar="N", help="Truncate the printed result.")
    p.add_argument("--quiet", action="store_true", help="Print the result only, no diagnostics.")

    p = verbs.add_parser(
        "inspect",
        help="Report every turn of a session directory, read-only.",
        description="Inspect a session directory read-only: which turn is current, whether it finished, "
        "what the terminal event said, whether a result is recoverable. stderr.log content, "
        "environment values and raw payloads are never printed.",
    )
    p.add_argument("session_dir", help="sessionInfo.files.dir, or any turn directory under it.")
    p.add_argument("--turn", type=positive_int, metavar="N", help="Report only turn N.")
    p.add_argument("--json", action="store_true", help="Emit a JSON report instead of the text table.")
    p.add_argument(
        "--max-errors",
        type=non_negative_int,
        default=5,
        metavar="N",
        help="Cap the error strings printed per turn (default 5).",
    )

    p = verbs.add_parser(
        "teardown",
        help="List uncollected turns and watcher processes before a reap.",
        description="List what a session leaves behind before it is reaped: turns whose answer is not "
        "collected, and watcher processes still polling its files, read from /proc. Kills nothing.",
    )
    p.add_argument("session_dir", help="sessionInfo.files.dir, or any turn directory under it.")
    p.add_argument("--handle", metavar="HANDLE", help="The session handle, echoed into the checklist.")
    p.add_argument("--json", action="store_true", help="Machine-readable report.")
    p.add_argument("--proc", default="/proc", help=argparse.SUPPRESS)
    return parser


def cmd_main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    create_logger(args.verbose, name="harness")
    try:
        if args.verb == "wait":
            return TurnWaiter(args).run()
        if args.verb == "resolve":
            return SpawnResolver.from_listing(args.profiles).run(args)
        if args.verb == "verdict":
            return SessionVerdict(args).run()
        if args.verb == "result":
            return TurnResult(args).run()
        if args.verb == "inspect":
            return SessionInspector(args).run()
        if args.verb == "teardown":
            return TeardownChecklist(args).run()
        raise ScriptError(f"unknown verb: {args.verb}")
    except ht.TranscriptError as err:
        sys.stderr.write(f"error: {err}\n")
        return 2
    except ScriptError as err:
        sys.stderr.write(f"error: {err}\n" if err.exit_code == 2 else f"{err}\n")
        return err.exit_code


if __name__ == "__main__":
    sys.exit(cmd_main())
