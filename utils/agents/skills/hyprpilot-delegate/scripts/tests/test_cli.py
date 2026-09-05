"""The top-level CLI surface: verbs are discoverable and a wrong invocation is exit 2."""

from __future__ import annotations

import pytest


@pytest.mark.parametrize(
    ("args", "code", "expect"),
    [
        pytest.param(("--help",), 0, "resolve", id="top-level help lists the verbs"),
        pytest.param(("--help",), 0, "session dir gone", id="epilog documents the wait exits"),
        pytest.param(("verdict", "--help"), 0, "--turn-dir", id="verb help is reachable"),
        pytest.param((), 2, "required", id="no verb is a usage error"),
        pytest.param(("spawn",), 2, "No such command", id="unknown verb is a usage error"),
    ],
)
def test_cli_surface(run, args, code, expect):
    result = run(*args)
    assert result.code == code
    assert expect in result
