"""`http`: a health probe against a real loopback server.

A refused connection is NOT met and NOT an error - a service is legitimately
down until the deploy converges, which is exactly what the watcher waits out.
"""

from __future__ import annotations

FAST = ("--interval", "0", "--max-polls", "3")


def test_a_200_is_met(run, http_base):
    result = run(*FAST, "http", f"{http_base}/ok")
    assert result.code == 0
    assert "met after 1 poll" in result


def test_the_body_can_be_required_to_contain_text(run, http_base):
    result = run(*FAST, "http", f"{http_base}/ok", "--contains", "healthy: yes")
    assert result.code == 0
    assert "met after 1 poll" in result


def test_a_body_without_the_text_is_not_met(run, http_base):
    result = run(*FAST, "http", f"{http_base}/ok", "--contains", "absent")
    assert result.code == 1
    assert "body without" in result


def test_an_unexpected_status_is_not_met(run, http_base):
    result = run(*FAST, "http", f"{http_base}/missing")
    assert result.code == 1
    assert "status 404" in result


def test_the_expected_status_can_be_something_other_than_200(run, http_base):
    result = run(*FAST, "http", f"{http_base}/missing", "--status", "404")
    assert result.code == 0
    assert "met after 1 poll" in result


def test_a_refused_connection_is_not_met_rather_than_an_error(run):
    """Port 1 refuses. The watcher keeps waiting instead of dying."""
    result = run(*FAST, "http", "http://127.0.0.1:1/x")
    assert result.code == 1
    assert "connection error" in result
