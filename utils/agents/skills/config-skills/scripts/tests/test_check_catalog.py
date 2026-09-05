"""The catalog linter: each check fires on the shape it names, and not otherwise.

Every case builds a throwaway catalog under tmp_path. Nothing reads the real
one, so a convention changing upstream cannot turn these red.
"""

from __future__ import annotations

import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parent.parent / "check_catalog.py"

GOOD_DESCRIPTION = (
    'good-skill Does one thing well. Use on "a phrase", "another". Not for the situation it must not take.'
)


@dataclass(frozen=True)
class Run:
    code: int
    out: str

    def __contains__(self, needle: str) -> bool:
        return needle in self.out


class Catalog:
    """A throwaway skill catalog, built one skill at a time."""

    def __init__(self, root: Path):
        self.root = root

    def add(self, slug: str, *, description: str | None = None, body: str = "Body.\n", extra: str = "") -> Path:
        directory = self.root / slug
        directory.mkdir(parents=True, exist_ok=True)
        described = GOOD_DESCRIPTION.replace("good-skill", slug) if description is None else description
        (directory / "SKILL.md").write_text(f"---\nname: {slug}\ndescription: {described}\n{extra}---\n\n{body}")
        return directory


@pytest.fixture
def catalog(tmp_path: Path) -> Catalog:
    return Catalog(tmp_path)


@pytest.fixture
def lint():
    def _lint(root: Path | Catalog, *args: str) -> Run:
        target = root.root if isinstance(root, Catalog) else root
        proc = subprocess.run(
            [sys.executable, str(SCRIPT), str(target), *args],
            capture_output=True,
            text=True,
            timeout=60,
        )
        return Run(proc.returncode, proc.stdout + proc.stderr)

    return _lint


def test_a_clean_catalog_passes(catalog, lint):
    catalog.add("good-skill")
    result = lint(catalog)
    assert result.code == 0
    assert "0 failure(s)" in result


class TestFrontmatter:
    def test_a_missing_block_is_a_failure(self, catalog, lint, tmp_path):
        (tmp_path / "broken").mkdir()
        (tmp_path / "broken" / "SKILL.md").write_text("no frontmatter here\n")
        result = lint(catalog)
        assert result.code == 1
        assert "does not open with ---" in result

    def test_an_unclosed_block_is_a_failure(self, catalog, lint, tmp_path):
        (tmp_path / "broken").mkdir()
        (tmp_path / "broken" / "SKILL.md").write_text("---\nname: broken\n")
        result = lint(catalog)
        assert result.code == 1
        assert "never closes" in result

    def test_name_must_match_the_directory(self, catalog, lint, tmp_path):
        directory = catalog.add("mismatched")
        text = (directory / "SKILL.md").read_text().replace("name: mismatched", "name: something-else")
        (directory / "SKILL.md").write_text(text)
        result = lint(catalog)
        assert result.code == 1
        assert "does not match the directory" in result


class TestDescription:
    def test_a_block_scalar_is_refused(self, catalog, lint):
        catalog.add("blocky", description="|")
        result = lint(catalog)
        assert result.code == 1
        assert "block scalar" in result

    def test_it_must_start_with_the_slug(self, catalog, lint):
        catalog.add("leader", description='Does a thing. Use on "x". Not for anything else.')
        result = lint(catalog)
        assert result.code == 1
        assert "does not start with the slug" in result

    def test_a_missing_trigger_is_a_failure(self, catalog, lint):
        catalog.add("triggerless", description="triggerless Does a thing and says nothing about when.")
        result = lint(catalog)
        assert result.code == 1
        assert "no trigger phrase" in result

    @pytest.mark.parametrize(
        "phrasing",
        [
            'Use on "a thing".',
            "Use when the branch is dirty.",
            "Use first after a compaction.",
            "Load before that server's first call.",
            "Load the entry for the thing you are watching.",
            "read when a skill declares a prerequisite.",
            "Auto-invoked on an issue id.",
        ],
    )
    def test_every_trigger_phrasing_the_catalog_uses_is_accepted(self, catalog, lint, phrasing):
        """The checklist writes `Use on`; the catalog also uses these, and they are the same slot."""
        catalog.add("varied", description=f"varied Does a thing. {phrasing} Not for other situations.")
        result = lint(catalog)
        assert result.code == 0, result.out

    def test_angle_brackets_are_refused(self, catalog, lint):
        catalog.add("bracketed", description='bracketed Does <a thing>. Use on "x". Not for other things.')
        result = lint(catalog)
        assert result.code == 1
        assert "contains < or >" in result

    def test_an_overlong_description_warns_before_it_fails(self, catalog, lint):
        catalog.add("wordy", description="wordy " + ("padding " * 50) + 'Use on "x". Not for anything.')
        result = lint(catalog)
        assert result.code == 0, "roughly 380 is a warning, not a hard failure"
        assert "desc-length" in result

    def test_a_truly_enormous_description_fails(self, catalog, lint):
        catalog.add("enormous", description="enormous " + ("padding " * 90) + 'Use on "x". Not for anything.')
        result = lint(catalog)
        assert result.code == 1
        assert "desc-length" in result

    def test_naming_a_sibling_in_not_for_warns(self, catalog, lint):
        catalog.add("sibling-a")
        catalog.add("sibling-b", description='sibling-b Does a thing. Use on "x". Not for sibling-a work.')
        result = lint(catalog)
        assert "desc-sibling" in result


class TestPointers:
    def test_a_declared_reference_that_is_missing_fails(self, catalog, lint):
        catalog.add("dangling", extra="references:\n  - ./references/absent.md\n")
        result = lint(catalog)
        assert result.code == 1
        assert "declared but missing" in result

    def test_a_declared_script_that_is_missing_fails(self, catalog, lint):
        catalog.add("scriptless", extra="scripts:\n  - ./scripts/absent.py\n")
        result = lint(catalog)
        assert result.code == 1
        assert "declared but missing" in result

    def test_a_declared_reference_that_exists_passes(self, catalog, lint):
        directory = catalog.add("solid", extra="references:\n  - ./references/present.md\n")
        (directory / "references").mkdir()
        (directory / "references" / "present.md").write_text("# Present\n")
        result = lint(catalog)
        assert result.code == 0, result.out

    def test_a_load_line_naming_no_skill_fails(self, catalog, lint):
        catalog.add("loader", body="Load `no-such-skill` for the rest.\n")
        result = lint(catalog)
        assert result.code == 1
        assert "names no skill" in result

    def test_a_load_line_naming_a_real_skill_passes(self, catalog, lint):
        catalog.add("target")
        catalog.add("loader", body="Load `target` for the rest.\n")
        result = lint(catalog)
        assert result.code == 0, result.out


class TestBodyRules:
    def test_a_called_wire_name_fails(self, catalog, lint):
        """An instruction to CALL the wire form is the mistake the rule exists for."""
        catalog.add("caller", body="Call mcp__slack_kilic__slack_post_message(channel_id='C1').\n")
        result = lint(catalog)
        assert result.code == 1
        assert "mcp-prefix" in result

    def test_a_wire_name_merely_named_only_warns(self, catalog, lint):
        """`mcp__claude_ai_Slack__*` IS the connector's identity; naming it is legitimate."""
        catalog.add("namer", body="The claude.ai connector `mcp__claude_ai_Slack__*` reaches the other workspace.\n")
        result = lint(catalog)
        assert result.code == 0, result.out
        assert "mcp-prefix" in result

    def test_an_emoji_anywhere_fails(self, catalog, lint):
        catalog.add("cheery", body="All good ✅ here.\n")
        result = lint(catalog)
        assert result.code == 1
        assert "emoji" in result

    def test_an_h1_in_the_body_warns(self, catalog, lint):
        catalog.add("headed", body="# A Title\n\nBody.\n")
        result = lint(catalog)
        assert result.code == 0
        assert "h1" in result

    def test_disable_model_invocation_false_warns(self, catalog, lint):
        catalog.add("tiered", extra="disableModelInvocation: false\n")
        result = lint(catalog)
        assert result.code == 0
        assert "tier" in result


class TestOrphans:
    def test_a_shared_reference_nothing_declares_warns(self, catalog, lint, tmp_path):
        catalog.add("lonely")
        shared = tmp_path / "references"
        shared.mkdir()
        (shared / "unused.md").write_text("# Unused\n")
        result = lint(catalog)
        assert "orphan-ref" in result


class TestInvocation:
    def test_warnings_can_be_silenced(self, catalog, lint):
        catalog.add("headed", body="# A Title\n\nBody.\n")
        result = lint(catalog, "--no-warnings")
        assert result.code == 0
        assert "h1" not in result

    def test_a_missing_root_is_a_usage_error(self, lint, tmp_path):
        result = lint(tmp_path / "nowhere")
        assert result.code == 2
        assert "not a directory" in result

    def test_a_root_with_no_skills_is_a_usage_error(self, lint, tmp_path):
        empty = tmp_path / "empty"
        empty.mkdir()
        result = lint(empty)
        assert result.code == 2
        assert "no */SKILL.md" in result
