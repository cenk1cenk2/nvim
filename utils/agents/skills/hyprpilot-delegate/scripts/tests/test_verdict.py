"""`verdict`: turn one session_status reading into the next action.

The exit code IS the action - 0 collect, 4 poll again, 5 wedged, 6 inspect,
7 steer - so a caller branches on it without parsing the text.
"""

from __future__ import annotations

import json
import time
from pathlib import Path

import pytest

FIXTURES = Path(__file__).resolve().parent / "fixtures"


@pytest.mark.parametrize(
    ("args", "code", "expect"),
    [
        pytest.param(
            ("--status", "exited", "--exit-code", "0", "--has-result", "true", "--transcript-bytes", "100"),
            0,
            "verdict: collect",
            id="clean exit is collect",
        ),
        pytest.param(
            ("--status", "exited", "--exit-code", "0", "--has-result", "false", "--transcript-bytes", "100"),
            0,
            "no-answer shape",
            id="clean exit without a result notes it",
        ),
        pytest.param(
            ("--status", "running", "--transcript-bytes", "100", "--turn", "1"),
            4,
            "verdict: running",
            id="running is poll again",
        ),
        pytest.param(
            ("--status", "exited", "--exit-code", "1", "--has-result", "false", "--transcript-bytes", "100"),
            6,
            "verdict: inspect",
            id="non-zero exit is inspect",
        ),
    ],
)
def test_verdict_from_flags(run, args, code, expect):
    result = run("verdict", *args)
    assert result.code == code
    assert expect in result


class TestTranscriptAwareVerdicts:
    """With `--turn-dir` it reads the transcript, which is what separates max-turns from a failure."""

    @pytest.mark.parametrize("expect", ["verdict: steer", "Do not re-spawn"])
    def test_max_turns_is_steer(self, run, inspect_dir, expect):
        result = run(
            "verdict",
            "--status",
            "exited",
            "--exit-code",
            "1",
            "--has-result",
            "false",
            "--turn-dir",
            str(inspect_dir / "turns/2"),
        )
        assert result.code == 7
        assert expect in result

    def test_runtime_error_is_named(self, run, tmp_path):
        turn = tmp_path / "rt"
        turn.mkdir()
        (turn / "turns.jsonl").write_text((FIXTURES / "claude-runtime-error.jsonl").read_text())
        result = run(
            "verdict", "--status", "exited", "--exit-code", "1", "--has-result", "false", "--turn-dir", str(turn)
        )
        assert result.code == 6
        assert "Credit balance" in result


class TestLedger:
    """One reading cannot show a flat transcript; the ledger across readings can."""

    def test_wedge_is_only_visible_across_readings(self, run, tmp_path):
        ledger = str(tmp_path / "ledger.jsonl")
        common = ("verdict", "--status", "running", "--turn", "1", "--ledger", ledger, "--flat-after", "1")

        first = run(*common, "--transcript-bytes", "500")
        assert first.code == 4
        assert "1 reading(s)" in first

        moving = run(*common, "--transcript-bytes", "600")
        assert moving.code == 4
        assert "flat for 0s" in moving

        time.sleep(1.1)
        flat = run(*common, "--transcript-bytes", "600")
        assert flat.code == 5
        assert "verdict: wedged" in flat

        # A new turn is a fresh process, so its byte count starts over.
        next_turn = run(
            "verdict",
            "--status",
            "running",
            "--turn",
            "2",
            "--ledger",
            ledger,
            "--flat-after",
            "1",
            "--transcript-bytes",
            "600",
        )
        assert next_turn.code == 4
        assert "verdict: running" in next_turn

    def test_verbose_reports_the_ledger_depth(self, run, tmp_path):
        ledger = str(tmp_path / "ledger.jsonl")
        run("verdict", "--status", "running", "--turn", "1", "--ledger", ledger, "--transcript-bytes", "1")
        result = run(
            "-v",
            "verdict",
            "--status",
            "running",
            "--turn",
            "2",
            "--ledger",
            ledger,
            "--flat-after",
            "1",
            "--transcript-bytes",
            "600",
        )
        assert result.code == 4
        assert "earlier reading(s)" in result


class TestJsonInput:
    def test_status_object_is_accepted_on_stdin(self, run):
        status = json.dumps({"status": "exited", "exitCode": 0, "hasResult": True, "transcriptBytes": 10, "turn": 1})
        result = run("verdict", "--json", "-", "--output", "json", stdin=status)
        assert result.code == 0
        assert '"verdict": "collect"' in result

    def test_json_and_flags_together_are_refused(self, run):
        result = run("verdict", "--json", "-", "--status", "running", stdin="{}")
        assert result.code == 2
        assert "not both" in result


@pytest.mark.parametrize(
    ("args", "expect"),
    [
        pytest.param(("--status", "done"), "invalid choice", id="bad status"),
        pytest.param(
            ("--status", "exited", "--has-result", "true"), "pass --exit-code", id="exited without an exit code"
        ),
        pytest.param(
            ("--status", "exited", "--exit-code", "0", "--has-result", "maybe"), "true or false", id="bad has-result"
        ),
        pytest.param(("--status", "running", "--ledger", "ledger.jsonl"), "absolute path", id="relative ledger"),
        pytest.param(("--status", "running", "--flat-after", "soon"), "invalid float", id="bad flat-after"),
        pytest.param(("--status", "running", "--bogus"), "unrecognized", id="unknown option"),
    ],
)
def test_verdict_refusals(run, args, expect):
    result = run("verdict", *args)
    assert result.code == 2
    assert expect in result
