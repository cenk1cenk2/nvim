"""Shared fixtures for the watch.py suite.

Every test writes only inside pytest's own tmp_path. The http cases bind a
loopback server on an ephemeral port and shut it down when the test returns;
nothing here reaches the network or touches a real watcher.
"""

from __future__ import annotations

import http.server
import json
import socketserver
import subprocess
import sys
import threading
from collections.abc import Callable, Iterator
from dataclasses import dataclass
from pathlib import Path

import pytest

SCRIPTS = Path(__file__).resolve().parent.parent
WATCH = SCRIPTS / "watch.py"

# Poll as fast as the loop allows: these cases assert on the ending, not on timing.
FAST = ("--interval", "0", "--max-polls", "3")


@dataclass(frozen=True)
class Run:
    """One invocation: the exit code, and stdout and stderr merged as the CLI presents them."""

    code: int
    out: str

    def __contains__(self, needle: str) -> bool:
        return needle in self.out


@pytest.fixture(scope="session")
def watch() -> Path:
    assert WATCH.is_file(), f"entry point missing: {WATCH}"
    return WATCH


@pytest.fixture
def run(watch: Path) -> Callable[..., Run]:
    """Invoke the real entry point. Exit codes are the contract, so nothing is imported here."""

    def _run(*args: str) -> Run:
        proc = subprocess.run(
            [sys.executable, str(watch), *args],
            capture_output=True,
            text=True,
            timeout=60,
        )
        return Run(proc.returncode, proc.stdout + proc.stderr)

    return _run


@pytest.fixture
def present(tmp_path: Path) -> Path:
    path = tmp_path / "present"
    path.write_text("")
    return path


@pytest.fixture
def missing(tmp_path: Path) -> Path:
    """A path that is never created - the ceiling cases poll this."""
    return tmp_path / "missing"


@pytest.fixture
def cat(tmp_path: Path) -> Path:
    """A command whose stdout is the file it is handed, so a test can move the value under the watcher."""
    script = tmp_path / "state.sh"
    script.write_text('#!/bin/sh\ncat "$1"\n')
    script.chmod(0o755)
    return script


@pytest.fixture
def merged(tmp_path: Path) -> Path:
    path = tmp_path / "merged"
    path.write_text("MERGED\n")
    return path


@pytest.fixture
def mr_json(tmp_path: Path) -> Path:
    path = tmp_path / "mr.json"
    path.write_text(
        json.dumps(
            {
                "state": "opened",
                "pipeline": {"status": "running"},
                # Two jobs, so a wildcard path genuinely matches several nodes.
                "jobs": [{"name": "lint", "status": "success"}, {"name": "test", "status": "running"}],
            }
        )
        + "\n"
    )
    return path


class _Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):  # noqa: N802 - the stdlib name
        if self.path == "/ok":
            body, status = b"healthy: yes", 200
        else:
            body, status = b"nope", 404
        self.send_response(status)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        """Silence the default stderr access log."""


@pytest.fixture(scope="session")
def http_base() -> Iterator[str]:
    """A loopback server on an ephemeral port: `/ok` is 200, anything else 404."""
    with socketserver.TCPServer(("127.0.0.1", 0), _Handler) as srv:
        thread = threading.Thread(target=srv.serve_forever, daemon=True)
        thread.start()
        try:
            yield f"http://127.0.0.1:{srv.server_address[1]}"
        finally:
            srv.shutdown()
            thread.join(timeout=5)
