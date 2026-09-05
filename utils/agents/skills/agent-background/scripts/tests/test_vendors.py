"""The domain conditions: argv assembly, terminal defaults, and the refusals.

These do not call the real vendors. Each case puts a stub named `glab`, `gh` or
`spacectl` on PATH that echoes a canned payload, so what is exercised is the
argv this builds and the JSON path it reads - the two things that decide whether
a watcher fires on the right thing.
"""

from __future__ import annotations

import json
import os
import stat
from pathlib import Path

import pytest

FAST = ("--interval", "0", "--max-polls", "1")


@pytest.fixture
def stub(tmp_path: Path, monkeypatch):
    """Put a fake vendor CLI on PATH that prints `payload` and records its argv."""
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    monkeypatch.setenv("PATH", f"{bin_dir}{os.pathsep}{os.environ['PATH']}")

    def _stub(name: str, payload: object) -> Path:
        argv_log = tmp_path / f"{name}.argv"
        script = bin_dir / name
        script.write_text(f'#!/bin/sh\nprintf "%s\\n" "$*" > {argv_log}\ncat <<\'JSON\'\n{json.dumps(payload)}\nJSON\n')
        script.chmod(script.stat().st_mode | stat.S_IEXEC)
        return argv_log

    return _stub


class TestGitlab:
    def test_an_mr_reaching_merged_is_met(self, run, stub):
        stub("glab", {"state": "merged"})
        result = run(*FAST, "gitlab-mr", "--project", "g/p", "--iid", "42")
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_an_open_mr_is_not_met(self, run, stub):
        stub("glab", {"state": "opened"})
        result = run(*FAST, "gitlab-mr", "--project", "g/p", "--iid", "42")
        assert result.code == 1
        assert "last observed: opened" in result

    def test_the_argv_carries_repo_iid_and_json(self, run, stub):
        argv_log = stub("glab", {"state": "merged"})
        run(*FAST, "gitlab-mr", "--project", "g/p", "--iid", "42")
        argv = argv_log.read_text()
        assert "mr view 42" in argv
        assert "--repo g/p" in argv
        assert "--output json" in argv

    def test_a_failed_pipeline_wakes_as_early_as_a_success(self, run, stub):
        """Terminal defaults cover failure, or the watch silently becomes a timeout."""
        stub("glab", {"status": "failed"})
        result = run(*FAST, "gitlab-ci", "--project", "g/p", "--pipeline", "9")
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_a_running_pipeline_is_not_met(self, run, stub):
        stub("glab", {"status": "running"})
        result = run(*FAST, "gitlab-ci", "--project", "g/p", "--pipeline", "9")
        assert result.code == 1


class TestGithub:
    def test_a_merged_pr_uses_the_upper_case_state(self, run, stub):
        stub("gh", {"state": "MERGED"})
        result = run(*FAST, "github-pr", "--repo", "o/r", "--number", "7")
        assert result.code == 0

    def test_a_completed_action_run_is_met(self, run, stub):
        stub("gh", {"status": "completed", "conclusion": "failure"})
        result = run(*FAST, "github-action", "--repo", "o/r", "--run", "5")
        assert result.code == 0, "completion is the condition; conclusion is read on wake"

    def test_an_in_progress_run_is_not_met(self, run, stub):
        stub("gh", {"status": "in_progress", "conclusion": None})
        result = run(*FAST, "github-action", "--repo", "o/r", "--run", "5")
        assert result.code == 1


class TestSpacelift:
    def test_it_reads_the_most_recent_run_not_the_first_row(self, run, stub):
        """Index 0 would fire on the previous run when the new one is not created yet."""
        stub(
            "spacectl",
            [
                {"id": "old", "state": "FINISHED", "isMostRecent": False},
                {"id": "new", "state": "APPLYING", "isMostRecent": True},
            ],
        )
        result = run(*FAST, "spacelift-run", "--stack", "s")
        assert result.code == 1
        assert "last observed: APPLYING" in result

    def test_the_most_recent_run_reaching_a_terminal_state_is_met(self, run, stub):
        stub(
            "spacectl",
            [
                {"id": "old", "state": "FAILED", "isMostRecent": False},
                {"id": "new", "state": "FINISHED", "isMostRecent": True},
            ],
        )
        result = run(*FAST, "spacelift-run", "--stack", "s")
        assert result.code == 0

    def test_skipped_counts_as_terminal(self, run, stub):
        stub("spacectl", [{"state": "SKIPPED", "isMostRecent": True}])
        result = run(*FAST, "spacelift-run", "--stack", "s")
        assert result.code == 0


class TestWaitResult:
    def test_an_explicit_wait_result_overrides_the_terminal_default(self, run, stub):
        """Waiting for merged ONLY: a closed MR must not satisfy it."""
        stub("glab", {"state": "closed"})
        result = run(*FAST, "gitlab-mr", "--project", "g/p", "--iid", "1", "--wait-result", "merged")
        assert result.code == 1

    def test_wait_result_is_repeatable(self, run, stub):
        stub("glab", {"state": "closed"})
        result = run(
            *FAST,
            "gitlab-mr",
            "--project",
            "g/p",
            "--iid",
            "1",
            "--wait-result",
            "merged",
            "--wait-result",
            "closed",
        )
        assert result.code == 0

    def test_a_condition_with_no_terminal_default_demands_one(self, run):
        """A release either exists or does not; there is no state to default to."""
        result = run(*FAST, "gitlab-tag", "--project", "g/p", "--tag", "v1")
        assert result.code == 2
        assert "no terminal default" in result

    def test_a_tag_condition_is_met_when_the_release_reports_that_tag(self, run, stub):
        stub("glab", {"tag_name": "v1.2.0"})
        result = run(*FAST, "gitlab-tag", "--project", "g/p", "--tag", "v1.2.0", "--wait-result", "v1.2.0")
        assert result.code == 0


class TestRequiredOptions:
    @pytest.mark.parametrize(
        ("condition", "args"),
        [
            pytest.param("gitlab-mr", ("--project", "g/p"), id="gitlab-mr without --iid"),
            pytest.param("github-pr", ("--repo", "o/r"), id="github-pr without --number"),
            pytest.param("spacelift-run", (), id="spacelift-run without --stack"),
        ],
    )
    def test_a_missing_identifier_is_a_usage_error(self, run, condition, args):
        result = run(*FAST, condition, *args)
        assert result.code == 2
        assert "Missing option" in result


def test_a_vendor_cli_that_is_absent_is_exit_three(run, tmp_path, monkeypatch):
    """Exit 3 is 'the check cannot run' - polling would never install glab."""
    monkeypatch.setenv("PATH", str(tmp_path))
    result = run(*FAST, "gitlab-mr", "--project", "g/p", "--iid", "1")
    assert result.code == 3
    assert "command not found" in result
