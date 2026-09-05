"""`resolve`: turn a profile fragment and the intended arguments into a spawn call, or refuse.

The refusals are the point. Every one of them is a spawn that would have been
accepted and then behaved differently from what the caller believed.
"""

from __future__ import annotations

import pytest

LONG_PROMPT = (
    "Refactor the retry logic in /srv/app/src/api/client.ts to keep the existing backoff curve "
    "and only change the retry ceiling. Run the test suite with task test before reporting. "
    "Report the diff."
)


@pytest.fixture
def resolve(run, profiles_file):
    def _resolve(*args: str, prompt: str | None = LONG_PROMPT) -> object:
        base = ["resolve", "--profiles", str(profiles_file), *args]
        if prompt is not None and "--prompt-file" not in args:
            base += ["--prompt", prompt]
        return run(*base)

    return _resolve


class TestMatching:
    @pytest.mark.parametrize(
        ("want", "expect"),
        [
            pytest.param("personal/claude/opus", '"profile": "personal/claude/opus"', id="exact id"),
            pytest.param("personal glm-5.3", '"personal/kilic/glm-5.3:cloud"', id="loose fragment"),
        ],
    )
    def test_resolves(self, resolve, want, expect):
        result = resolve("--want", want)
        assert result.code == 0
        assert expect in result

    @pytest.mark.parametrize(
        ("want", "expect"),
        [
            pytest.param("personal claude", "is ambiguous between", id="ambiguous fragment"),
            pytest.param("personal claude", "personal/claude/sonnet", id="ambiguous lists candidates"),
            pytest.param("work gemini", "personal/codex/gpt", id="no match lists what exists"),
            pytest.param("personal/broken/one", "failed to resolve", id="a row carrying an error is refused"),
        ],
    )
    def test_unlaunchable_is_exit_three(self, resolve, want, expect):
        result = resolve("--want", want)
        assert result.code == 3
        assert expect in result

    def test_verbose_reports_the_match_count(self, run, profiles_file):
        result = run("-v", "resolve", "--profiles", str(profiles_file), "--want", "glm-5.3", "--prompt", LONG_PROMPT)
        assert result.code == 0
        assert "matched 1 of 6" in result


class TestBriefWarnings:
    """A thin brief costs a whole session, so it warns rather than failing."""

    @pytest.mark.parametrize(
        ("args", "prompt", "expect"),
        [
            pytest.param(("--want", "personal/claude/opus"), "do it", "thin brief", id="thin prompt"),
            pytest.param(("--want", "personal/claude/opus"), None, "incomplete", id="no prompt at all"),
            pytest.param(("--want", "personal/kilic/cheap"), LONG_PROMPT, "headless", id="headless profile"),
        ],
    )
    def test_warns_without_refusing(self, resolve, args, prompt, expect):
        result = resolve(*args, prompt=prompt)
        assert result.code == 0
        assert expect in result


class TestModes:
    """Mode is per-vendor, and the wrong one restricts nothing while looking restrictive."""

    @pytest.mark.parametrize(
        ("want", "mode", "expect"),
        [
            pytest.param("personal/claude/opus", "plan", "gates the skill discovery", id="claude plan is refused"),
            pytest.param("personal/claude/opus", "bypassPermissions", "widens", id="claude bypass is refused"),
            pytest.param("personal/claude/opus", "build", "claude mode must be", id="claude unknown mode"),
            pytest.param("glm-5.3", "auto", "opencode mode must be", id="opencode unknown mode"),
            pytest.param("personal/codex/gpt", "plan", "codex mode must be", id="codex rejects claude's vocabulary"),
        ],
    )
    def test_refused(self, resolve, want, mode, expect):
        result = resolve("--want", want, "--mode", mode)
        assert result.code == 2
        assert expect in result

    def test_opencode_build_passes(self, resolve):
        result = resolve("--want", "glm-5.3", "--mode", "build")
        assert result.code == 0
        assert '"mode": "build"' in result


class TestReadOnly:
    """`--read-only` lands differently per vendor, and on claude a mode alone is not a restriction."""

    def test_opencode_read_only_is_plan(self, resolve):
        result = resolve("--want", "glm-5.3", "--read-only")
        assert result.code == 0
        assert '"mode": "plan"' in result

    def test_claude_read_only_demands_a_write_block(self, resolve):
        result = resolve("--want", "personal/claude/opus", "--read-only")
        assert result.code == 2
        assert "needs a --disallowedTools" in result

    def test_claude_read_only_with_a_block_stays_auto(self, resolve):
        result = resolve(
            "--want",
            "personal/claude/opus",
            "--read-only",
            "--arg=--disallowedTools",
            "--arg",
            "mcp__slack-kilic__slack_post_message,Write,Edit",
        )
        assert result.code == 0
        assert '"mode": "auto"' in result

    def test_codex_read_only_is_the_sandbox_mode(self, resolve):
        """hyprpilot projects codex `mode` to `--sandbox`, so read-only is a real lever."""
        result = resolve("--want", "personal/codex/gpt", "--read-only")
        assert result.code == 0
        assert '"mode": "read-only"' in result


class TestArgs:
    """`args` is forwarded verbatim to the vendor, so a wrong spelling blocks nothing silently."""

    def test_underscored_server_key_warns(self, resolve):
        result = resolve(
            "--want", "personal/claude/opus", "--arg=--disallowedTools=mcp__slack_kilic__slack_post_message"
        )
        assert result.code == 0
        assert "blocks nothing" in result

    def test_kebab_server_key_does_not_warn(self, resolve):
        result = resolve(
            "--want", "personal/claude/opus", "--arg=--disallowedTools=mcp__slack-kilic__slack_post_message"
        )
        assert result.code == 0
        assert "blocks nothing" not in result

    def test_widening_arg_is_refused(self, resolve):
        result = resolve("--want", "personal/claude/opus", "--arg=--dangerously-skip-permissions")
        assert result.code == 2
        assert "widens" in result

    def test_opencode_args_point_at_its_help(self, resolve):
        result = resolve("--want", "glm-5.3", "--arg=--variant", "--arg", "x")
        assert result.code == 0
        assert "opencode run --help" in result


class TestWithConfig:
    @pytest.mark.parametrize(
        ("value", "code", "expect"),
        [
            pytest.param('[{"model":"opus"}]', 0, '"with_config"', id="array passes"),
            pytest.param('{"model":"opus"}', 2, "array of objects", id="bare object is refused"),
            pytest.param('[{"env":{"X":"1"}}]', 2, "refused by spawn", id="key spawn rejects"),
            pytest.param("model=opus", 2, "not JSON", id="non-json"),
        ],
    )
    def test_with_config(self, resolve, value, code, expect):
        result = resolve("--want", "personal/claude/opus", "--with-config", value)
        assert result.code == code
        assert expect in result


def test_wait_warns_about_the_raw_stream(resolve):
    result = resolve("--want", "personal/claude/opus", "--wait")
    assert result.code == 0
    assert "raw event stream" in result


def test_json_output_is_only_the_call(resolve):
    result = resolve("--want", "personal/claude/opus", "--json")
    assert result.code == 0
    assert '"profile"' in result


def test_profiles_can_come_from_stdin(run, profiles_file):
    result = run(
        "resolve",
        "--profiles",
        "-",
        "--want",
        "personal/claude/opus",
        "--prompt",
        LONG_PROMPT,
        stdin=profiles_file.read_text(),
    )
    assert result.code == 0
    assert '"personal/claude/opus"' in result


class TestPromptSources:
    def test_prompt_and_prompt_file_conflict(self, run, profiles_file):
        result = run(
            "resolve",
            "--profiles",
            str(profiles_file),
            "--want",
            "personal/claude/opus",
            "--prompt",
            "x",
            "--prompt-file",
            str(profiles_file),
        )
        assert result.code == 2
        assert "mutually exclusive" in result

    def test_prompt_file_lands_as_file(self, run, profiles_file):
        result = run(
            "resolve",
            "--profiles",
            str(profiles_file),
            "--want",
            "personal/claude/opus",
            "--prompt-file",
            str(profiles_file),
        )
        assert result.code == 0
        assert f'"file": "{profiles_file}"' in result

    @pytest.mark.parametrize(
        ("value", "expect"),
        [
            pytest.param("brief.md", "absolute path", id="relative"),
            pytest.param("{tmp}/nope.md", "does not exist", id="missing"),
        ],
    )
    def test_prompt_file_refusals(self, run, profiles_file, tmp_path, value, expect):
        result = run(
            "resolve",
            "--profiles",
            str(profiles_file),
            "--want",
            "personal/claude/opus",
            "--prompt-file",
            value.format(tmp=tmp_path),
        )
        assert result.code == 2
        assert expect in result


def test_relative_cwd_is_refused(resolve):
    result = resolve("--want", "personal/claude/opus", "--cwd", "repo")
    assert result.code == 2
    assert "absolute path" in result


@pytest.mark.parametrize(
    ("content", "expect"),
    [
        pytest.param("not json at all\n", "not JSON", id="non-json profiles"),
        pytest.param('{"type":"system"}\n', "list_profiles result", id="json without rows"),
    ],
)
def test_bad_profiles_input(run, tmp_path, content, expect):
    path = tmp_path / "profiles-bad.json"
    path.write_text(content)
    result = run("resolve", "--profiles", str(path), "--want", "x")
    assert result.code == 2
    assert expect in result


def test_missing_profiles_file_is_refused(run, tmp_path):
    result = run("resolve", "--profiles", str(tmp_path / "none.json"), "--want", "x")
    assert result.code == 2
    assert "cannot read" in result


@pytest.mark.parametrize(
    ("args", "expect"),
    [
        pytest.param((), "Missing option", id="no --want"),
        pytest.param(("--want", "x", "--model", "y"), "No such option", id="unknown option"),
    ],
)
def test_resolve_usage_errors(run, profiles_file, args, expect):
    result = run("resolve", "--profiles", str(profiles_file), *args)
    assert result.code == 2
    assert expect in result
