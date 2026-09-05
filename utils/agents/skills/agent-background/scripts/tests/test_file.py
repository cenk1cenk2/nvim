"""File conditions: `file-exists`, `file-gone`, `file-flat`.

Exit 0 is met, exit 1 is the ceiling. A ceiling is a backstop, not a verdict,
so its output has to say what it last saw and point at a real check.
"""

from __future__ import annotations

import threading
import time
from pathlib import Path

# Poll as fast as the loop allows: these cases assert on the ending, not on timing.
FAST = ("--interval", "0", "--max-polls", "3")


def test_present_file_exits_zero(run, present):
    result = run(*FAST, "file-exists", str(present))
    assert result.code == 0
    assert "met after 1 poll" in result


def test_absent_file_hits_the_ceiling(run, missing):
    result = run(*FAST, "file-exists", str(missing))
    assert result.code == 1
    assert "not met after 3 poll" in result


def test_ceiling_advises_a_real_check(run, missing):
    """A ceiling is a backstop, so it must not read as a verdict."""
    result = run(*FAST, "file-exists", str(missing))
    assert result.code == 1
    assert "check the real state" in result


def test_it_fires_when_the_file_appears(run, tmp_path: Path):
    late = tmp_path / "late"
    threading.Timer(0.15, lambda: late.write_text("")).start()

    result = run("--interval", "0.05", "--max-polls", "40", "file-exists", str(late))
    assert result.code == 0
    assert "met after" in result


def test_file_gone_is_met_when_absent(run, missing):
    result = run(*FAST, "file-gone", str(missing))
    assert result.code == 0
    assert "met after 1 poll" in result


def test_file_gone_on_a_present_file_hits_the_ceiling(run, present):
    result = run(*FAST, "file-gone", str(present))
    assert result.code == 1
    assert "not met" in result


def test_label_appears_in_the_result_line(run, present):
    result = run(*FAST, "--label", "K-1", "file-exists", str(present))
    assert result.code == 0
    assert "RESULT: K-1 met" in result


def test_quiet_drops_the_header(run, present):
    result = run(*FAST, "--quiet", "file-exists", str(present))
    assert result.code == 0
    assert "watching" not in result


class TestFileFlat:
    """A stall detector: the file stopped growing for `--for` seconds."""

    def test_a_static_file_is_flat(self, run, tmp_path: Path):
        flat = tmp_path / "flat"
        flat.write_text("abc")
        result = run("--interval", "0.05", "--max-polls", "40", "file-flat", str(flat), "--for", "0.2")
        assert result.code == 0
        assert "met after" in result

    def test_a_growing_file_is_not_flat(self, run, tmp_path: Path):
        growing = tmp_path / "growing"
        growing.write_text("")

        def grow() -> None:
            for _ in range(8):
                with growing.open("a") as fh:
                    fh.write("x")
                time.sleep(0.05)

        writer = threading.Thread(target=grow, daemon=True)
        writer.start()
        result = run("--interval", "0.05", "--max-polls", "6", "file-flat", str(growing), "--for", "0.2")
        writer.join(timeout=5)
        assert result.code == 1
        assert "not met" in result

    def test_an_absent_file_is_never_flat(self, run, missing):
        """Absent is not the same as stopped growing - it has not started."""
        result = run(*FAST, "file-flat", str(missing), "--for", "0.1")
        assert result.code == 1
        assert "absent" in result
