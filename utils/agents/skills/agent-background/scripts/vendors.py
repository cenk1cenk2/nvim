"""Domain conditions: a named wrapper over `command` for the things actually waited on.

Each one assembles a vendor CLI invocation, a JSON path into its output, and the
set of TERMINAL values. Defaulting to every terminal state - not just the happy
one - is the point: a failure has to wake you as early as a success, or the
watch silently becomes a timeout.

Every invocation below is built from flags verified against the installed CLI.
When a vendor has no read subcommand for a thing, it is absent here rather than
guessed; an invented flag arms a watcher that never fires.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from agentlib.models import Expectations

from probes import Command


@dataclass(frozen=True)
class Vendor:
    """One domain condition: how to build its argv, what to read, and what ends it."""

    name: str
    help: str
    # Placeholders are filled from the click options of the same name.
    argv: tuple[str, ...]
    json_path: str
    terminal: tuple[str, ...]
    # Options the command needs, in the order they appear in `argv`.
    params: tuple[str, ...] = ()
    settled: tuple[str, ...] = field(default=())

    def build(self, values: dict[str, str], wait_result: tuple[str, ...]) -> Command:
        argv = [part.format(**values) for part in self.argv]
        expect = Expectations(values=tuple(wait_result or self.terminal), json_path=self.json_path)
        wanted = " | ".join(expect.values)
        return Command(argv, expect, describe_as=f"{self.name} {self._subject(values)} reaches {wanted}")

    def _subject(self, values: dict[str, str]) -> str:
        return " ".join(str(values[name]) for name in self.params if values.get(name))


# `glab mr view <iid> --output json` -> `.state`: opened | merged | closed | locked.
GITLAB_MR = Vendor(
    name="gitlab-mr",
    help="A GitLab merge request reaching a terminal state.",
    argv=("glab", "mr", "view", "{iid}", "--repo", "{project}", "--output", "json"),
    json_path="state",
    terminal=("merged", "closed"),
    params=("project", "iid"),
)

# `glab ci get --pipeline-id <id> --output json` -> `.status`.
GITLAB_CI = Vendor(
    name="gitlab-ci",
    help="A GitLab pipeline reaching a terminal status.",
    argv=("glab", "ci", "get", "--pipeline-id", "{pipeline}", "--repo", "{project}", "--output", "json"),
    json_path="status",
    terminal=("success", "failed", "canceled", "skipped"),
    params=("project", "pipeline"),
)

# `glab release view <tag> --output json`; the release existing IS the
# condition, so the expected value is the tag itself.
# UNVERIFIED: the `tag_name` field name. `glab release view` takes `--output
# json` (confirmed against glab 1.116.0), but naming the key needs a real
# release to read. Confirm before relying on this one.
GITLAB_TAG = Vendor(
    name="gitlab-tag",
    help="A GitLab release/tag existing.",
    argv=("glab", "release", "view", "{tag}", "--repo", "{project}", "--output", "json"),
    json_path="tag_name",
    terminal=(),
    params=("project", "tag"),
)

# `gh pr view <n> --json state` -> `.state`: OPEN | MERGED | CLOSED (upper case).
GITHUB_PR = Vendor(
    name="github-pr",
    help="A GitHub pull request reaching a terminal state.",
    argv=("gh", "pr", "view", "{number}", "--repo", "{repo}", "--json", "state"),
    json_path="state",
    terminal=("MERGED", "CLOSED"),
    params=("repo", "number"),
)

# `gh run view <id> --json status,conclusion`. Watch `status` for the ending;
# `conclusion` carries success/failure and is read on wake, not waited on.
GITHUB_ACTION = Vendor(
    name="github-action",
    help="A GitHub Actions run reaching completion.",
    argv=("gh", "run", "view", "{run}", "--repo", "{repo}", "--json", "status,conclusion"),
    json_path="status",
    terminal=("completed",),
    params=("repo", "run"),
)

GITHUB_TAG = Vendor(
    name="github-tag",
    help="A GitHub release/tag existing.",
    argv=("gh", "release", "view", "{tag}", "--repo", "{repo}", "--json", "tagName"),
    json_path="tagName",
    terminal=(),
    params=("repo", "tag"),
)

# spacectl has `stack run list` but NO `stack run get` (confirmed against
# spacectl 1.25.0), so the latest run is read as index 0 of the list.
# UNVERIFIED: the `state` field name and the terminal value spellings; the
# flags are confirmed, the payload keys need a real stack to read.
SPACELIFT_RUN = Vendor(
    name="spacelift-run",
    help="The latest Spacelift run on a stack reaching a terminal state.",
    argv=("spacectl", "stack", "run", "list", "--id", "{stack}", "--max-results", "1", "--output", "json"),
    json_path="0.state",
    terminal=("FINISHED", "FAILED", "CANCELED", "DISCARDED", "STOPPED"),
    params=("stack",),
)

# `spacectl module list-versions --id <module> --output json`, newest first.
# UNVERIFIED: the `state` field name and its values, as above.
SPACELIFT_MODULE = Vendor(
    name="spacelift-module",
    help="A Spacelift module version reaching a terminal state.",
    argv=("spacectl", "module", "list-versions", "--id", "{module}", "--output", "json"),
    json_path="0.state",
    terminal=("ACTIVE", "FAILED"),
    params=("module",),
)

VENDORS: tuple[Vendor, ...] = (
    GITLAB_MR,
    GITLAB_CI,
    GITLAB_TAG,
    GITHUB_PR,
    GITHUB_ACTION,
    GITHUB_TAG,
    SPACELIFT_RUN,
    SPACELIFT_MODULE,
)
