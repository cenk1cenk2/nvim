"""`command` and `exit-zero`: the conditions that shell out.

`command` compares a command's stdout, optionally narrowed by `--json-path`.
The load-bearing rule is that a non-zero exit is NEVER met - a CLI that fails
to parse its own API response exits 1 with empty output, and treating that as
a match fires the watcher on nothing.
"""

from __future__ import annotations

import threading
import time
from pathlib import Path

FAST = ("--interval", "0", "--max-polls", "3")


class TestExitZero:
    def test_true_is_met(self, run):
        result = run(*FAST, "exit-zero", "--", "true")
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_false_hits_the_ceiling_and_reports_the_code(self, run):
        result = run(*FAST, "exit-zero", "--", "false")
        assert result.code == 1
        assert "last observed: exit 1" in result

    def test_a_missing_binary_is_exit_three(self, run, tmp_path: Path):
        """Exit 3 is 'the check cannot run' - polling would never change it."""
        result = run(*FAST, "exit-zero", "--", str(tmp_path / "no-such-binary"))
        assert result.code == 3
        assert "command not found" in result


class TestExpect:
    def test_stdout_equal_to_expect_is_met(self, run, cat, merged):
        result = run(*FAST, "command", "--expect", "MERGED", "--", str(cat), str(merged))
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_any_of_several_expects_matches(self, run, cat, merged):
        result = run(*FAST, "command", "--expect", "CLOSED", "--expect", "MERGED", "--", str(cat), str(merged))
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_a_mismatch_reports_what_it_saw(self, run, cat, merged):
        result = run(*FAST, "command", "--expect", "CLOSED", "--", str(cat), str(merged))
        assert result.code == 1
        assert "last observed: MERGED" in result

    def test_contains_matches_a_substring(self, run, cat, merged):
        result = run(*FAST, "command", "--contains", "--expect", "ERGE", "--", str(cat), str(merged))
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_expect_file_carries_quotes(self, run, cat, tmp_path: Path):
        """A value with quotes cannot survive the shell, so it is read from a file."""
        expect = tmp_path / "expect.txt"
        expect.write_text('{"a": "b"}\n')
        payload = tmp_path / "quoted.out"
        payload.write_text('{"a": "b"}\n')

        result = run(*FAST, "command", "--expect-file", str(expect), "--", str(cat), str(payload))
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_a_missing_binary_is_exit_three(self, run, tmp_path: Path):
        result = run(*FAST, "command", "--expect", "x", "--", str(tmp_path / "no-such-binary"))
        assert result.code == 3
        assert "command not found" in result

    def test_a_non_zero_exit_is_never_met(self, run, cat, tmp_path: Path):
        """`glab` piped into a parser exits 1 with empty output; that must not read as a match."""
        result = run(*FAST, "command", "--expect", "x", "--", str(cat), str(tmp_path / "missing"))
        assert result.code == 1
        assert "last observed: exit 1" in result


class TestJsonPath:
    def test_it_narrows_an_object(self, run, cat, mr_json):
        result = run(
            *FAST, "command", "--json-path", "pipeline.status", "--expect", "running", "--", str(cat), str(mr_json)
        )
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_it_indexes_a_list(self, run, cat, mr_json):
        result = run(
            *FAST, "command", "--json-path", "jobs.0.status", "--expect", "success", "--", str(cat), str(mr_json)
        )
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_an_unresolved_path_is_not_met(self, run, cat, mr_json):
        result = run(*FAST, "command", "--json-path", "nope.x", "--expect", "y", "--", str(cat), str(mr_json))
        assert result.code == 1
        assert "unresolved" in result

    def test_a_path_against_non_json_is_not_met(self, run, cat, merged):
        """Not an error: a CLI can emit a plain line where JSON was expected."""
        result = run(*FAST, "command", "--json-path", "state", "--expect", "MERGED", "--", str(cat), str(merged))
        assert result.code == 1
        assert "unresolved" in result


class TestJsonPathExpressions:
    """The jq-shaped form, for what a dotted path cannot express."""

    def test_a_bracket_index(self, run, cat, mr_json):
        result = run(
            *FAST, "command", "--json-path", "$.jobs[0].status", "--expect", "success", "--", str(cat), str(mr_json)
        )
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_a_filter_selects_by_field(self, run, cat, mr_json):
        """The case the dotted form cannot do: pick the job by name, not by position."""
        expression = '$.jobs[?(@.name=="lint")].status'
        result = run(*FAST, "command", "--json-path", expression, "--expect", "success", "--", str(cat), str(mr_json))
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_a_dollar_root_reaches_a_scalar(self, run, cat, mr_json):
        result = run(
            *FAST, "command", "--json-path", "$.pipeline.status", "--expect", "running", "--", str(cat), str(mr_json)
        )
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_several_matches_are_refused_not_guessed(self, run, cat, mr_json):
        """Firing on whichever node sorted first is the same bug class as a glob."""
        result = run(
            *FAST, "command", "--json-path", "$.jobs[*].status", "--expect", "success", "--", str(cat), str(mr_json)
        )
        assert result.code == 1
        assert "unresolved" in result

    def test_a_path_matching_nothing_is_not_met(self, run, cat, mr_json):
        result = run(*FAST, "command", "--json-path", "$.nope.missing", "--expect", "x", "--", str(cat), str(mr_json))
        assert result.code == 1
        assert "unresolved" in result

    def test_a_dollar_prefixed_key_is_a_dotted_path_not_an_expression(self, run, cat, tmp_path):
        """`$schema`, `$ref` and `$id` are ordinary JSON keys, not JSONPath."""
        payload = tmp_path / "schema.json"
        payload.write_text('{"$schema": "ok"}')
        result = run(*FAST, "command", "--json-path", "$schema", "--expect", "ok", "--", str(cat), str(payload))
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_a_malformed_expression_is_a_usage_error_at_arm_time(self, run, cat, merged):
        """Parsed only per poll it raised inside the loop and exited 1, reading as a ceiling."""
        result = run(*FAST, "command", "--json-path", "$[", "--expect", "x", "--", str(cat), str(merged))
        assert result.code == 2
        assert "not a valid JSONPath" in result
        assert "watching" not in result, "it must refuse before arming"


class TestNegate:
    def test_it_waits_for_a_value_to_leave_the_set(self, run, cat, mr_json):
        result = run(
            *FAST,
            "command",
            "--negate",
            "--expect",
            "opened",
            "--json-path",
            "pipeline.status",
            "--",
            str(cat),
            str(mr_json),
        )
        assert result.code == 0
        assert "met after 1 poll" in result

    def test_a_still_matching_value_is_not_met(self, run, cat, mr_json):
        result = run(
            *FAST,
            "command",
            "--negate",
            "--expect",
            "running",
            "--json-path",
            "pipeline.status",
            "--",
            str(cat),
            str(mr_json),
        )
        assert result.code == 1
        assert "not met" in result


class TestTransitions:
    """Transitions print as they happen, so the wake carries a history rather than one value."""

    def test_a_change_is_printed(self, run, cat, tmp_path: Path):
        target = tmp_path / "transition"
        target.write_text("queued\n")

        def move() -> None:
            time.sleep(0.12)
            target.write_text("running\n")
            time.sleep(0.12)
            target.write_text("done\n")

        writer = threading.Thread(target=move, daemon=True)
        writer.start()
        result = run(
            "--interval", "0.05", "--max-polls", "40", "command", "--expect", "done", "--", str(cat), str(target)
        )
        writer.join(timeout=5)
        assert result.code == 0
        assert "CHANGE: poll" in result

    def test_the_first_value_is_a_change_too(self, run, cat, merged):
        result = run(*FAST, "command", "--expect", "MERGED", "--", str(cat), str(merged))
        assert result.code == 0
        assert "value=MERGED" in result
