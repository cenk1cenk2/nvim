"""`wait`: the watcher payload. One literal turn path, bounded polling, no globbing.

Its exit code is the wake, so each ending is asserted separately: 0 done,
10 the session vanished, 11 the transcript stopped growing, 1 the ceiling,
2 an argument that would have armed a watcher on nothing.
"""

from __future__ import annotations

import threading
import time

import pytest

FAST = ("--interval", "0.05", "--max-polls", "3")


def test_done_marker_present_exits_zero(run, session_dir):
    result = run("wait", "--turn-dir", str(session_dir / "turns/1"), *FAST)
    assert result.code == 0
    assert "done after 1 poll" in result


@pytest.mark.parametrize(
    ("args", "expect"),
    [
        pytest.param(("--turn-dir", "{s}/turns/1"), "turns/1/done.json", id="turn-dir appends done.json"),
        pytest.param(("--turn-dir", "{s}/turns/1/"), "done after 1 poll", id="turn-dir tolerates a trailing slash"),
        pytest.param(("--done-file", "{s}/turns/1/done.json"), "done after 1 poll", id="done-file form still works"),
        pytest.param(
            ("--turn-dir", "{s}/turns/1", "--label", "K-899"), "RESULT: K-899 done", id="label appears in RESULT"
        ),
        pytest.param(("--turn-dir", "{s}/turns/1"), "session dir: {s}", id="session dir is derived and printed"),
        pytest.param(
            ("--turn-dir", "{s}/turns/1", "--session-dir", "{s}"),
            "session dir: {s}",
            id="explicit session-dir is honoured",
        ),
    ],
)
def test_wait_accepts(run, session_dir, args, expect):
    result = run("wait", *(a.format(s=session_dir) for a in args), *FAST)
    assert result.code == 0
    assert expect.format(s=session_dir) in result


def test_quiet_drops_the_header(run, session_dir):
    result = run("wait", "--turn-dir", str(session_dir / "turns/1"), "--quiet", *FAST)
    assert result.code == 0
    assert "done file:" not in result


@pytest.mark.parametrize(
    "expect",
    ["not done after 3 poll", "session_status first", "never compute the turn"],
)
def test_pending_turn_hits_the_ceiling(run, session_dir, expect):
    result = run("wait", "--turn-dir", str(session_dir / "turns/2"), *FAST)
    assert result.code == 1
    assert expect in result


# A ceiling exit here would take minutes at 5s x 100, so reaching exit 10 at all
# proves the vanished-session check short-circuits rather than polling.
@pytest.mark.parametrize(
    ("turn", "expect"),
    [
        pytest.param("1", "session directory", id="names the missing directory"),
        pytest.param("1", "before the first poll", id="skips polling entirely"),
        pytest.param("4", "session_list", id="advises session_list"),
    ],
)
def test_vanished_session_exits_ten(run, tmp_path, turn, expect):
    result = run("wait", "--turn-dir", str(tmp_path / f"gone/turns/{turn}"), "--interval", "5", "--max-polls", "100")
    assert result.code == 10
    assert expect in result


def test_session_lost_mid_poll_exits_ten(run, tmp_path):
    """The same ending reached from inside the loop rather than before it."""
    live = tmp_path / "vanishing"
    (live / "turns/1").mkdir(parents=True)
    threading.Timer(0.15, lambda: __import__("shutil").rmtree(live, ignore_errors=True)).start()

    result = run("wait", "--turn-dir", str(live / "turns/1"), "--interval", "0.05", "--max-polls", "40")
    assert result.code == 10
    assert "session directory gone" in result


# The harness creates a turn directory before the response carrying it returns,
# so an absent turn under a LIVE session means the index was computed, not read.
@pytest.mark.parametrize(
    "expect",
    ["derived turn index", "sessionInfo.files.turnDir"],
)
def test_derived_turn_index_is_refused(run, session_dir, expect):
    result = run("wait", "--turn-dir", str(session_dir / "turns/9"), *FAST)
    assert result.code == 2
    assert expect in result


def test_a_refused_arm_polls_nothing(run, session_dir):
    result = run("wait", "--turn-dir", str(session_dir / "turns/9"), *FAST)
    assert "watching" not in result


class TestStallDetection:
    """`--stall-after` is what wakes you on a wedge; without it a stuck turn never does."""

    SLOW = ("--interval", "0.3", "--max-polls", "10", "--stall-after", "1")

    @pytest.mark.parametrize(
        "expect",
        ["transcript flat at 18 bytes", "wedged agent", "stall:       1s"],
    )
    def test_flat_transcript_exits_eleven(self, run, session_dir, expect):
        (session_dir / "turns/2/turns.jsonl").write_text('{"type":"system"}\n')
        result = run("wait", "--turn-dir", str(session_dir / "turns/2"), *self.SLOW)
        assert result.code == 11
        assert expect in result

    def test_growing_transcript_is_not_a_stall(self, run, session_dir, harness):
        target = session_dir / "turns/3/turns.jsonl"

        def grow() -> None:
            for _ in range(6):
                with target.open("a") as fh:
                    fh.write('{"type":"assistant"}\n')
                time.sleep(0.25)

        writer = threading.Thread(target=grow, daemon=True)
        writer.start()
        result = run(
            "wait",
            "--turn-dir",
            str(session_dir / "turns/3"),
            "--interval",
            "0.3",
            "--max-polls",
            "5",
            "--stall-after",
            "1",
        )
        writer.join(timeout=5)
        assert result.code == 1
        assert "not done after 5 poll" in result

    def test_absent_transcript_is_not_a_stall(self, run, session_dir):
        result = run(
            "wait",
            "--turn-dir",
            str(session_dir / "turns/3"),
            "--interval",
            "0.3",
            "--max-polls",
            "4",
            "--stall-after",
            "1",
        )
        assert result.code == 1
        assert "not done after 4 poll" in result

    def test_done_wins_over_a_flat_transcript(self, run, session_dir):
        result = run("wait", "--turn-dir", str(session_dir / "turns/1"), "--stall-after", "1", *FAST)
        assert result.code == 0
        assert "done after 1 poll" in result


@pytest.mark.parametrize(
    ("args", "expect"),
    [
        pytest.param(("--interval", "5"), "--turn-dir is required", id="missing path"),
        pytest.param(
            ("--turn-dir", "{s}/turns/1", "--done-file", "{s}/turns/1/done.json"), "exactly one", id="both path args"
        ),
        pytest.param(("--done-file", "{s}/turns/1/turns.jsonl"), "must end in /done.json", id="non done.json path"),
        pytest.param(("--turn-dir", "{s}/turns/*"), "glob character", id="glob in turn-dir"),
        pytest.param(("--turn-dir", "turns/1"), "absolute path", id="relative turn-dir"),
        pytest.param(("--done-file", "{s}/turns/*/done.json"), "glob character", id="glob in done-file"),
        pytest.param(("--turn-dir", "{s}/turns/1", "--session-dir", "rel"), "absolute path", id="relative session-dir"),
        pytest.param(
            ("--turn-dir", "{s}/turns/1", "--stall-after", "1.5"), "not a valid integer", id="non-integer stall"
        ),
        pytest.param(("--turn-dir", "{s}/turns/1", "--stall-after", "0"), "positive integer", id="zero stall"),
        pytest.param(("--turn-dir", "{s}/turns/1", "--max-polls", "0"), "positive integer", id="zero max-polls"),
        pytest.param(("--turn-dir", "{s}/turns/1", "--interval", "-5"), "must not be negative", id="negative interval"),
        pytest.param(
            ("--turn-dir", "{s}/turns/1", "--interval", "soon"), "not a valid float", id="non-numeric interval"
        ),
        pytest.param(("--turn-dir", "{s}/turns/1", "--forever"), "No such option", id="unknown option"),
    ],
)
def test_wait_refusals(run, session_dir, args, expect):
    result = run("wait", *(a.format(s=session_dir) for a in args))
    assert result.code == 2
    assert expect in result


def test_verb_help_names_the_field_to_pass(run):
    result = run("wait", "--help")
    assert result.code == 0
    assert "sessionInfo.files.turnDir" in result
