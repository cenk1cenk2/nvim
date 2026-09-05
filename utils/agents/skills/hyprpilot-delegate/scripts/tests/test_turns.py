"""Unit tests for `lib.turns`, the transcript parser the verbs share.

These import the module directly rather than shelling out. The CLI tests prove
the exit-code contract; these prove the parsing decisions underneath it, which a
subprocess can only reach through whichever verb happens to expose them.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

SCRIPTS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(SCRIPTS))

from lib import turns  # noqa: E402


class TestResolveTranscript:
    def test_a_turn_directory_resolves_to_its_transcript(self, tmp_path):
        (tmp_path / "turns.jsonl").write_text("")
        assert turns.resolve_transcript(str(tmp_path)) == str(tmp_path / "turns.jsonl")

    def test_a_file_path_passes_through(self, tmp_path):
        target = tmp_path / "turns.jsonl"
        target.write_text("")
        assert turns.resolve_transcript(str(target)) == str(target)

    @pytest.mark.parametrize("path", ["/tmp/turns/*/turns.jsonl", "/tmp/turns/?/turns.jsonl", "/tmp/[abc]/turns.jsonl"])
    def test_every_glob_character_is_refused(self, path):
        """A glob matches a finished sibling turn, which is the false-fire this guards."""
        with pytest.raises(turns.TranscriptError, match="glob character"):
            turns.resolve_transcript(path)

    def test_missing_path_is_named(self, tmp_path):
        with pytest.raises(turns.TranscriptError, match="does not exist"):
            turns.resolve_transcript(str(tmp_path / "absent.jsonl"))

    def test_empty_path_is_refused(self):
        with pytest.raises(turns.TranscriptError, match="no transcript path"):
            turns.resolve_transcript("")


class TestReadEvents:
    def test_a_truncated_line_yields_none_and_the_read_continues(self, tmp_path):
        """A transcript can be truncated mid-write while the turn is still running."""
        target = tmp_path / "turns.jsonl"
        target.write_text('{"type":"system"}\n{"type":"assist\n{"type":"result"}\n')

        events = list(turns.read_events(str(target)))
        assert [lineno for lineno, _ in events] == [1, 2, 3]
        assert events[1][1] is None
        assert events[0][1]["type"] == "system"
        assert events[2][1]["type"] == "result"

    def test_blank_lines_are_skipped_without_a_line_number_gap(self, tmp_path):
        target = tmp_path / "turns.jsonl"
        target.write_text('{"type":"a"}\n\n\n{"type":"b"}\n')
        assert [lineno for lineno, _ in turns.read_events(str(target))] == [1, 4]

    def test_a_non_object_line_is_not_an_event(self, tmp_path):
        target = tmp_path / "turns.jsonl"
        target.write_text('["a list"]\n42\n"a string"\n')
        assert [event for _, event in turns.read_events(str(target))] == [None, None, None]


class TestEventLabel:
    @pytest.mark.parametrize(
        ("event", "expect"),
        [
            pytest.param({"type": "result"}, "result", id="plain type"),
            pytest.param(
                {"type": "item.completed", "item": {"type": "agent_message"}},
                "item.completed/agent_message",
                id="codex item carries its inner type",
            ),
            pytest.param(
                {"type": "item.completed", "item": {}}, "item.completed/<no-item-type>", id="item without a type"
            ),
            pytest.param(
                {"type": "item.completed", "item": "not-a-dict"}, "item.completed", id="item that is not an object"
            ),
            pytest.param({}, "<no-type>", id="event without a type"),
        ],
    )
    def test_label(self, event, expect):
        assert turns.event_label(event) == expect


class TestDetectProvider:
    """`session.json` does not record the vendor, so event shape is the only evidence."""

    @pytest.mark.parametrize(
        ("events", "expect"),
        [
            pytest.param([{"type": "result", "subtype": "success"}], "claude", id="claude terminal result"),
            pytest.param(
                [{"type": "assistant", "message": {"content": "hi"}}], "claude", id="claude assistant message"
            ),
            pytest.param([{"type": "item.completed", "item": {"type": "agent_message"}}], "codex", id="codex item"),
            pytest.param([{"type": "turn.completed"}], "codex", id="codex turn completion"),
            pytest.param([{"type": "text", "part": {"text": "hi"}}], "opencode", id="opencode text part"),
            pytest.param([{"type": "step_finish"}], "opencode", id="opencode step event"),
        ],
    )
    def test_detects(self, events, expect):
        provider, _ = turns.detect_provider(events)
        assert provider == expect

    def test_no_recognised_event_is_no_provider(self):
        provider, score = turns.detect_provider([{"type": "mystery"}])
        assert provider is None
        assert set(score) == set(turns.PROVIDERS)

    def test_an_empty_transcript_has_no_provider(self):
        provider, _ = turns.detect_provider([])
        assert provider is None

    def test_scoring_beats_first_match_on_a_mixed_transcript(self):
        """A single ambiguous event must not outvote the vendor's own terminal shape."""
        events = [
            {"type": "system", "session_id": "x"},
            {"type": "text", "part": {"text": "a"}},
            {"type": "text", "part": {"text": "b"}},
        ]
        provider, score = turns.detect_provider(events)
        assert provider == "opencode"
        assert score["opencode"] > score["claude"]


class TestScan:
    def test_scan_reports_the_result_and_its_source(self, tmp_path):
        target = tmp_path / "turns.jsonl"
        target.write_text(
            json.dumps({"type": "system", "session_id": "x"})
            + "\n"
            + json.dumps({"type": "result", "subtype": "success", "result": "ANSWER"})
            + "\n"
        )
        info = turns.scan(str(target))
        assert info["provider"] == "claude"
        assert info["result"] == "ANSWER"
        assert info["events"] == 2

    def test_rescan_as_overrides_detection(self, tmp_path):
        """`--provider` exists for a transcript whose shape is ambiguous or wrong."""
        target = tmp_path / "turns.jsonl"
        target.write_text(json.dumps({"type": "result", "subtype": "success", "result": "ANSWER"}) + "\n")

        detected = turns.scan(str(target))
        assert detected["provider"] == "claude"

        forced = turns.rescan_as(str(target), "codex")
        assert forced["provider"] == "codex"
        assert forced["result"] != "ANSWER"


def test_withheld_keys_cover_the_credential_carrying_fields():
    """Nothing in this module prints a raw event; these names let a caller say a key was present."""
    assert "env" in turns.WITHHELD_KEYS
    assert "authorization" in turns.WITHHELD_KEYS
