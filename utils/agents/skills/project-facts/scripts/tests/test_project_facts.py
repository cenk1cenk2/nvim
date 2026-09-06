"""Repository fact detection: the runner, what CI enforces, and how it releases.

Every case builds a throwaway repository under tmp_path. Nothing reads a real
one, so a project changing its tooling cannot turn these red.
"""

from __future__ import annotations

import json
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parent.parent / "project_facts.py"


@dataclass(frozen=True)
class Run:
    code: int
    out: str

    def __contains__(self, needle: str) -> bool:
        return needle in self.out

    @property
    def facts(self) -> dict:
        return json.loads(self.out)


@pytest.fixture
def facts():
    def _facts(root: Path, *args: str) -> Run:
        proc = subprocess.run(
            [sys.executable, str(SCRIPT), str(root), *args],
            capture_output=True,
            text=True,
            timeout=60,
        )
        return Run(proc.returncode, proc.stdout + proc.stderr)

    return _facts


class TestRunner:
    def test_a_taskfile_yields_its_task_names(self, facts, tmp_path):
        (tmp_path / "Taskfile.yml").write_text(
            "version: '3'\ntasks:\n  lint:\n    cmds: [echo]\n  test:\n    cmds: [echo]\n"
        )
        result = facts(tmp_path, "--json")
        assert result.facts["runner"] == "task"
        assert result.facts["commands"] == ["lint", "test"]

    def test_package_json_yields_its_scripts(self, facts, tmp_path):
        (tmp_path / "package.json").write_text(json.dumps({"scripts": {"build": "x", "lint": "y"}}))
        result = facts(tmp_path, "--json")
        assert result.facts["runner"] == "npm"
        assert result.facts["commands"] == ["build", "lint"]

    def test_a_makefile_yields_its_targets(self, facts, tmp_path):
        (tmp_path / "Makefile").write_text("lint:\n\techo a\n\ntest: lint\n\techo b\n")
        result = facts(tmp_path, "--json")
        assert result.facts["runner"] == "make"
        assert set(result.facts["commands"]) == {"lint", "test"}

    def test_taskfile_wins_over_a_makefile(self, facts, tmp_path):
        """Discovery order is the one `project-tooling` states; first match wins."""
        (tmp_path / "Taskfile.yml").write_text("version: '3'\ntasks:\n  lint:\n    cmds: [echo]\n")
        (tmp_path / "Makefile").write_text("build:\n\techo a\n")
        result = facts(tmp_path, "--json")
        assert result.facts["runner"] == "task"

    def test_no_runner_says_so_rather_than_guessing(self, facts, tmp_path):
        """Inventing a command is the failure this exists to prevent."""
        result = facts(tmp_path, "--json")
        assert result.facts["runner"] is None
        assert any("do not invent commands" in note for note in result.facts["notes"])

    def test_an_unparseable_manifest_yields_no_commands_rather_than_crashing(self, facts, tmp_path):
        (tmp_path / "package.json").write_text("{not json")
        result = facts(tmp_path, "--json")
        assert result.code == 0
        assert result.facts["runner"] == "npm"
        assert result.facts["commands"] == []


class TestCi:
    def test_it_finds_the_gate_commands_a_gitlab_pipeline_runs(self, facts, tmp_path):
        (tmp_path / ".gitlab-ci.yml").write_text(
            "lint:\n  script:\n    - pnpm run lint\ndeploy:\n  script:\n    - ./deploy.sh\n"
        )
        result = facts(tmp_path, "--json")
        assert ".gitlab-ci.yml" in result.facts["ci_files"]
        assert "pnpm run lint" in result.facts["ci_commands"]

    def test_a_deploy_step_is_not_a_gate(self, facts, tmp_path):
        """Only gate-shaped commands count; a deploy is not a check."""
        (tmp_path / ".gitlab-ci.yml").write_text("deploy:\n  script:\n    - ./deploy.sh\n")
        result = facts(tmp_path, "--json")
        assert result.facts["ci_commands"] == []

    def test_it_reads_github_workflow_run_steps(self, facts, tmp_path):
        workflows = tmp_path / ".github" / "workflows"
        workflows.mkdir(parents=True)
        (workflows / "ci.yml").write_text("jobs:\n  build:\n    steps:\n      - run: go test ./...\n")
        result = facts(tmp_path, "--json")
        assert "go test ./..." in result.facts["ci_commands"]

    def test_no_ci_is_called_out(self, facts, tmp_path):
        """Discovery says which commands exist; only CI says which ones gate a merge."""
        (tmp_path / "Taskfile.yml").write_text("version: '3'\ntasks:\n  lint:\n    cmds: [echo]\n")
        result = facts(tmp_path, "--json")
        assert any("nothing establishes which commands gate" in n for n in result.facts["notes"])

    def test_a_command_is_not_repeated_across_jobs(self, facts, tmp_path):
        (tmp_path / ".gitlab-ci.yml").write_text("a:\n  script:\n    - task lint\nb:\n  script:\n    - task lint\n")
        result = facts(tmp_path, "--json")
        assert result.facts["ci_commands"].count("task lint") == 1


class TestRelease:
    @pytest.mark.parametrize(
        ("marker", "expected"),
        [
            pytest.param("release-please-config.json", "release-please", id="release-please"),
            pytest.param(".releaserc", "semantic-release", id="semantic-release"),
            pytest.param("commitlint.config.js", "commitlint", id="commitlint"),
        ],
    )
    def test_a_marker_file_identifies_the_automation(self, facts, tmp_path, marker, expected):
        (tmp_path / marker).write_text("{}")
        result = facts(tmp_path, "--json")
        assert result.facts["release"] == expected

    def test_changesets_is_found_by_its_config(self, facts, tmp_path):
        changeset = tmp_path / ".changeset"
        changeset.mkdir()
        (changeset / "config.json").write_text("{}")
        result = facts(tmp_path, "--json")
        assert result.facts["release"] == "changesets"
        assert any(".changeset/*.md" in note for note in result.facts["notes"])

    def test_semantic_release_configured_inside_package_json(self, facts, tmp_path):
        """It is as often a key in package.json as a file of its own."""
        (tmp_path / "package.json").write_text(json.dumps({"release": {"branches": ["main"]}}))
        result = facts(tmp_path, "--json")
        assert result.facts["release"] == "semantic-release"

    def test_commit_driven_automation_warns_that_the_type_sets_the_bump(self, facts, tmp_path):
        (tmp_path / ".releaserc").write_text("{}")
        result = facts(tmp_path, "--json")
        assert any("commit type sets the version bump" in note for note in result.facts["notes"])

    def test_no_automation_is_none(self, facts, tmp_path):
        result = facts(tmp_path, "--json")
        assert result.facts["release"] == "none"


class TestInvocation:
    def test_text_output_names_each_field(self, facts, tmp_path):
        (tmp_path / "Taskfile.yml").write_text("version: '3'\ntasks:\n  lint:\n    cmds: [echo]\n")
        result = facts(tmp_path)
        assert result.code == 0
        for field in ("root:", "runner:", "ci:", "release:"):
            assert field in result

    def test_a_missing_directory_is_a_usage_error(self, facts, tmp_path):
        result = facts(tmp_path / "nowhere")
        assert result.code == 2
        assert "not a directory" in result
