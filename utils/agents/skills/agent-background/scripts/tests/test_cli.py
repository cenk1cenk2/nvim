"""The CLI surface: refusals, and where a flag belongs relative to the condition.

Flag placement is the subtle half. Common options work on either side of the
condition, but everything after `--` belongs to the watched command - getting
that wrong silently hands the watcher's own flags to the thing being watched.
"""

from __future__ import annotations

import pytest

FAST = ("--interval", "0", "--max-polls", "3")


class TestRefusals:
    """Each of these would otherwise arm a watcher that polls nothing."""

    @pytest.mark.parametrize(
        ("args", "expect"),
        [
            pytest.param((), "a condition is required", id="no argument"),
            pytest.param(("wait-for", "{present}"), "No such command", id="unknown condition"),
            pytest.param(("file-exists", "present"), "absolute path", id="relative path"),
            pytest.param(("file-exists", "{tmp}/*/done.json"), "glob character", id="glob path"),
            pytest.param(
                ("file-exists", "{present}", "file-gone", "{tmp}/x"), "Got unexpected extra", id="two conditions"
            ),
            pytest.param(("file-flat", "{present}"), "--for", id="file-flat without --for"),
            pytest.param(("command", "--", "true"), "at least one --expect", id="command without expect"),
            pytest.param(("command",), "Missing argument", id="command without a command"),
            pytest.param(
                ("file-exists", "{present}", "--interval", "soon"), "not a valid float", id="non-numeric interval"
            ),
            pytest.param(("file-exists", "{present}", "--max-polls", "0"), "greater than 0", id="zero max-polls"),
            pytest.param(("http", "localhost/x"), "valid URL", id="http without a scheme"),
            pytest.param(("file-exists", "{present}", "--forever"), "No such option", id="unknown option"),
            pytest.param(
                ("file-exists", "{present}", "--json-path", "x"), "No such option", id="option from another condition"
            ),
        ],
    )
    def test_refused_with_exit_two(self, run, tmp_path, present, args, expect):
        rendered = [a.format(tmp=tmp_path, present=present) for a in args]
        result = run(*rendered)
        assert result.code == 2
        assert expect in result

    def test_expect_and_expect_file_together(self, run, tmp_path):
        expect_file = tmp_path / "expect.txt"
        expect_file.write_text("x\n")
        result = run("command", "--expect", "x", "--expect-file", str(expect_file), "--", "true")
        assert result.code == 2
        assert "not both" in result

    def test_an_unreadable_expect_file(self, run, tmp_path):
        result = run("command", "--expect-file", str(tmp_path / "nope.txt"), "--", "true")
        assert result.code == 2
        assert "cannot read" in result


class TestFlagPlacement:
    """Common options bind to the watcher wherever they sit; past `--` they do not."""

    def test_shared_flags_after_the_condition(self, run, present):
        result = run("file-exists", str(present), "--interval", "0", "--max-polls", "3")
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_shared_flags_before_the_condition(self, run, present):
        result = run("--interval", "0", "--max-polls", "3", "file-exists", str(present))
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_a_flag_before_the_condition_wins_over_the_subparser_default(self, run, present):
        result = run("--max-polls", "1", "file-exists", str(present), "--interval", "0")
        assert result.code == 0
        assert "ceiling:     1 polls at 0s" in result

    def test_a_label_after_the_condition(self, run, present):
        result = run("file-exists", str(present), "--label", "late", "--max-polls", "1", "--interval", "0")
        assert result.code == 0
        assert "RESULT: late met" in result

    def test_a_ceiling_reached_with_flags_after_the_path(self, run, missing):
        result = run("file-exists", str(missing), "--interval", "0.05", "--max-polls", "2")
        assert result.code == 1
        assert "not met after 2 poll" in result

    def test_flags_before_the_separator_are_the_watchers(self, run, cat, merged):
        result = run(
            "command", "--expect", "MERGED", "--max-polls", "1", "--interval", "0", "--", str(cat), str(merged)
        )
        assert result.code == 0
        assert "ceiling:     1 polls at 0s" in result

    def test_flags_after_the_separator_reach_the_command(self, run):
        """`--interval 0` here is an argument to echo, not to the watcher."""
        result = run(
            "--max-polls",
            "1",
            "--interval",
            "0",
            "command",
            "--expect",
            "a --interval 0",
            "--",
            "echo",
            "a",
            "--interval",
            "0",
        )
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_exit_zero_flags_after_the_separator_reach_the_command(self, run):
        result = run(
            "--max-polls", "1", "--interval", "0", "exit-zero", "--", "sh", "-c", "exit 3", "x", "--interval", "0"
        )
        assert result.code == 1
        assert "last observed: exit 3" in result


class TestArgvBelongsToTheCommand:
    """Everything after the command word is the command's, options included.

    These are regressions: the argparse version used REMAINDER, and the click
    port silently began consuming the watched command's own flags.
    """

    def test_a_known_option_after_the_command_word_is_not_the_watchers(self, run, tmp_path):
        """`--quiet` here is an argument to echo; consuming it also hid the header."""
        result = run("exit-zero", "--max-polls", "1", "--interval", "0", "echo", "--quiet", "hi")
        assert result.code == 0
        assert "`echo --quiet hi`" in result, "the watcher ate a flag meant for the command"
        assert "watching" in result, "--quiet was applied to the watcher"

    def test_a_dash_h_after_the_command_word_does_not_print_watcher_help(self, run):
        """Swallowing it printed help and exited 0, which a caller reads as MET."""
        result = run("exit-zero", "--max-polls", "1", "--interval", "0", "echo", "-h")
        assert "Usage: watch.py" not in result
        assert "`echo -h`" in result

    def test_help_before_the_command_word_still_works(self, run):
        result = run("command", "--help")
        assert result.code == 0
        assert "--json-path" in result


class TestVerboseOnEitherSide:
    """The either-side contract covers `-v` too, which the port had dropped."""

    def test_before_the_condition(self, run, present):
        result = run("-v", "--interval", "0", "--max-polls", "1", "file-exists", str(present))
        assert result.code == 0
        assert "poll 1 met=True" in result

    def test_after_the_condition(self, run, present):
        result = run("file-exists", str(present), "-v", "--interval", "0", "--max-polls", "1")
        assert result.code == 0
        assert "poll 1 met=True" in result


class TestHelp:
    def test_top_level_help_documents_the_exit_codes(self, run):
        result = run("--help")
        assert result.code == 0
        assert "exit codes" in result

    def test_condition_help_lists_its_own_options(self, run):
        result = run("command", "--help")
        assert result.code == 0
        assert "--json-path" in result

    def test_condition_help_also_lists_the_shared_flags(self, run):
        result = run("file-exists", "--help")
        assert result.code == 0
        assert "--max-polls" in result


def test_verbose_traces_each_poll(run, present):
    result = run("-v", *FAST, "file-exists", str(present))
    assert result.code == 0
    assert "poll 1 met=True" in result
