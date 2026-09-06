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

    def test_a_slightly_overlong_description_warns(self, catalog, lint):
        """ "Roughly 380" allows a tolerance band; 390-ish sits inside it."""
        catalog.add("wordy", description="wordy " + ("padding " * 46) + 'Use on "x". Not for anything.')
        result = lint(catalog)
        assert result.code == 0, "just over 380 is a warning, not a hard failure"
        assert "desc-length" in result

    def test_a_description_past_the_tolerance_band_fails(self, catalog, lint):
        """Past ~420 truncation starts eating the trailing triggers."""
        catalog.add("enormous", description="enormous " + ("padding " * 70) + 'Use on "x". Not for anything.')
        result = lint(catalog)
        assert result.code == 1
        assert "desc-length" in result

    def test_a_missing_not_for_fails(self, catalog, lint):
        """Checklist 4 is part of "one shape, every skill" and is purely mechanical."""
        catalog.add("openended", description='openended Does a thing. Use on "x".')
        result = lint(catalog)
        assert result.code == 1
        assert "desc-notfor" in result

    @pytest.mark.parametrize(
        "prose",
        [
            "Load-balancer tuning for the ingress tier.",
            "Read to understand the rota.",
            "Handles read-only access to buckets.",
            "Covers the use of tokens for API access.",
        ],
    )
    def test_prose_that_merely_contains_the_trigger_words_is_not_a_trigger(self, catalog, lint, prose):
        """A loose regex accepted all four of these, which is how the rule got hollowed out."""
        catalog.add("loose", description=f"loose {prose} Not for other situations.")
        result = lint(catalog)
        assert result.code == 1
        assert "desc-trigger" in result

    def test_naming_a_sibling_in_not_for_warns(self, catalog, lint):
        catalog.add("sibling-a")
        catalog.add("sibling-b", description='sibling-b Does a thing. Use on "x". Not for sibling-a work.')
        result = lint(catalog)
        assert "desc-sibling" in result


class TestParser:
    def test_an_unreadable_frontmatter_line_is_reported_not_skipped(self, catalog, lint, tmp_path):
        """A dropped `references:` item means the existence check quietly stops checking."""
        directory = catalog.add("odd")
        text = (directory / "SKILL.md").read_text().replace("---\n\n", "references:\n[a, b]\n---\n\n")
        (directory / "SKILL.md").write_text(text)
        result = lint(catalog)
        assert result.code == 1
        assert "unparseable frontmatter line" in result


class TestParserIndents:
    """A list item the collector drops means its existence check stops running."""

    @pytest.mark.parametrize(
        "indent",
        [pytest.param("", id="column zero"), pytest.param("    ", id="four spaces"), pytest.param("\t", id="tab")],
    )
    def test_a_declared_reference_is_checked_at_any_indent(self, catalog, lint, indent):
        catalog.add("odd", extra=f"references:\n{indent}- ./references/absent.md\n")
        result = lint(catalog)
        assert result.code == 1
        assert "declared but missing" in result

    def test_a_flow_sequence_is_reported_rather_than_silently_dropped(self, catalog, lint):
        catalog.add("flowing", extra="references: [./references/absent.md]\n")
        result = lint(catalog)
        assert result.code == 1
        assert "flow sequence" in result


class TestInvocationErrors:
    def test_an_unknown_option_is_exit_two_not_a_traceback(self, lint, catalog):
        catalog.add("good-skill")
        result = lint(catalog, "--bogus")
        assert result.code == 2
        assert "Traceback" not in result


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

    @pytest.mark.parametrize(
        "phrasing",
        ["load `no-such-skill` first", "Load the `no-such-skill` skill", "Load `no-such-skill`"],
    )
    def test_every_load_phrasing_the_catalog_uses_is_resolved(self, catalog, lint, phrasing):
        """The catalog writes loads three ways; all three must resolve."""
        catalog.add("loader", body=f"{phrasing}.\n")
        result = lint(catalog)
        assert result.code == 1
        assert "names no skill" in result

    def test_a_parent_relative_reference_that_exists_is_not_an_orphan(self, catalog, lint, tmp_path):
        """The orphan check compares resolved paths; `../references/` must match."""
        shared = tmp_path / "references"
        shared.mkdir()
        (shared / "shared.md").write_text("# Shared\n")
        catalog.add("consumer", extra="references:\n  - ../references/shared.md\n")
        result = lint(catalog)
        assert result.code == 0, result.out
        assert "orphan-ref" not in result


class TestBodyRules:
    @pytest.mark.parametrize(
        "line",
        [
            "Call mcp__slack_kilic__slack_post_message(channel_id='C1').",
            "Use `mcp__hyprpilot-skills__read_skill { slug }` to fetch it.",
            "Use `mcp__claude_ai_Slack__slack_send_message` to post.",
        ],
    )
    def test_a_wire_name_used_as_an_instruction_fails(self, catalog, lint, line):
        """The catalog calls tools in `{ slug }` form, so keying on `(` detected nothing."""
        catalog.add("caller", body=f"{line}\n")
        result = lint(catalog)
        assert result.code == 1
        assert "mcp-prefix" in result

    def test_a_family_glob_naming_a_connector_passes(self, catalog, lint):
        """`mcp__claude_ai_Slack__*` IS the connector's identity, not a call."""
        catalog.add("namer", body="The claude.ai connector `mcp__claude_ai_Slack__*` reaches the other workspace.\n")
        result = lint(catalog)
        assert result.code == 0, result.out

    def test_a_family_glob_with_a_placeholder_passes(self, catalog, lint):
        """`mcp__claude_ai_<Connector>__*` is how config-skills itself names a family."""
        catalog.add("placeheld", body="A first-party connector is `mcp__claude_ai_<Connector>__*`.\n")
        result = lint(catalog)
        assert result.code == 0, result.out

    def test_a_toolsearch_select_string_passes(self, catalog, lint):
        """A `select:` argument is literal data the caller must type verbatim."""
        catalog.add("selector", body="Load with `select:mcp__claude-in-chrome__navigate`.\n")
        result = lint(catalog)
        assert result.code == 0, result.out

    def test_a_fenced_call_instruction_still_fails(self, catalog, lint):
        """A fence does not make a call instruction stop being one."""
        catalog.add("fenced", body="```\nmcp__slack_kilic__slack_post_message(channel_id='C1')\n```\n")
        result = lint(catalog)
        assert result.code == 1

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

    def test_disable_model_invocation_false_is_allowed(self, catalog, lint):
        """config-skills permits it explicitly for an auto-invoke skill."""
        catalog.add("tiered", extra="disableModelInvocation: false\n")
        result = lint(catalog)
        assert result.code == 0, result.out

    def test_a_foreign_frontmatter_key_fails(self, catalog, lint):
        """Claude Code keys this catalog does not use; a stray one is invisible."""
        catalog.add("strayed", extra="when_to_use: whenever\n")
        result = lint(catalog)
        assert result.code == 1
        assert "frontmatter-key" in result

    def test_a_star_is_an_emoji_too(self, catalog, lint):
        """U+2B50 sits outside the emoji planes; the absolute rule names star explicitly."""
        catalog.add("starry", body="Rated it a star.\n".replace("a star", "\u2b50"))
        result = lint(catalog)
        assert result.code == 1
        assert "emoji" in result

    def test_an_h1_inside_a_fence_is_not_a_heading(self, catalog, lint):
        """A `#` in a code block is a shell comment; counting those is noise."""
        catalog.add("shellish", body="```sh\n# set the thing\ntrue\n```\n")
        result = lint(catalog)
        assert result.code == 0
        assert "h1" not in result


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
