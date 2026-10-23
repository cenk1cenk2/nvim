"""The MCP conditions against a loopback streamable-HTTP server.

The fake server answers `initialize`, then serves one payload per `tools/call`
from a list the test hands it, repeating the last. Poll 1 is the baseline for
`mcp-new`, poll 2 is what changed, and a ceiling of 2 turns "nothing changed"
into exit 1.
"""

from __future__ import annotations

import http.server
import json
import socketserver
import threading
from collections.abc import Iterator

import pytest

FAST = ("--interval", "0", "--max-polls", "2")


class _Handler(http.server.BaseHTTPRequestHandler):
    payloads: list = []
    calls = 0
    seen_headers: list = []

    def do_POST(self):  # noqa: N802 - the stdlib name
        body = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        type(self).seen_headers.append(dict(self.headers))
        if self.headers.get("x-token") != "secret":
            self._reply(401, {"error": "unauthorized"})
            return
        if "id" not in body:
            self._reply(202, None)
            return
        if body["method"] == "initialize":
            result = {"protocolVersion": "2025-06-18", "capabilities": {}, "serverInfo": {"name": "fake"}}
        elif body["params"]["name"] != "read":
            result = {"isError": True, "content": [{"type": "text", "text": "Unknown tool"}]}
        else:
            cls = type(self)
            payload = cls.payloads[min(cls.calls, len(cls.payloads) - 1)]
            cls.calls += 1
            result = {"content": [{"type": "text", "text": json.dumps({"result": json.dumps(payload)})}]}
        self._sse({"jsonrpc": "2.0", "id": body["id"], "result": result})

    def _reply(self, status: int, body) -> None:
        data = b"" if body is None else json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _sse(self, message: dict) -> None:
        data = f"event: message\ndata: {json.dumps(message)}\n\n".encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, *args):
        """Silence the default stderr access log."""


@pytest.fixture
def mcp_server() -> Iterator[type[_Handler]]:
    _Handler.payloads = []
    _Handler.calls = 0
    _Handler.seen_headers = []
    with socketserver.ThreadingTCPServer(("127.0.0.1", 0), _Handler) as srv:
        thread = threading.Thread(target=srv.serve_forever, daemon=True)
        thread.start()
        _Handler.url = f"http://127.0.0.1:{srv.server_address[1]}/mcp"
        try:
            yield _Handler
        finally:
            srv.shutdown()
            thread.join(timeout=5)


@pytest.fixture
def env(monkeypatch):
    monkeypatch.setenv("WATCH_TEST_TOKEN", "secret")


def server_args(server) -> tuple[str, ...]:
    return ("--url", server.url, "--header", "x-token: ${WATCH_TEST_TOKEN}", "--tool", "read")


def message(ident: int, role: str, content: str) -> dict:
    return {"id": str(ident), "role": role, "content": content}


def test_a_value_inside_a_wrapped_payload_is_met(run, mcp_server, env):
    mcp_server.payloads = [{"total": 68}]
    result = run(*FAST, "mcp", *server_args(mcp_server), "--json-path", "result.total", "--expect", "68")
    assert result.code == 0
    assert "met after 1 poll" in result


def test_a_different_value_reaches_the_ceiling(run, mcp_server, env):
    mcp_server.payloads = [{"total": 68}]
    result = run(*FAST, "mcp", *server_args(mcp_server), "--json-path", "result.total", "--expect", "69")
    assert result.code == 1
    assert "last observed: 68" in result


def test_the_header_secret_comes_from_the_environment(run, mcp_server, env):
    mcp_server.payloads = [{"total": 1}]
    run(*FAST, "mcp", *server_args(mcp_server), "--json-path", "result.total", "--expect", "1")
    assert all(headers.get("x-token") == "secret" for headers in mcp_server.seen_headers)


def test_an_unset_header_variable_cannot_run(run, mcp_server, monkeypatch):
    monkeypatch.delenv("WATCH_TEST_TOKEN", raising=False)
    result = run(*FAST, "mcp", *server_args(mcp_server), "--expect", "x")
    assert result.code == 3
    assert "WATCH_TEST_TOKEN" in result
    assert not mcp_server.seen_headers


def test_refused_credentials_cannot_run(run, mcp_server, monkeypatch):
    monkeypatch.setenv("WATCH_TEST_TOKEN", "wrong")
    result = run(*FAST, "mcp", *server_args(mcp_server), "--expect", "x")
    assert result.code == 3
    assert "refused the credentials" in result


def test_an_unknown_tool_cannot_run(run, mcp_server, env):
    args = ("--url", mcp_server.url, "--header", "x-token: ${WATCH_TEST_TOKEN}", "--tool", "nope")
    result = run(*FAST, "mcp", *args, "--expect", "x")
    assert result.code == 3
    assert "Unknown tool" in result


def test_a_new_matching_item_fires_with_its_text(run, mcp_server, env):
    before = [message(1, "user", "hi"), message(2, "assistant", "on it")]
    after = [*before, message(3, "user", "internal"), message(4, "assistant", "MR is open\nsecond line")]
    mcp_server.payloads = [{"messages": before}, {"messages": after}]
    result = run(
        *FAST,
        "mcp-new",
        *server_args(mcp_server),
        "--items",
        "result.messages",
        "--id",
        "id",
        "--match",
        "role=assistant",
        "--show",
        "content",
    )
    assert result.code == 0
    assert "RESULT: new item 4 in mcp read: MR is open" in result
    assert "second line" not in result


def test_a_new_item_that_does_not_match_is_ignored(run, mcp_server, env):
    before = [message(1, "assistant", "on it")]
    mcp_server.payloads = [{"messages": before}, {"messages": [*before, message(2, "user", "notification")]}]
    result = run(
        *FAST,
        "mcp-new",
        *server_args(mcp_server),
        "--items",
        "result.messages",
        "--id",
        "id",
        "--match",
        "role=assistant",
    )
    assert result.code == 1
    assert "none new" in result


def test_an_existing_item_never_fires(run, mcp_server, env):
    mcp_server.payloads = [{"messages": [message(1, "assistant", "old")]}]
    result = run(*FAST, "mcp-new", *server_args(mcp_server), "--items", "result.messages", "--id", "id")
    assert result.code == 1


def test_an_unresolvable_items_path_cannot_run(run, mcp_server, env):
    mcp_server.payloads = [{"messages": []}]
    result = run(*FAST, "mcp-new", *server_args(mcp_server), "--items", "result.absent", "--id", "id")
    assert result.code == 3
    assert "cannot take the baseline" in result


@pytest.mark.parametrize(
    "args",
    [
        ("mcp", "--tool", "read", "--expect", "x"),
        ("mcp", "--url", "http://127.0.0.1:1/mcp", "--tool", "read"),
        ("mcp", "--url", "http://127.0.0.1:1/mcp", "--tool", "read", "--arguments", "[1]", "--expect", "x"),
        ("mcp", "--server", "a", "--tool", "read", "--expect", "x"),
        ("mcp", "--url", "http://127.0.0.1:1/mcp", "--header", "no-colon", "--tool", "read", "--expect", "x"),
        ("mcp-new", "--url", "http://127.0.0.1:1/mcp", "--tool", "read", "--items", "a", "--id", "id", "--match", "x"),
    ],
)
def test_usage_errors_poll_nothing(run, args):
    result = run(*FAST, *args)
    assert result.code == 2


def test_a_server_is_read_from_a_config(run, mcp_server, env, tmp_path):
    config = tmp_path / "mcp.json"
    config.write_text(
        json.dumps({"mcpServers": {"fake": {"url": mcp_server.url, "headers": {"x-token": "${WATCH_TEST_TOKEN}"}}}})
    )
    mcp_server.payloads = [{"total": 2}]
    result = run(
        *FAST,
        "mcp",
        "--server",
        "fake",
        "--config",
        str(config),
        "--tool",
        "read",
        "--json-path",
        "result.total",
        "--expect",
        "2",
    )
    assert result.code == 0


def test_a_stdio_server_in_a_config_is_refused(run, tmp_path):
    config = tmp_path / "mcp.json"
    config.write_text(json.dumps({"mcpServers": {"local": {"command": "bunx", "args": []}}}))
    result = run(*FAST, "mcp", "--server", "local", "--config", str(config), "--tool", "read", "--expect", "x")
    assert result.code == 2
    assert "stdio" in result
