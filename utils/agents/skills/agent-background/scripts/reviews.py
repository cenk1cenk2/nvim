"""Review activity: snapshot the MR or PR at the first poll, then fire when it changes.

Review activity has no target value to wait for, so these conditions record a
baseline and diff every later poll against it. Identity is by note, review and
thread id, never by count: an edited note keeps its id and a deleted one only
disappears, so neither reads as new activity.
"""

from __future__ import annotations

import json
from collections.abc import Callable, Iterable
from dataclasses import dataclass, field
from urllib.parse import quote

from probes import CannotRun, run_command

KINDS = ("note", "resolved", "approval", "changes", "closed")
GITLAB_KINDS = tuple(kind for kind in KINDS if kind != "changes")


class FetchError(Exception):
    """One read of the review state failed. Fatal for the baseline, retried afterwards."""


@dataclass(frozen=True)
class Note:
    author: str
    where: str | None = None


@dataclass(frozen=True)
class Thread:
    resolved: bool
    resolved_by: str | None = None
    where: str | None = None


@dataclass(frozen=True)
class Review:
    state: str
    author: str


@dataclass(frozen=True)
class Snapshot:
    state: str
    notes: dict[str, Note] = field(default_factory=dict)
    threads: dict[str, Thread] = field(default_factory=dict)
    approvals: frozenset[str] = frozenset()
    reviews: dict[str, Review] = field(default_factory=dict)

    def summary(self) -> str:
        resolved = sum(thread.resolved for thread in self.threads.values())
        return (
            f"state={self.state} notes={len(self.notes)} threads={resolved}/{len(self.threads)} resolved "
            f"approvals={len(self.approvals)}"
        )


@dataclass(frozen=True)
class Event:
    kind: str
    text: str


def _by(author: str | None) -> str:
    return f" by {author}" if author else ""


def _at(where: str | None) -> str:
    return f" ({where})" if where else ""


class ReviewActivity:
    """Probe: the first call takes the baseline, every later call diffs against it."""

    reports_first_value = True

    def __init__(
        self,
        ref: str,
        fetch: Callable[[], Snapshot],
        closed_states: tuple[str, ...],
        kinds: Iterable[str],
        ignore: Iterable[str],
    ):
        self.ref = ref
        self.fetch = fetch
        self.closed_states = closed_states
        # `closed` is always watched: a merged or closed MR gets no more review,
        # so a watcher without it would poll to its ceiling on a dead subject.
        self.kinds = frozenset(kinds) | {"closed"}
        self.ignore = frozenset(ignore)
        self.baseline: Snapshot | None = None
        self.outcome: str | None = None

    def describe(self) -> str:
        ignoring = f", ignoring {', '.join(sorted(self.ignore))}" if self.ignore else ""
        return f"review activity on {self.ref}: {' | '.join(k for k in KINDS if k in self.kinds)}{ignoring}"

    def __call__(self) -> tuple[bool, str | None]:
        try:
            current = self.fetch()
        except (FetchError, CannotRun) as err:
            if self.baseline is None:
                raise CannotRun(f"cannot take the baseline: {err}") from None
            return False, f"poll failed, retrying: {err}"
        if self.baseline is None:
            self.baseline = current
        event = next((event for event in self.diff(self.baseline, current) if event.kind in self.kinds), None)
        if event is not None:
            self.outcome = event.text
            return True, current.summary()
        return False, current.summary()

    def diff(self, before: Snapshot, after: Snapshot) -> Iterable[Event]:
        # Checked against the state itself rather than a transition, so a watch
        # armed on an MR that already merged ends at its first poll.
        if after.state in self.closed_states:
            yield Event("closed", f"closed {self.ref} as {after.state}")
        for review_id, review in after.reviews.items():
            if review_id in before.reviews or review.author in self.ignore:
                continue
            if review.state == "CHANGES_REQUESTED":
                yield Event("changes", f"changes requested on {self.ref}{_by(review.author)}")
            elif review.state == "APPROVED":
                yield Event("approval", f"approval on {self.ref}{_by(review.author)}")
        for user in sorted(after.approvals - before.approvals - self.ignore):
            yield Event("approval", f"approval on {self.ref}{_by(user)}")
        for user in sorted(before.approvals - after.approvals - self.ignore):
            yield Event("approval", f"approval withdrawn on {self.ref}{_by(user)}")
        for thread_id, thread in after.threads.items():
            was = before.threads.get(thread_id)
            if was is None or was.resolved == thread.resolved:
                continue
            if thread.resolved:
                if thread.resolved_by not in self.ignore:
                    yield Event(
                        "resolved", f"resolved thread on {self.ref}{_by(thread.resolved_by)}{_at(thread.where)}"
                    )
            else:
                yield Event("resolved", f"reopened thread on {self.ref}{_at(thread.where)}")
        for note_id, note in after.notes.items():
            if note_id not in before.notes and note.author not in self.ignore:
                yield Event("note", f"note on {self.ref}{_by(note.author)}{_at(note.where)}")


def _read(argv: list[str]) -> str:
    code, out = run_command(argv)
    if code != 0:
        raise FetchError(f"`{' '.join(argv[:3])}` exit {code}")
    return out


def _json(argv: list[str]):
    try:
        return json.loads(_read(argv))
    except json.JSONDecodeError as err:
        raise FetchError(f"`{' '.join(argv[:3])}` returned no JSON: {err}") from None


def _where(path: str | None, line: int | None) -> str | None:
    if not path:
        return None
    return f"{path}:{line}" if line else path


def gitlab_snapshot(project: str, iid: str) -> Snapshot:
    base = f"projects/{quote(project, safe='')}/merge_requests/{iid}"
    mr = _json(["glab", "api", base])
    # `--output ndjson` because the default output concatenates one JSON array
    # per page, which is not a JSON document once there is a second page.
    lines = _read(["glab", "api", "--paginate", "--output", "ndjson", f"{base}/discussions?per_page=100"])
    try:
        discussions = [json.loads(line) for line in lines.splitlines() if line.strip()]
    except json.JSONDecodeError as err:
        raise FetchError(f"discussions returned no JSON: {err}") from None
    approvals = _json(["glab", "api", f"{base}/approvals"])

    notes: dict[str, Note] = {}
    threads: dict[str, Thread] = {}
    for discussion in discussions:
        human = [note for note in discussion.get("notes", []) if not note.get("system")]
        for note in human:
            position = note.get("position") or {}
            where = _where(
                position.get("new_path") or position.get("old_path"),
                position.get("new_line") or position.get("old_line"),
            )
            notes[str(note["id"])] = Note(note["author"]["username"], where)
        resolvable = [note for note in human if note.get("resolvable")]
        if resolvable:
            resolved = all(note.get("resolved") for note in resolvable)
            last = resolvable[-1].get("resolved_by") or {}
            threads[discussion["id"]] = Thread(resolved, last.get("username"), notes[str(resolvable[0]["id"])].where)
    approved_by = frozenset(entry["user"]["username"] for entry in approvals.get("approved_by", []))
    return Snapshot(state=mr["state"], notes=notes, threads=threads, approvals=approved_by)


THREADS_QUERY = """
query($owner: String!, $name: String!, $number: Int!, $endCursor: String) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviewThreads(first: 100, after: $endCursor) {
        nodes { id isResolved path line resolvedBy { login } }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}
"""


def _login(item: dict) -> str:
    """A deleted GitHub account comes back as a null user."""
    return (item.get("user") or {}).get("login") or "ghost"


def _pages(argv: list[str]) -> list:
    """`--slurp` wraps every page in one outer array; flatten it back to the items."""
    return [item for page in _json(argv) for item in page]


def github_snapshot(repo: str, number: str) -> Snapshot:
    owner, _, name = repo.partition("/")
    pr = _json(["gh", "pr", "view", number, "--repo", repo, "--json", "state"])
    issue_comments = _pages(["gh", "api", "--paginate", "--slurp", f"repos/{repo}/issues/{number}/comments"])
    review_comments = _pages(["gh", "api", "--paginate", "--slurp", f"repos/{repo}/pulls/{number}/comments"])
    reviews = _pages(["gh", "api", "--paginate", "--slurp", f"repos/{repo}/pulls/{number}/reviews"])
    variables = [f"-F{key}={value}" for key, value in (("owner", owner), ("name", name), ("number", number))]
    thread_pages = _json(["gh", "api", "graphql", "--paginate", "--slurp", *variables, "-f", f"query={THREADS_QUERY}"])

    notes: dict[str, Note] = {}
    for comment in issue_comments:
        notes[f"issue:{comment['id']}"] = Note(_login(comment))
    for comment in review_comments:
        where = _where(comment.get("path"), comment.get("line") or comment.get("original_line"))
        notes[f"review-comment:{comment['id']}"] = Note(_login(comment), where)
    # A review submitted with inline comments carries an empty COMMENTED body;
    # its comments are the notes. Only a review with a body of its own is one.
    for review in reviews:
        if review["state"] == "COMMENTED" and review.get("body"):
            notes[f"review:{review['id']}"] = Note(_login(review))

    threads: dict[str, Thread] = {}
    for page in thread_pages:
        for thread in page["data"]["repository"]["pullRequest"]["reviewThreads"]["nodes"]:
            resolved_by = (thread.get("resolvedBy") or {}).get("login")
            threads[thread["id"]] = Thread(
                thread["isResolved"], resolved_by, _where(thread.get("path"), thread.get("line"))
            )

    return Snapshot(
        state=pr["state"],
        notes=notes,
        threads=threads,
        approvals=frozenset(_login(review) for review in reviews if review["state"] == "APPROVED"),
        reviews={str(review["id"]): Review(review["state"], _login(review)) for review in reviews},
    )
