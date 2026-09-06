#!/usr/bin/env -S sh -c 'exec uv run --project "$(dirname "$0")" "$0" "$@"'
"""Report what a repository builds with, what CI enforces, and how it releases.

Three questions an agent otherwise answers by hand every time, each mechanical
and each with a silent failure mode:

  runner    the task runner and the commands it defines
  ci        which of those commands the pipeline actually runs, and in what order
  release   whether the repo releases from commits, and by what

The load-bearing one is `ci`. Discovery alone says which commands EXIST; only the
pipeline says which of them gate a merge. A green task runner is not a green
pipeline, and acting on the first without the second is the mistake this exists
to remove.
"""

from __future__ import annotations

import json
import re
import tomllib
from dataclasses import asdict, dataclass, field
from enum import StrEnum
from pathlib import Path

import click
import yaml
from agentlib.cli import ExitCode, create_logger, emit


class Runner(StrEnum):
    """Task runners, in the order `project-tooling` checks for them."""

    TASK = "task"
    MAKE = "make"
    NPM = "npm"
    CARGO = "cargo"
    GO = "go"
    PYTHON = "python"
    GRADLE = "gradle"
    MAVEN = "maven"


class Release(StrEnum):
    """Release automation, which decides whether a commit type sets a version."""

    RELEASE_PLEASE = "release-please"
    SEMANTIC_RELEASE = "semantic-release"
    CHANGESETS = "changesets"
    COMMITLINT = "commitlint"
    NONE = "none"


# Marker file -> runner. First match wins, matching the discovery order.
RUNNER_MARKERS: tuple[tuple[Runner, tuple[str, ...]], ...] = (
    (Runner.TASK, ("Taskfile.yml", "Taskfile.yaml")),
    (Runner.MAKE, ("Makefile",)),
    (Runner.NPM, ("package.json",)),
    (Runner.CARGO, ("Cargo.toml",)),
    (Runner.GO, ("go.mod",)),
    (Runner.PYTHON, ("pyproject.toml", "setup.py", "setup.cfg")),
    (Runner.GRADLE, ("build.gradle", "build.gradle.kts")),
    (Runner.MAVEN, ("pom.xml",)),
)

RELEASE_MARKERS: tuple[tuple[Release, tuple[str, ...]], ...] = (
    (Release.RELEASE_PLEASE, ("release-please-config.json", ".release-please-manifest.json")),
    (
        Release.SEMANTIC_RELEASE,
        (".releaserc", ".releaserc.json", ".releaserc.yml", ".releaserc.yaml", "release.config.js"),
    ),
    (Release.CHANGESETS, (".changeset/config.json",)),
    (Release.COMMITLINT, ("commitlint.config.js", ".commitlintrc", ".commitlintrc.json")),
)

CI_FILES = (".gitlab-ci.yml", ".github/workflows", "Jenkinsfile", ".circleci/config.yml")

# A shell line that looks like it runs a quality gate rather than deploying.
GATE_WORDS = re.compile(r"\b(lint|test|build|fmt|format|check|typecheck|vet|clippy|audit)\b", re.IGNORECASE)


@dataclass
class Facts:
    root: str
    runner: str | None = None
    runner_file: str | None = None
    commands: list[str] = field(default_factory=list)
    ci_files: list[str] = field(default_factory=list)
    ci_commands: list[str] = field(default_factory=list)
    release: str = Release.NONE
    release_file: str | None = None
    notes: list[str] = field(default_factory=list)


def detect_runner(root: Path, facts: Facts) -> None:
    for runner, markers in RUNNER_MARKERS:
        for marker in markers:
            if (root / marker).exists():
                facts.runner = runner
                facts.runner_file = marker
                facts.commands = read_commands(root / marker, runner)
                return


def read_commands(path: Path, runner: Runner) -> list[str]:
    """Read the runner's own command names. Never guess: an invented target fails at run time."""
    try:
        if runner is Runner.TASK:
            data = yaml.safe_load(path.read_text()) or {}
            return sorted((data.get("tasks") or {}).keys())
        if runner is Runner.NPM:
            data = json.loads(path.read_text())
            return sorted((data.get("scripts") or {}).keys())
        if runner is Runner.PYTHON and path.name == "pyproject.toml":
            data = tomllib.loads(path.read_text())
            scripts = data.get("project", {}).get("scripts", {})
            return sorted(scripts.keys())
        if runner is Runner.MAKE:
            # Target lines only; a target is `name:` at column zero.
            return sorted(
                {
                    line.split(":", 1)[0].strip()
                    for line in path.read_text().splitlines()
                    if re.match(r"^[A-Za-z0-9_.-]+\s*:", line) and not line.startswith("\t")
                }
            )
    except (OSError, ValueError, yaml.YAMLError, tomllib.TOMLDecodeError):
        return []
    return []


def detect_ci(root: Path, facts: Facts) -> None:
    """Find the pipeline definitions and the gate-shaped commands they run."""
    for entry in CI_FILES:
        target = root / entry
        if not target.exists():
            continue
        facts.ci_files.append(entry)
        files = sorted(target.rglob("*.y*ml")) if target.is_dir() else [target]
        for path in files:
            facts.ci_commands.extend(ci_commands(path))
    # Preserve pipeline order but drop repeats.
    facts.ci_commands = list(dict.fromkeys(facts.ci_commands))


def ci_commands(path: Path) -> list[str]:
    """Pull the run/script lines out of a pipeline file, keeping only gate-shaped ones."""
    try:
        text = path.read_text()
    except OSError:
        return []
    found: list[str] = []
    try:
        data = yaml.safe_load(text)
    except yaml.YAMLError:
        data = None
    for line in _shell_lines(data) if data is not None else text.splitlines():
        line = line.strip()
        if line and GATE_WORDS.search(line):
            found.append(line)
    return found


def _shell_lines(node: object) -> list[str]:
    """Every `script:` / `run:` string anywhere in a parsed pipeline."""
    out: list[str] = []
    if isinstance(node, dict):
        for key, value in node.items():
            if key in ("script", "run", "before_script", "after_script", "cmds"):
                if isinstance(value, str):
                    out.extend(value.splitlines())
                elif isinstance(value, list):
                    out.extend(item for item in value if isinstance(item, str))
            out.extend(_shell_lines(value))
    elif isinstance(node, list):
        for item in node:
            out.extend(_shell_lines(item))
    return out


def detect_release(root: Path, facts: Facts) -> None:
    for release, markers in RELEASE_MARKERS:
        for marker in markers:
            if (root / marker).exists():
                facts.release = release
                facts.release_file = marker
                return
    # semantic-release is often configured inside package.json rather than a file.
    package = root / "package.json"
    if package.exists():
        try:
            data = json.loads(package.read_text())
        except (OSError, ValueError):
            return
        if "release" in data:
            facts.release = Release.SEMANTIC_RELEASE
            facts.release_file = "package.json"
        elif "semantic-release" in json.dumps(data.get("devDependencies", {})):
            facts.release = Release.SEMANTIC_RELEASE
            facts.release_file = "package.json (devDependencies)"


def gather(root: Path) -> Facts:
    facts = Facts(root=str(root))
    detect_runner(root, facts)
    detect_ci(root, facts)
    detect_release(root, facts)
    if facts.runner is None:
        facts.notes.append("no task runner found; do not invent commands, ask instead")
    if not facts.ci_files:
        facts.notes.append("no CI config found; nothing establishes which commands gate a merge")
    elif not facts.ci_commands:
        facts.notes.append("CI config found but no gate-shaped commands parsed; read it by hand")
    if facts.release in (Release.RELEASE_PLEASE, Release.SEMANTIC_RELEASE, Release.COMMITLINT):
        facts.notes.append(f"{facts.release} releases from commits: the commit type sets the version bump")
    if facts.release is Release.CHANGESETS:
        facts.notes.append("changesets: a user-facing change needs a .changeset/*.md before merge")
    return facts


def render(facts: Facts) -> None:
    emit(f"root:     {facts.root}")
    emit(f"runner:   {facts.runner or 'none'}" + (f"  ({facts.runner_file})" if facts.runner_file else ""))
    if facts.commands:
        emit(f"commands: {', '.join(facts.commands)}")
    emit(f"ci:       {', '.join(facts.ci_files) or 'none'}")
    for command in facts.ci_commands:
        emit(f"  ci runs: {command}")
    emit(f"release:  {facts.release}" + (f"  ({facts.release_file})" if facts.release_file else ""))
    for note in facts.notes:
        emit(f"note:     {note}")


@click.command(context_settings={"help_option_names": ["-h", "--help"]})
@click.argument("root", required=False, default=".")
@click.option("--json", "as_json", is_flag=True, help="Emit the facts as JSON.")
@click.option("-v", "--verbose", is_flag=True, help="Debug logging on stderr.")
def cli(root: str, as_json: bool, verbose: bool) -> None:
    """Report the tooling, CI gates and release automation of the repository at ROOT."""
    create_logger(verbose, "project-facts")
    target = Path(root).expanduser().resolve()
    if not target.is_dir():
        emit(f"error: not a directory: {target}")
        raise SystemExit(ExitCode.USAGE)

    facts = gather(target)
    if as_json:
        emit(json.dumps(asdict(facts), indent=2, sort_keys=True))
    else:
        render(facts)
    raise SystemExit(ExitCode.MET)


if __name__ == "__main__":
    cli.main(standalone_mode=False)
