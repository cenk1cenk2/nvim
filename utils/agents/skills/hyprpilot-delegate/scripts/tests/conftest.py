"""Shared fixtures for the hyprpilot-harness suite.

Every test writes only inside pytest's own tmp_path. Nothing here touches a real
session, a config file, or the network; the teardown cases start stand-in
processes that only sleep, and stop them before the test returns.
"""

from __future__ import annotations

import contextlib
import json
import os
import signal
import subprocess
import sys
from collections.abc import Callable, Iterator
from dataclasses import dataclass
from pathlib import Path

import pytest

SCRIPTS = Path(__file__).resolve().parent.parent
HARNESS = SCRIPTS / "hyprpilot-harness.py"
FIXTURES = Path(__file__).resolve().parent / "fixtures"

# `resolve` warns on a thin prompt, which would mask the assertion in every case
# that is not about that warning.
LONG_PROMPT = (
    "Refactor the retry logic in /srv/app/src/api/client.ts to keep the existing backoff curve "
    "and only change the retry ceiling. Run the test suite with task test before reporting. "
    "Report the diff."
)


@dataclass(frozen=True)
class Run:
    """One invocation: the exit code, and stdout and stderr merged as the CLI presents them."""

    code: int
    out: str

    def __contains__(self, needle: str) -> bool:
        return needle in self.out


@pytest.fixture(scope="session")
def harness() -> Path:
    assert HARNESS.is_file(), f"entry point missing: {HARNESS}"
    return HARNESS


@pytest.fixture
def run(harness: Path) -> Callable[..., Run]:
    """Invoke the real entry point. Exit codes are the contract, so nothing is imported here."""

    def _run(*args: str, stdin: str | None = None) -> Run:
        proc = subprocess.run(
            [sys.executable, str(harness), *args],
            capture_output=True,
            text=True,
            input=stdin,
            timeout=60,
        )
        return Run(proc.returncode, proc.stdout + proc.stderr)

    return _run


@pytest.fixture
def session_dir(tmp_path: Path) -> Path:
    """A session with turn 1 done, turns 2 and 3 pending - the `wait` layout."""
    root = tmp_path / "hyprpilot-session-TEST"
    for turn in (1, 2, 3):
        (root / "turns" / str(turn)).mkdir(parents=True)
    (root / "turns" / "1" / "done.json").write_text("")
    return root


@pytest.fixture
def inspect_dir(tmp_path: Path) -> Path:
    """A session covering every turn shape inspect and teardown have to name.

    turn 1 finished with a result, turn 2 hit max_turns, turn 3 is still running,
    turn 4 is a launch failure whose transcript never opened.
    """
    root = tmp_path / "hyprpilot-session-INSPECT"
    (root / "turns").mkdir(parents=True)
    (root / "session.json").write_text(
        json.dumps({"handle": "abc-123", "startedAt": 1785584000, "pid": 4242, "pgid": 4242, "ownerPid": 1})
    )

    def turn(n: int, transcript: str | None, stderr: str | None, done: dict | None) -> None:
        d = root / "turns" / str(n)
        d.mkdir(parents=True)
        if transcript is not None:
            (d / "turns.jsonl").write_text(transcript)
        if stderr is not None:
            (d / "stderr.log").write_text(stderr)
        if done is not None:
            (d / "done.json").write_text(json.dumps(done) + "\n")

    turn(
        1,
        (FIXTURES / "claude-success.jsonl").read_text(),
        "",
        {"exitCode": 0, "finishedAt": 1785584247, "handle": "abc-123"},
    )
    turn(
        2,
        (FIXTURES / "claude-max-turns.jsonl").read_text(),
        "",
        {"exitCode": 1, "finishedAt": 1785585000, "handle": "abc-123"},
    )
    turn(3, (FIXTURES / "claude-running.jsonl").read_text(), None, None)
    turn(4, "", "error: unknown option --nope\n", {"exitCode": 1, "finishedAt": 1785586000, "handle": "abc-123"})
    return root


@pytest.fixture
def profiles_file(tmp_path: Path) -> Path:
    """A `list_profiles` result covering every vendor, plus a row that failed to resolve."""
    rows = {
        "profiles": [
            {
                "id": "personal/claude/opus",
                "agent": "claude-code",
                "provider": "claude-code",
                "model": "opus",
                "mode": "auto",
                "harnessEnabled": True,
                "headless": False,
                "isDefault": True,
            },
            {
                "id": "personal/claude/sonnet",
                "agent": "claude-code",
                "provider": "claude-code",
                "model": "sonnet",
                "mode": "auto",
                "harnessEnabled": True,
                "headless": False,
                "isDefault": False,
            },
            {
                "id": "personal/kilic/glm-5.3:cloud",
                "agent": "opencode",
                "provider": "opencode",
                "model": "glm",
                "mode": "build",
                "harnessEnabled": True,
                "headless": False,
                "isDefault": False,
            },
            {
                "id": "personal/kilic/cheap",
                "agent": "opencode",
                "provider": "opencode",
                "model": "cheap",
                "mode": "plan",
                "harnessEnabled": True,
                "headless": True,
                "isDefault": False,
            },
            {
                "id": "personal/codex/gpt",
                "agent": "codex",
                "provider": "codex",
                "model": "gpt",
                "harnessEnabled": True,
                "headless": False,
                "isDefault": False,
            },
            {
                "id": "personal/broken/one",
                "agent": "claude-code",
                "provider": "claude-code",
                "harnessEnabled": True,
                "headless": False,
                "isDefault": False,
                "error": "profile failed to resolve: missing command",
            },
        ]
    }
    path = tmp_path / "profiles.json"
    path.write_text(json.dumps(rows))
    return path


@pytest.fixture
def sleeper(tmp_path: Path) -> Iterator[Callable[..., subprocess.Popen]]:
    """Start stand-in watcher processes carrying the real argv shape.

    A real `wait` exits at once on a finished or vanished turn, so the stale and
    orphan cases cannot use one - they need a process that keeps the argv but
    stays alive. Everything started here is killed when the test returns.
    """
    fake = tmp_path / "fake" / "hyprpilot-harness.py"
    fake.parent.mkdir(parents=True)
    fake.write_text("#!/bin/sh\nsleep 100\n")
    fake.chmod(0o755)

    started: list[subprocess.Popen] = []

    def _start(*args: str) -> subprocess.Popen:
        proc = subprocess.Popen(
            [str(fake), *args],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
        started.append(proc)
        return proc

    yield _start

    for proc in started:
        _stop(proc)


def _stop(proc: subprocess.Popen) -> None:
    if proc.poll() is not None:
        return
    try:
        os.killpg(proc.pid, signal.SIGKILL)
    except (ProcessLookupError, PermissionError):
        proc.kill()
    with contextlib.suppress(subprocess.TimeoutExpired):
        proc.wait(timeout=5)


@pytest.fixture
def stop() -> Callable[[subprocess.Popen], None]:
    """Stop one stand-in early, for the cases that assert it disappears from the report."""
    return _stop
