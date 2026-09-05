"""`teardown`: what is still uncollected, still running, or still polling this session.

Reaping deletes the directory a watcher tests, so a watcher left behind reports
the cleanup as a finish. Finding those processes is the point of this verb.
"""

from __future__ import annotations

import time
from pathlib import Path

import pytest

FIXTURES = Path(__file__).resolve().parent / "fixtures"


@pytest.fixture
def done_session(tmp_path: Path) -> Path:
    """A session with nothing running and nothing left to collect."""
    root = tmp_path / "hyprpilot-session-DONE"
    turn = root / "turns" / "1"
    turn.mkdir(parents=True)
    (turn / "turns.jsonl").write_text((FIXTURES / "claude-success.jsonl").read_text())
    (turn / "done.json").write_text('{"exitCode":0}\n')
    return root


@pytest.mark.parametrize(
    ("expect",),
    [
        pytest.param("turn 1  done", id="turns are listed"),
        pytest.param("turn 3  RUNNING", id="a running turn is flagged"),
        pytest.param("collect turn 1 before reaping", id="a turn with a result asks for collection"),
        pytest.param("turn 2 ended on error_max_turns", id="a max-turns turn says steer"),
        pytest.param("do not reap", id="a running turn blocks the reap"),
    ],
)
def test_checklist(run, inspect_dir, expect):
    result = run("teardown", str(inspect_dir))
    assert result.code == 0
    assert expect in result


def test_handle_is_echoed(run, inspect_dir):
    result = run("teardown", str(inspect_dir), "--handle", "abc-123")
    assert result.code == 0
    assert "handle:      abc-123" in result


def test_a_turn_dir_resolves_to_its_session(run, inspect_dir):
    result = run("teardown", str(inspect_dir / "turns/1"))
    assert result.code == 0
    assert "turn 1  done" in result


def test_json_report_carries_watchers(run, inspect_dir):
    result = run("teardown", str(inspect_dir), "--json")
    assert result.code == 0
    assert '"watchers"' in result


class TestWatcherDiscovery:
    """Three states, told apart by what the polled path resolves to now."""

    def test_live_and_stale_watchers_are_classified(self, run, inspect_dir, sleeper, stop):
        # turn 3 exists with no done.json, so a watcher on it is legitimately live.
        live = sleeper("wait", "--turn-dir", str(inspect_dir / "turns/3"), "--interval", "5", "--max-polls", "100")
        # turn 1 already finished, so its watcher is stale.
        stale = sleeper("wait", "--turn-dir", str(inspect_dir / "turns/1"), "--interval", "5", "--max-polls", "100")
        time.sleep(0.3)

        result = run("teardown", str(inspect_dir))
        assert result.code == 0
        assert f"pid {live.pid}  live" in result
        assert f"pid {stale.pid}  stale" in result

        stop(stale)
        time.sleep(0.2)
        after = run("teardown", str(inspect_dir))
        assert f"pid {stale.pid}" not in after

    def test_verbose_reports_the_scan(self, run, inspect_dir, sleeper):
        sleeper("wait", "--turn-dir", str(inspect_dir / "turns/3"), "--interval", "5", "--max-polls", "100")
        time.sleep(0.3)
        result = run("-v", "teardown", str(inspect_dir))
        assert result.code == 0
        assert "watcher(s) on this session" in result

    def test_watcher_on_a_vanished_session_is_an_orphan(self, run, tmp_path, sleeper):
        gone = tmp_path / "hyprpilot-session-GONE"
        orphan = sleeper("wait", "--turn-dir", str(gone / "turns/1"), "--interval", "5", "--max-polls", "100")
        time.sleep(0.3)

        result = run("teardown", str(gone))
        assert result.code == 0
        assert f"pid {orphan.pid}  orphan" in result
        assert "session_list" in result

    def test_a_non_wait_verb_is_not_a_watcher(self, run, done_session, sleeper):
        """Only `wait` polls. A sibling verb sharing the script name is not a watch."""
        other = sleeper("inspect", str(done_session))
        time.sleep(0.3)
        result = run("teardown", str(done_session))
        assert f"pid {other.pid}" not in result


class TestQuietSession:
    def test_all_done_and_unwatched_offers_the_reap(self, run, done_session):
        result = run("teardown", str(done_session))
        assert result.code == 0
        assert "then session_kill" in result

    def test_no_watchers_is_stated_rather_than_omitted(self, run, done_session):
        result = run("teardown", str(done_session))
        assert "none found polling" in result

    def test_teardown_does_not_find_itself(self, run, done_session):
        """The waiter and this checklist are one script, so a name match alone would self-report."""
        result = run("teardown", str(done_session))
        assert "hyprpilot-harness.py teardown" not in result

    def test_unreadable_proc_is_reported_not_guessed(self, run, done_session, tmp_path):
        result = run("teardown", str(done_session), "--proc", str(tmp_path / "no-proc"))
        assert result.code == 0
        assert "process table unreadable" in result


@pytest.mark.parametrize(
    ("path", "expect"),
    [
        pytest.param("session-x", "absolute path", id="relative path"),
        pytest.param("{tmp}/hyprpilot-session-*", "glob character", id="glob path"),
        pytest.param("/", "refusing", id="root"),
    ],
)
def test_teardown_refusals(run, tmp_path, path, expect):
    result = run("teardown", path.format(tmp=tmp_path))
    assert result.code == 2
    assert expect in result


def test_no_argument_is_a_usage_error(run):
    result = run("teardown")
    assert result.code == 2
    assert "required" in result
