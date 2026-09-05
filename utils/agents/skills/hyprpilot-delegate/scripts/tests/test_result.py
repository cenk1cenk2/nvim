"""`result`: recover what the agent said from a transcript on disk, per vendor.

The exit code carries the finding, not just success: 0 complete, 4 partial with
no terminal event, 3 nothing recoverable, 2 bad input.
"""

from __future__ import annotations

from pathlib import Path

import pytest

FIXTURES = Path(__file__).resolve().parent / "fixtures"


def fixture(name: str) -> str:
    return str(FIXTURES / f"{name}.jsonl")


@pytest.mark.parametrize(
    ("args", "code", "expect"),
    [
        # claude
        pytest.param(
            (fixture("claude-success"), "--quiet"), 0, "MR !315 created.", id="claude success prints the result"
        ),
        pytest.param((fixture("claude-success"),), 0, "provider=claude", id="claude success reports the provider"),
        pytest.param(
            (fixture("claude-max-turns"), "--quiet"), 0, "Committed 3 files", id="claude max-turns falls back"
        ),
        pytest.param(
            (fixture("claude-max-turns"),), 0, "steer the SAME session", id="claude max-turns explains the steer"
        ),
        pytest.param((fixture("claude-running"), "--quiet"), 4, "Reading the chart.", id="running turn is a partial"),
        pytest.param(
            (fixture("claude-running"), "--quiet"), 4, "PARTIAL result", id="running turn warns even when quiet"
        ),
        pytest.param(
            (fixture("claude-running"),), 4, "no terminal `result` event", id="running turn names the missing event"
        ),
        pytest.param(
            (fixture("claude-runtime-error"),), 3, "Credit balance is too low", id="claude runtime error is surfaced"
        ),
        pytest.param((fixture("claude-truncated"), "--quiet"), 0, "Done anyway.", id="claude truncated line tolerated"),
        # codex
        pytest.param(
            (fixture("codex-success"), "--quiet"),
            0,
            "Bump landed on the ruler chart.",
            id="codex agent_message extracted",
        ),
        pytest.param((fixture("codex-no-message"),), 3, "agent_message", id="codex without agent_message explains"),
        # opencode
        pytest.param(
            (fixture("opencode-success"), "--quiet"), 0, "No drift found.", id="opencode last text part extracted"
        ),
        pytest.param(
            (fixture("opencode-success"),), 0, "emits no terminal event", id="opencode warns it is not terminal"
        ),
        # shapes that carry no answer
        pytest.param((fixture("empty"),), 3, "launch-failure shape", id="empty transcript explains launch failure"),
        pytest.param((fixture("unknown-shape"),), 3, "no event matched", id="unknown shape is named as such"),
        # projections
        pytest.param(
            (fixture("claude-success"), "--json"), 0, '"provider": "claude"', id="json report carries the provider"
        ),
        pytest.param(
            (fixture("claude-success"), "--provider", "codex"),
            3,
            "agent_message",
            id="forced provider overrides detection",
        ),
        pytest.param(
            (fixture("claude-success"), "--max-chars", "4", "--quiet"),
            0,
            "[truncated at 4 characters]",
            id="max-chars truncates",
        ),
    ],
)
def test_result(run, args, code, expect):
    result = run("result", *args)
    assert result.code == code
    assert expect in result


def test_verbose_traces_the_forced_provider(run):
    result = run("-v", "result", fixture("claude-success"), "--provider", "codex")
    assert result.code == 3
    assert "forcing provider codex" in result


@pytest.mark.parametrize(
    ("args", "expect"),
    [
        pytest.param(("{tmp}/nope.jsonl",), "does not exist", id="missing file"),
        pytest.param(("{tmp}/turns/*/turns.jsonl",), "glob character", id="glob path"),
        pytest.param((), "Missing argument", id="no argument"),
        pytest.param((fixture("claude-success"), "--bogus"), "No such option", id="unknown option"),
        pytest.param((fixture("claude-success"), "--provider", "gpt"), "not one of", id="bad provider value"),
        pytest.param((fixture("claude-success"), "--max-chars", "0"), "positive integer", id="zero max-chars"),
    ],
)
def test_result_refusals(run, tmp_path, args, expect):
    result = run("result", *(a.format(tmp=tmp_path) for a in args))
    assert result.code == 2
    assert expect in result
