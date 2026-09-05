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

# A lint run that found failures. Deliberately not `ExitCode.CEILING`, which
# means a bounded wait expired in the watcher scripts.
FINDINGS_FOUND = 1

DESCRIPTION_CEILING = 380
# "Roughly 380" allows a tolerance band, not an open one. 420 is ~10% over;
# beyond that a description is long enough for truncation to start eating the
# trailing triggers, which is the whole reason the ceiling exists.
DESCRIPTION_HARD_CEILING = 420

# Pictographs, dingbats, arrows and stars. The narrow BMP ranges matter as much
# as the astral ones: the absolute rule names "star" explicitly, and U+2B50 sits
# outside the emoji planes.
EMOJI = re.compile("[\u2300-\u23ff\u2600-\u27bf\u2b00-\u2bff\ufe0f\U0001f000-\U0001faff]")

# The closed set of trigger phrasings the catalog uses. Enumerated, not a loose
# pattern: `Use on`, `Use when`, `Use first after`, `Load before`, `Load the
# entry for`, `read when`, `load this only to`, and the auto-invoke form.
TRIGGER = re.compile(
    r"\b(?:"
    r"Use on|Use when|Use first|Use it when|Use this when"
    r"|Load when|Load before|Load it|Load the entry|load this"
    r"|[Rr]ead when|Invoke when|Invoked when"
    r"|Auto-invoked"
    r")\b",
)

MCP_WIRE = re.compile(r"mcp__[A-Za-z]")
# A wire name may legitimately appear as a FAMILY glob naming a connector, or
# inside a ToolSearch `select:` string, which is literal data. Everything else
# is an instruction to call it, which the short `server__tool` form owns.
MCP_WIRE_ALLOWED = re.compile(r"mcp__[A-Za-z0-9_]*__\*|select:[^`\s]*mcp__")

# The catalog writes loads three ways; all three must resolve.
LOAD_SLUG = re.compile(r"\b[Ll]oad(?: the)? `([a-z0-9][a-z0-9-]*)`")
KEBAB = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")

# Keys Claude Code understands but this catalog does not use; `config-skills`
# says plainly not to add them, and a stray one is invisible.
FOREIGN_KEYS = ("when_to_use", "allowed-tools", "allowed_tools", "hooks", "model")

# Frontmatter lines the hand parser understands. Anything else is reported
# rather than skipped: a silently dropped `references:` item means the
# existence check quietly stops checking.
RECOGNISED_LINE = re.compile(r"^(?:\s*- .+|[A-Za-z_][A-Za-z0-9_-]*:.*|\s*#.*|\s*)$")


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
    unreadable: list[Finding] = []
    current: str | None = None
    for offset, line in enumerate(lines[1:close], start=2):
        if not RECOGNISED_LINE.match(line):
            unreadable.append(
                Finding(Level.FAIL, "frontmatter", slug, f"unparseable frontmatter line: {line.strip()!r}", offset)
            )
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
        unreadable,
    )


class Checks:
    """Each method is one rule. `config-skills` is cited so a failure is traceable to its source."""

    RULES = (
        "name_matches_directory",
        "kebab_case",
        "description",
        "no_foreign_frontmatter",
        "declared_paths_exist",
        "load_lines_resolve",
        "no_emoji",
        "no_mcp_wire_names",
        "no_h1",
    )

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
        # Checklist 3 writes the slot as `Use on` / `Use when`. The catalog also
        # uses a small, closed set of variants; they are enumerated rather than
        # matched loosely, because a loose pattern accepts prose that carries no
        # trigger at all ("Load-balancer tuning for the ingress tier").
        if not TRIGGER.search(text):
            out.append(Finding(Level.FAIL, "desc-trigger", skill.slug, "no trigger phrase (checklist 3)"))
        # Checklist 4 is part of "one shape, every skill" and its presence is
        # purely mechanical, so it fails rather than warns.
        if "Not for" not in text:
            out.append(Finding(Level.FAIL, "desc-notfor", skill.slug, "no `Not for <situation>` (checklist 4)"))
        if len(text) > DESCRIPTION_CEILING:
            # "Roughly 380" is a tolerance band, not an open one.
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

    def kebab_case(self, skill: Skill) -> list[Finding]:
        """config-skills Conventions: directory and `name` are both kebab-case."""
        if not KEBAB.match(skill.slug):
            return [Finding(Level.FAIL, "kebab", skill.slug, "directory name is not kebab-case")]
        return []

    def no_foreign_frontmatter(self, skill: Skill) -> list[Finding]:
        """config-skills: the Claude Code keys this catalog does not use are not added."""
        return [
            Finding(Level.FAIL, "frontmatter-key", skill.slug, f"{key} is not a key this catalog uses")
            for key in FOREIGN_KEYS
            if key in skill.frontmatter
        ]

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
            if not MCP_WIRE.search(line):
                continue
            # Two shapes are literal data rather than an instruction: a family
            # glob naming a connector (`mcp__claude_ai_Slack__*`), and a name
            # inside a ToolSearch `select:` string. Everything else is a call the
            # short `server__tool` form owns, and a fence does not excuse it -
            # a fenced call instruction is still an instruction.
            if MCP_WIRE_ALLOWED.search(line):
                continue
            out.append(Finding(Level.FAIL, "mcp-prefix", skill.slug, "mcp__ wire name; use `server__tool`", offset))
        return out

    def no_h1(self, skill: Skill) -> list[Finding]:
        """config-skills Body structure: a SKILL.md body opens with content, not an H1.

        Fence-aware: a `# ...` inside a code block is a shell comment, and
        counting those trains a reader to ignore the column.
        """
        fenced = False
        for offset, line in enumerate(skill.body.splitlines(), start=skill.body_offset + 1):
            if line.lstrip().startswith("```"):
                fenced = not fenced
                continue
            if not fenced and line.startswith("# "):
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
    # Named explicitly: sweeping `dir()` would turn any future public helper on
    # Checks into a silent rule.
    methods = [getattr(checks, name) for name in Checks.RULES]
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
    # Not CEILING: that means 'a bounded wait expired' for the watcher scripts.
    # Here a non-zero exit means the catalog has failures to fix.
    raise SystemExit(FINDINGS_FOUND if fails else ExitCode.MET)


def main() -> None:
    try:
        cli.main(standalone_mode=False)
    except click.ClickException as err:
        err.show()
        raise SystemExit(ExitCode.USAGE) from err
    except click.Abort:
        raise SystemExit(130) from None


if __name__ == "__main__":
    main()
