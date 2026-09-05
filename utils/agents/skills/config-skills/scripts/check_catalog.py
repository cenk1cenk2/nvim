#!/usr/bin/env -S sh -c 'exec uv run --project "$(dirname "$0")" "$0" "$@"'
"""Lint the hyprpilot skill catalog against the conventions `config-skills` states.

Every check here is mechanical - a rule whose violation a reader cannot see and
which fails silently at runtime. The judgement calls (is this description
accurate, does this body earn its length) stay with the author.

The failure this exists to catch: an unresolvable slug or reference path raises
nothing. The agent proceeds without the thing it named, exactly as if the
instruction had been followed.
"""

from __future__ import annotations

import re
from collections import defaultdict
from dataclasses import dataclass, field
from enum import StrEnum
from pathlib import Path

import click
from agentlib.cli import ExitCode, create_logger, emit

DESCRIPTION_CEILING = 380
DESCRIPTION_HARD_CEILING = 500
EMOJI = re.compile(
    "[☀-➿\U0001f000-\U0001faff️]",
)
MCP_WIRE = re.compile(r"mcp__[a-z]")
LOAD_SLUG = re.compile(r"Load `([a-z0-9][a-z0-9-]*)`")
BACKTICK_PATH = re.compile(r"`([^`]+\.md)`")


class Level(StrEnum):
    FAIL = "FAIL"
    WARN = "WARN"


@dataclass(frozen=True)
class Finding:
    level: Level
    check: str
    skill: str
    detail: str
    line: int | None = None

    def render(self) -> str:
        where = f"{self.skill}:{self.line}" if self.line else self.skill
        return f"  {self.level:<4} {self.check:<18} {where:<44} {self.detail}"


@dataclass
class Skill:
    """One catalog entry, parsed far enough to check it."""

    path: Path
    slug: str
    frontmatter: dict[str, str]
    reference_paths: list[str]
    script_paths: list[str]
    body: str
    body_offset: int
    raw: str = field(repr=False, default="")

    @property
    def directory(self) -> Path:
        return self.path.parent


def parse_skill(path: Path) -> tuple[Skill | None, list[Finding]]:
    """Split frontmatter from body. A skill that will not parse is a FAIL, not a crash."""
    slug = path.parent.name
    raw = path.read_text(encoding="utf-8", errors="replace")
    lines = raw.splitlines()
    if not lines or lines[0].strip() != "---":
        return None, [Finding(Level.FAIL, "frontmatter", slug, "does not open with ---")]
    try:
        close = next(i for i, line in enumerate(lines[1:], start=1) if line.strip() == "---")
    except StopIteration:
        return None, [Finding(Level.FAIL, "frontmatter", slug, "frontmatter block never closes")]

    fields: dict[str, str] = {}
    references: list[str] = []
    scripts: list[str] = []
    current: str | None = None
    for line in lines[1:close]:
        if line.startswith("#") or not line.strip():
            continue
        if line.startswith("  - "):
            value = line[4:].strip()
            if current == "references":
                references.append(value)
            elif current == "scripts":
                scripts.append(value)
            continue
        if ":" in line and not line.startswith(" "):
            key, _, value = line.partition(":")
            current = key.strip()
            fields[current] = value.strip()
    return (
        Skill(
            path=path,
            slug=slug,
            frontmatter=fields,
            reference_paths=references,
            script_paths=scripts,
            body="\n".join(lines[close + 1 :]),
            body_offset=close + 1,
            raw=raw,
        ),
        [],
    )


class Checks:
    """Each method is one rule. `config-skills` is cited so a failure is traceable to its source."""

    def __init__(self, root: Path, slugs: set[str]):
        self.root = root
        self.slugs = slugs

    def name_matches_directory(self, skill: Skill) -> list[Finding]:
        """config-skills Conventions: directory name must match `name`, both kebab-case."""
        name = skill.frontmatter.get("name")
        if name is None:
            return [Finding(Level.FAIL, "name", skill.slug, "no name: field")]
        if name != skill.slug:
            return [Finding(Level.FAIL, "name-dir", skill.slug, f"name: {name} does not match the directory")]
        return []

    def description(self, skill: Skill) -> list[Finding]:
        """config-skills Description Checklist, items 1-7."""
        raw = skill.frontmatter.get("description")
        if raw is None:
            return [Finding(Level.FAIL, "desc", skill.slug, "no description: field")]
        out: list[Finding] = []
        if raw.startswith(("|", ">")):
            out.append(Finding(Level.FAIL, "desc-scalar", skill.slug, "block scalar; must be a plain one-line scalar"))
            return out
        text = raw.strip("'\"")
        if not text.startswith(skill.slug):
            out.append(Finding(Level.FAIL, "desc-slug", skill.slug, "does not start with the slug (checklist 1)"))
        # `Load when` / `Load before` fill the same slot as `Use on` for a
        # manual or server-manual skill, and several skills use them.
        # Checklist 3 writes the slot as `Use on` / `Use when`, but the catalog
        # in practice also says "Use first after", "Load the entry for", "read
        # when", "load this only to". All of them are the same slot - an
        # imperative telling the reader when to reach for the skill - so the
        # check accepts any of them. What it still catches is a description
        # with no trigger clause at all, which is the failure that matters.
        if not re.search(
            r"\b(use|load|read|invoke)\b[^.]{0,40}?\b(on|when|before|after|for|to)\b|auto-invoked", text, re.IGNORECASE
        ):
            out.append(Finding(Level.FAIL, "desc-trigger", skill.slug, "no trigger phrase (checklist 3)"))
        if "Not for" not in text:
            out.append(Finding(Level.WARN, "desc-notfor", skill.slug, "no `Not for <situation>` (checklist 4)"))
        if len(text) > DESCRIPTION_CEILING:
            # The checklist says "roughly 380", so overshooting it is a warning.
            # It becomes a failure only where truncation would start eating the
            # trailing triggers, which is what the ceiling exists to protect.
            level = Level.FAIL if len(text) > DESCRIPTION_HARD_CEILING else Level.WARN
            out.append(
                Finding(level, "desc-length", skill.slug, f"{len(text)} chars, ceiling ~{DESCRIPTION_CEILING} (6)")
            )
        if "<" in text or ">" in text:
            out.append(Finding(Level.FAIL, "desc-brackets", skill.slug, "contains < or > (checklist 7)"))
        # Checklist 4: `Not for` describes a situation, never names a sibling.
        tail = text.partition("Not for")[2]
        for sibling in self.slugs - {skill.slug}:
            if sibling in tail:
                out.append(
                    Finding(
                        Level.WARN,
                        "desc-sibling",
                        skill.slug,
                        f"`Not for` names the sibling {sibling}; describe the situation instead (4)",
                    )
                )
                break
        return out

    def tier(self, skill: Skill) -> list[Finding]:
        """config-skills Conventions: `disableModelInvocation` is true or absent, never false."""
        value = skill.frontmatter.get("disableModelInvocation")
        if value == "false":
            return [Finding(Level.WARN, "tier", skill.slug, "disableModelInvocation: false; omit the key instead")]
        return []

    def declared_paths_exist(self, skill: Skill) -> list[Finding]:
        """A declared reference or script that does not exist resolves to nothing, silently."""
        out: list[Finding] = []
        for declared, kind in [(skill.reference_paths, "references"), (skill.script_paths, "scripts")]:
            for entry in declared:
                target = (skill.directory / entry).resolve()
                if not target.is_file():
                    out.append(Finding(Level.FAIL, f"{kind}-exist", skill.slug, f"declared but missing: {entry}"))
        return out

    def load_lines_resolve(self, skill: Skill) -> list[Finding]:
        """Every ``Load `X` `` names a real skill; a dangling slug is skipped in silence."""
        out: list[Finding] = []
        for offset, line in enumerate(skill.body.splitlines(), start=skill.body_offset + 1):
            for match in LOAD_SLUG.finditer(line):
                slug = match.group(1)
                if slug not in self.slugs:
                    out.append(
                        Finding(Level.FAIL, "load-resolves", skill.slug, f"Load `{slug}` names no skill", offset)
                    )
        return out

    def no_emoji(self, skill: Skill) -> list[Finding]:
        """Absolute across this catalog: no emoji or pictograph anywhere."""
        out: list[Finding] = []
        for offset, line in enumerate(skill.raw.splitlines(), start=1):
            if EMOJI.search(line):
                out.append(Finding(Level.FAIL, "emoji", skill.slug, "emoji or pictograph", offset))
        return out

    def no_mcp_wire_names(self, skill: Skill) -> list[Finding]:
        """A body writes `server__tool`; the `mcp__` wire form is the runtime's, not the catalog's."""
        out: list[Finding] = []
        fenced = False
        for offset, line in enumerate(skill.body.splitlines(), start=skill.body_offset + 1):
            if line.lstrip().startswith("```"):
                fenced = not fenced
                continue
            match = MCP_WIRE.search(line)
            if not match:
                continue
            # A wire name followed by `(` is an instruction to CALL it, which is
            # the mistake. A bare one is usually naming a connector whose wire
            # form IS its identity - `mcp__claude_ai_Slack__*` in slack-kilic -
            # and that is legitimate, so it only warns.
            called = re.search(r"mcp__[A-Za-z0-9_]+\(", line) is not None
            level = Level.FAIL if called and not fenced else Level.WARN
            out.append(Finding(level, "mcp-prefix", skill.slug, "mcp__ wire name in the body", offset))
        return out

    def no_h1(self, skill: Skill) -> list[Finding]:
        """config-skills Body structure: a SKILL.md body opens with content, not an H1."""
        for offset, line in enumerate(skill.body.splitlines(), start=skill.body_offset + 1):
            if line.startswith("# "):
                return [Finding(Level.WARN, "h1", skill.slug, "H1 heading in the body", offset)]
        return []


def collect(root: Path) -> tuple[list[Skill], list[Finding]]:
    skills: list[Skill] = []
    findings: list[Finding] = []
    for path in sorted(root.glob("*/SKILL.md")):
        skill, problems = parse_skill(path)
        findings.extend(problems)
        if skill is not None:
            skills.append(skill)
    return skills, findings


def orphan_references(root: Path, skills: list[Skill]) -> list[Finding]:
    """A shared reference nothing declares is dead weight nobody will notice."""
    declared: set[Path] = set()
    for skill in skills:
        for entry in skill.reference_paths:
            declared.add((skill.directory / entry).resolve())
    out: list[Finding] = []
    shared = root / "references"
    if not shared.is_dir():
        return out
    for path in sorted(shared.rglob("*.md")):
        if path.resolve() not in declared:
            out.append(Finding(Level.WARN, "orphan-ref", str(path.relative_to(root)), "declared by no skill"))
    return out


@click.command(context_settings={"help_option_names": ["-h", "--help"]})
@click.argument("root", required=False)
@click.option("--warnings/--no-warnings", default=True, help="Show warnings as well as failures.")
@click.option("-v", "--verbose", is_flag=True, help="Debug logging on stderr.")
def cli(root: str | None, warnings: bool, verbose: bool) -> None:
    """Lint the skill catalog at ROOT (default: this script's own catalog root)."""
    create_logger(verbose, "check-catalog")
    catalog = Path(root).expanduser().resolve() if root else Path(__file__).resolve().parents[2]
    if not catalog.is_dir():
        emit(f"error: not a directory: {catalog}")
        raise SystemExit(ExitCode.USAGE)

    skills, findings = collect(catalog)
    # Findings with no parseable skills means every SKILL.md is broken, which is
    # a lint result to report - not an empty catalog to complain about.
    if not skills and not findings:
        emit(f"error: no */SKILL.md found under {catalog}")
        raise SystemExit(ExitCode.USAGE)

    slugs = {skill.slug for skill in skills}
    checks = Checks(catalog, slugs)
    methods = [
        getattr(checks, name) for name in dir(checks) if not name.startswith("_") and callable(getattr(checks, name))
    ]
    for skill in skills:
        for method in methods:
            findings.extend(method(skill))
    findings.extend(orphan_references(catalog, skills))

    by_skill: dict[str, list[Finding]] = defaultdict(list)
    for finding in findings:
        if finding.level is Level.WARN and not warnings:
            continue
        by_skill[finding.skill].append(finding)

    for skill in sorted(by_skill):
        emit(skill)
        for finding in by_skill[skill]:
            emit(finding.render())

    fails = sum(1 for f in findings if f.level is Level.FAIL)
    warns = sum(1 for f in findings if f.level is Level.WARN)
    emit("")
    emit(f"{len(skills)} skill(s) checked: {fails} failure(s), {warns} warning(s)")
    raise SystemExit(ExitCode.CEILING if fails else ExitCode.MET)


if __name__ == "__main__":
    cli.main(standalone_mode=False)
