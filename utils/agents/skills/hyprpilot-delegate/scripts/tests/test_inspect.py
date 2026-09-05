"""`inspect`: read a session off disk without a single MCP call.

It withholds by design - stderr content and every session.json key outside
`handle` and `startedAt` are reported by size or name only.
"""

from __future__ import annotations

import pytest


@pytest.mark.parametrize(
    ("args", "expect"),
    [
        pytest.param((), "handle:      abc-123", id="session handle is reported"),
        pytest.param((), "turns found: 1, 2, 3, 4", id="every turn is listed"),
        pytest.param((), "values withheld): ownerPid, pgid, pid", id="pid values are withheld"),
        pytest.param(("--turn", "1"), "finished with a recoverable result", id="turn 1 verdict is recoverable"),
        pytest.param(("--turn", "1"), "content not printed", id="stderr content is never printed"),
        pytest.param(("--turn", "2"), "max_turns (num_turns=31)", id="turn 2 verdict names max_turns"),
        pytest.param(("--turn", "2"), "Do not re-spawn", id="max_turns verdict says do not re-spawn"),
        pytest.param(("--turn", "2"), "exitCode=1", id="done.json exit code is reported"),
        pytest.param(("--turn", "3"), "still running, or was killed", id="pending turn is not called failed"),
        pytest.param(("--turn", "3"), "stderr.log: absent", id="absent stderr.log reads cleanly"),
        pytest.param(("--turn", "4"), "launch failure shape", id="empty transcript reads as launch failure"),
        pytest.param(("--turn", "4"), "29 bytes (content not printed)", id="stderr message stays unprinted"),
        pytest.param(("--json",), '"verdict"', id="json report carries the verdict"),
    ],
)
def test_inspect(run, inspect_dir, args, expect):
    result = run("inspect", str(inspect_dir), *args)
    assert result.code == 0
    assert expect in result


def test_a_turn_dir_resolves_to_its_session_root(run, inspect_dir):
    result = run("inspect", str(inspect_dir / "turns/1"))
    assert result.code == 0
    assert "turns found: 1, 2, 3, 4" in result


@pytest.mark.parametrize(
    ("path", "args", "expect"),
    [
        pytest.param("{d}", ("--turn", "9"), "turn 9 not present", id="absent turn"),
        pytest.param("{tmp}", (), "no turns/ directory", id="non-session dir"),
        pytest.param("{tmp}/nowhere", (), "does not exist", id="missing dir"),
        pytest.param("{tmp}/hyprpilot-session-*", (), "glob character", id="glob path"),
        pytest.param("session-x", (), "absolute path", id="relative path"),
    ],
)
def test_inspect_refusals(run, inspect_dir, tmp_path, path, args, expect):
    result = run("inspect", path.format(d=inspect_dir, tmp=tmp_path), *args)
    assert result.code == 2
    assert expect in result
