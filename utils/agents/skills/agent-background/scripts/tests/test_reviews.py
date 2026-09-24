"""The review-activity conditions: a baseline at the first poll, a diff at every later one.

A stub `glab` or `gh` on PATH serves the recorded payloads under `fixtures/`,
one per endpoint, and a second payload from the next call on. So poll 1 is the
baseline, poll 2 is what the reviewer did, and the ceiling of 2 turns "nothing
happened" into exit 1.
"""

from __future__ import annotations

import copy
import json
import os
import stat
import sys
from pathlib import Path

import pytest

FIXTURES = Path(__file__).resolve().parent / "fixtures"
FAST = ("--interval", "0", "--max-polls", "2")
FAILED = {"__exit__": 1}

STUB = """#!{python}
import json, pathlib, sys

args = sys.argv[1:]
joined = " ".join(args)
root = pathlib.Path({root!r})
if "graphql" in args:
    key = "threads"
elif args[:2] == ["pr", "view"]:
    key = "pr"
elif "/discussions" in joined:
    key = "discussions"
elif "/approvals" in joined:
    key = "approvals"
elif "/issues/" in joined:
    key = "issue_comments"
elif joined.endswith("/comments"):
    key = "review_comments"
elif joined.endswith("/reviews"):
    key = "reviews"
else:
    key = "mr"

sequence = json.loads((root / "scenario.json").read_text())[key]
counter = root / f"{{key}}.count"
calls = int(counter.read_text()) if counter.exists() else 0
counter.write_text(str(calls + 1))
payload = sequence[min(calls, len(sequence) - 1)]

if isinstance(payload, dict) and "__exit__" in payload:
    sys.exit(payload["__exit__"])
if "ndjson" in args:
    print("\\n".join(json.dumps(item) for item in payload))
elif key == "threads":
    page = {{"reviewThreads": {{"nodes": payload, "pageInfo": {{"hasNextPage": False, "endCursor": None}}}}}}
    print(json.dumps([{{"data": {{"repository": {{"pullRequest": page}}}}}}]))
elif "--slurp" in args:
    print(json.dumps([payload]))
else:
    print(json.dumps(payload))
"""


def recorded(name: str):
    return json.loads((FIXTURES / f"{name}.json").read_text())


@pytest.fixture
def serve(tmp_path: Path, monkeypatch):
    """Serve each endpoint's recorded fixture, or `before`, first; `{endpoint: after}` from the second call on."""
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    monkeypatch.setenv("PATH", f"{bin_dir}{os.pathsep}{os.environ['PATH']}")

    def _serve(vendor: str, before: dict | None = None, **after) -> None:
        prefix = "gitlab" if vendor == "glab" else "github"
        names = {
            "gitlab": ("mr", "discussions", "approvals"),
            "github": ("pr", "issue_comments", "review_comments", "reviews", "threads"),
        }[prefix]
        scenario = {}
        for name in names:
            baseline = (before or {}).get(name, recorded(f"{prefix}_{name}"))
            scenario[name] = [baseline, after.get(name, baseline)]
        (tmp_path / "scenario.json").write_text(json.dumps(scenario))
        script = bin_dir / vendor
        script.write_text(STUB.format(python=sys.executable, root=str(tmp_path)))
        script.chmod(script.stat().st_mode | stat.S_IEXEC)

    return _serve


def gitlab(*extra: str) -> tuple[str, ...]:
    return (*FAST, "gitlab-mr-review", "--project", "group/project", "--iid", "6", *extra)


def github(*extra: str) -> tuple[str, ...]:
    return (*FAST, "github-pr-review", "--repo", "owner/repo", "--number", "7", *extra)


def discussions_with(note: dict) -> list:
    discussions = recorded("gitlab_discussions")
    discussions.append({"id": f"new-{note['id']}", "individual_note": True, "notes": [note]})
    return discussions


def human_note(author: str = "reviewer", **fields) -> dict:
    return {"id": 2001, "body": "One more thing.", "author": {"username": author}, "system": False, **fields}


class TestGitlab:
    def test_a_system_note_does_not_fire(self, run, serve):
        """Negative control: branch pushes and retargets add notes that are not review."""
        serve("glab", discussions=discussions_with({**human_note(), "system": True, "body": "deleted the branch"}))
        result = run(*gitlab())
        assert result.code == 1

    def test_a_new_human_note_fires_note(self, run, serve):
        position = {"new_path": "src/a.ts", "new_line": 9}
        serve("glab", discussions=discussions_with(human_note(position=position)))
        result = run(*gitlab())
        assert result.code == 0
        assert "RESULT: note on group/project!6 by reviewer (src/a.ts:9)" in result

    def test_an_edited_note_does_not_fire(self, run, serve):
        discussions = recorded("gitlab_discussions")
        discussions[2]["notes"][0]["body"] = "Start every url path with a slash."
        serve("glab", discussions=discussions)
        assert run(*gitlab()).code == 1

    def test_a_deleted_note_does_not_fire(self, run, serve):
        serve("glab", discussions=recorded("gitlab_discussions")[:1])
        assert run(*gitlab()).code == 1

    def test_a_resolved_thread_fires_resolved(self, run, serve):
        discussions = recorded("gitlab_discussions")
        discussions[2]["notes"][0].update(resolved=True, resolved_by={"username": "author"})
        serve("glab", discussions=discussions)
        result = run(*gitlab())
        assert result.code == 0
        assert "RESULT: resolved thread on group/project!6 by author (src/webhook.controller.ts:9)" in result

    def test_an_approval_fires_approval(self, run, serve):
        approvals = {**recorded("gitlab_approvals"), "approved_by": [{"user": {"username": "reviewer"}}]}
        serve("glab", approvals=approvals)
        result = run(*gitlab())
        assert result.code == 0
        assert "RESULT: approval on group/project!6 by reviewer" in result

    def test_merged_fires_closed_even_when_only_notes_are_awaited(self, run, serve):
        serve("glab", mr={**recorded("gitlab_mr"), "state": "merged"})
        result = run(*gitlab("--wait-result", "note"))
        assert result.code == 0
        assert "RESULT: closed group/project!6 as merged" in result

    def test_an_mr_merged_before_the_watch_fires_closed_at_the_first_poll(self, run, serve):
        serve("glab", before={"mr": {**recorded("gitlab_mr"), "state": "merged"}})
        result = run(*gitlab())
        assert result.code == 0
        assert "RESULT: closed group/project!6 as merged" in result

    def test_an_unawaited_kind_does_not_fire(self, run, serve):
        serve("glab", discussions=discussions_with(human_note()))
        assert run(*gitlab("--wait-result", "approval")).code == 1

    def test_an_ignored_author_does_not_fire(self, run, serve):
        serve("glab", discussions=discussions_with(human_note("review-bot")))
        assert run(*gitlab("--ignore-author", "review-bot")).code == 1

    def test_changes_is_refused_for_gitlab(self, run):
        result = run(*gitlab("--wait-result", "changes"))
        assert result.code == 2
        assert "changes" in result

    def test_a_failed_baseline_cannot_run(self, run, serve):
        """Without a baseline there is nothing to diff against, so no later poll can fire."""
        serve("glab", before={"approvals": FAILED})
        result = run(*gitlab())
        assert result.code == 3
        assert "cannot take the baseline" in result

    def test_a_transient_failure_after_the_baseline_is_retried(self, run, serve):
        serve("glab", discussions=FAILED)
        result = run(*gitlab())
        assert result.code == 1
        assert "poll failed, retrying" in result


class TestGithub:
    def test_changes_requested_fires_changes(self, run, serve):
        reviews = [
            *recorded("github_reviews"),
            {"id": 3001, "state": "CHANGES_REQUESTED", "body": "", "user": {"login": "reviewer"}},
        ]
        serve("gh", reviews=reviews)
        result = run(*github())
        assert result.code == 0
        assert "RESULT: changes requested on owner/repo#7 by reviewer" in result

    def test_an_approval_fires_approval(self, run, serve):
        reviews = [
            *recorded("github_reviews"),
            {"id": 3002, "state": "APPROVED", "body": "", "user": {"login": "lead"}},
        ]
        serve("gh", reviews=reviews)
        result = run(*github("--wait-result", "approval"))
        assert result.code == 0
        assert "RESULT: approval on owner/repo#7 by lead" in result

    def test_a_new_review_comment_fires_note_with_its_line(self, run, serve):
        comment = copy.deepcopy(recorded("github_review_comments")[0])
        comment.update(id=4001, line=12, path="pkg/verify/other.go")
        serve("gh", review_comments=[*recorded("github_review_comments"), comment])
        result = run(*github())
        assert result.code == 0
        assert "RESULT: note on owner/repo#7 by reviewer (pkg/verify/other.go:12)" in result

    def test_a_resolved_thread_fires_resolved(self, run, serve):
        threads = recorded("github_threads")
        threads[0].update(isResolved=True, resolvedBy={"login": "author"})
        serve("gh", threads=threads)
        result = run(*github("--wait-result", "resolved"))
        assert result.code == 0
        assert "RESULT: resolved thread on owner/repo#7 by author (pkg/verify/verify.go:130)" in result

    def test_merged_fires_closed_even_when_only_notes_are_awaited(self, run, serve):
        serve("gh", pr={"state": "MERGED"})
        result = run(*github("--wait-result", "note"))
        assert result.code == 0
        assert "RESULT: closed owner/repo#7 as MERGED" in result

    def test_an_ignored_author_does_not_fire(self, run, serve):
        comment = {"id": 5001, "body": "Deployed a preview.", "user": {"login": "preview-bot", "type": "Bot"}}
        serve("gh", issue_comments=[*recorded("github_issue_comments"), comment])
        assert run(*github("--ignore-author", "preview-bot")).code == 1
