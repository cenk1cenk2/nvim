"""The mcp-stream condition against a loopback server that pages a cursor-ordered event list.

The fake `events` tool returns up to `limit` events with a cursor above
`after_cursor`, oldest first, and the test moves the stream between polls
through `script`: one callable per poll, run before that poll's first call.
"""

from __future__ import annotations

import http.server
import json
import socketserver
import threading
from collections.abc import Iterator

import pytest

FAST = ("--interval", "0", "--max-polls", "3")


class _Handler(http.server.BaseHTTPRequestHandler):
    events: list = []
    script: list = []
    polls = 0
    calls: list = []

    def do_POST(self):  # noqa: N802 - the stdlib name
        body = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        if "id" not in body:
            self._reply(202, b"")
            return
        if body["method"] == "initialize":
            result = {"protocolVersion": "2025-06-18", "capabilities": {}, "serverInfo": {"name": "fake"}}
        else:
            cls = type(self)
            arguments = body["params"]["arguments"]
            cls.calls.append(arguments)
            after = arguments.get("after_cursor", 0)
            page = [event for event in cls.events if not isinstance(event["cursor"], int) or event["cursor"] > after][
                : arguments.get("limit", 2)
            ]
            payload = {"events": page, "next_cursor": page[-1]["cursor"] if page else after}
            result = {"content": [{"type": "text", "text": json.dumps({"result": json.dumps(payload)})}]}
        self._reply(200, json.dumps({"jsonrpc": "2.0", "id": body["id"], "result": result}).encode())

    def _reply(self, status: int, data: bytes) -> None:
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, *args):
        """Silence the default stderr access log."""


@pytest.fixture
def stream() -> Iterator[type[_Handler]]:
    _Handler.events = []
    _Handler.calls = []
    with socketserver.ThreadingTCPServer(("127.0.0.1", 0), _Handler) as srv:
        thread = threading.Thread(target=srv.serve_forever, daemon=True)
        thread.start()
        _Handler.url = f"http://127.0.0.1:{srv.server_address[1]}/mcp"
        try:
            yield _Handler
        finally:
            srv.shutdown()
            thread.join(timeout=5)


def event(cursor: int, role: str, content: str = "") -> dict:
    return {"cursor": cursor, "role": role, "content": content}


def watch_args(server, *extra: str) -> tuple[str, ...]:
    return ("mcp-stream", "--url", server.url, "--tool", "events", "--items", "result.events", *extra)


class _Feeder(threading.Thread):
    """Append to the stream once the watcher has taken its baseline."""

    def __init__(self, server, after_calls: int, change):
        super().__init__(daemon=True)
        self.server = server
        self.after_calls = after_calls
        self.change = change

    def run(self):
        while len(self.server.calls) < self.after_calls:
            threading.Event().wait(0.01)
        self.change(self.server.events)


def test_the_baseline_drains_every_page_and_never_fires(run, stream):
    stream.events = [event(cursor, "assistant") for cursor in range(1, 8)]
    result = run(*FAST, *watch_args(stream, "--match", "role=assistant"))
    assert result.code == 1
    assert "head at cursor 7" in result


def test_a_matching_event_past_the_head_fires_with_its_text(run, stream):
    stream.events = [event(1, "assistant"), event(2, "user")]
    _Feeder(stream, 3, lambda events: events.extend([event(3, "user"), event(5, "assistant", "MR open\nmore")])).start()
    result = run(
        "--interval", "0.2", "--max-polls", "20", *watch_args(stream, "--match", "role=assistant", "--show", "content")
    )
    assert result.code == 0
    assert "RESULT: new item at cursor 5 in mcp events: MR open" in result
    assert "more" not in result


def test_an_event_that_does_not_match_is_skipped(run, stream):
    stream.events = [event(1, "assistant")]
    _Feeder(stream, 2, lambda events: events.append(event(2, "user"))).start()
    result = run("--interval", "0.2", "--max-polls", "5", *watch_args(stream, "--match", "role=assistant"))
    assert result.code == 1
    assert "cursor 2, none new" in result


def test_a_restarted_stream_fires_as_lost(run, stream):
    stream.events = [event(40, "assistant"), event(41, "assistant")]
    _Feeder(stream, 3, lambda events: events.__setitem__(slice(None), [event(1, "assistant")])).start()
    result = run("--interval", "0.2", "--max-polls", "20", *watch_args(stream, "--match", "role=assistant"))
    assert result.code == 0
    assert "lost its place at cursor 41" in result


def test_an_empty_stream_takes_the_first_event(run, stream):
    _Feeder(stream, 1, lambda events: events.append(event(1, "assistant", "first"))).start()
    result = run("--interval", "0.2", "--max-polls", "20", *watch_args(stream, "--show", "content"))
    assert result.code == 0
    assert "cursor 1 in mcp events: first" in result


def test_a_quiet_poll_is_one_call(run, stream):
    stream.events = [event(1, "assistant")]
    run("--interval", "0", "--max-polls", "4", *watch_args(stream))
    pages_for_baseline = 2
    assert len(stream.calls) == pages_for_baseline + 3


def test_events_without_an_integer_cursor_cannot_run(run, stream):
    stream.events = [{"cursor": "abc", "role": "assistant"}]
    result = run(*FAST, *watch_args(stream))
    assert result.code == 3
    assert "no integer cursor" in result


def test_a_non_integer_cursor_argument_is_a_usage_error(run, stream):
    result = run(*FAST, *watch_args(stream, "--arguments", '{"after_cursor": "x"}'))
    assert result.code == 2
