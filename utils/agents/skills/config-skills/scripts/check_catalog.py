#!/usr/bin/env -S sh -c 'd="$(dirname "$0")"; uv sync -q --project "$d" && exec "$d/.venv/bin/python" "$0" "$@"'
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

# Pictographs, dingbats and stars. The narrow BMP ranges matter as much as the
# astral ones: the absolute rule names "star" explicitly, and U+2B50 sits
# outside the emoji planes. The U+2190 arrow block is ARROW's.
EMOJI = re.compile("[\u2300-\u23ff\u2600-\u27bf\u2b00-\u2bff\ufe0f\U0001f000-\U0001faff]")

# Arrows in prose: the glyph block and the ASCII spellings. Prose says the
# relation in words; a code fence or span holding one is literal data.
ARROW = re.compile("[\u2190-\u21ff]|->|=>")
CODE_SPAN = re.compile(r"`[^`]*`")
HTML_COMMENT = re.compile(r"<!--.*?-->")

# An issue or MR id as a reader would see it: `K-219`, `INFFND-12`, `!262`, `#41`.
BARE_ID = re.compile(r"(?<![\w/.-])(?:[A-Z][A-Z0-9]*-\d+|![0-9]+|#[0-9]+)\b")
MARKDOWN_LINK = re.compile(r"\[[^\]]*\]\([^)]*\)")
# Fence languages that hold code or config, where a bare id is machine-read.
CODE_FENCE_LANGUAGES = {"sh", "bash", "zsh", "shell", "console", "json", "yaml", "yml", "toml", "python", "py", "lua"}

# A present-then-approve flow, which only a skill declaring `present-first` runs.
PRESENT_FIRST_FLOW = re.compile(
    r"\b(?:after (?:explicit |user )?approval|wait (?:for|on) (?:the )?(?:user'?s? |explicit )?approval"
    r"|present-and-approve|present(?:ed)? (?:the )?(?:draft|proposed changes))\b",
    re.IGNORECASE,
)
POSTURE_LINE = re.compile(r"^Posture: `present-first`\.", re.MULTILINE)
PRESENT_FIRST = "present-first"

# The Invocation Tiers assignment bullets in `config-skills`, and the tier each one names.
TIER_BULLET = re.compile(r"^- \*\*(Manual|Model-invocable|Auto-invoke)\*\* \u2014")

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
MCP_WIRE_ALLOWED = re.compile(r"mcp__(?:[A-Za-z0-9_]|<[A-Za-z]+>)*__\*|select:[^`\s]*mcp__")

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


# A backticked kebab name in prose: the form a body cites a reference by.
CITED_NAME = re.compile(r"`([a-z0-9][a-z0-9-]*)`")

# Words that narrate this system's own past, per `current-state-only`. A hit is
# a WARN: the same words also describe live external things.
HISTORY = re.compile(r"\b(?:formerly|used to|no longer|previously|legacy|migrated|renamed)\b", re.IGNORECASE)


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

    @property
    def name(self) -> str:
        """The slug's last segment: a nested skill's slug is its path, its name is its directory."""
        return self.path.parent.name


def parse_skill(path: Path, root: Path) -> tuple[Skill | None, list[Finding]]:
    """Split frontmatter from body. A skill that will not parse is a FAIL, not a crash."""
    slug = path.parent.relative_to(root).as_posix()
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
        stripped = line.lstrip()
        if stripped.startswith("- "):
            value = stripped[2:].strip()
            if current == "references":
                references.append(value)
            elif current == "scripts":
                scripts.append(value)
            continue
        if ":" in line and not line.startswith(" "):
            key, _, value = line.partition(":")
            current = key.strip()
            value = value.strip()
            if current in ("references", "scripts") and value.startswith("["):
                unreadable.append(
                    Finding(
                        Level.FAIL,
                        "frontmatter",
                        slug,
                        f"{current} is a flow sequence; write it as a block list so each entry is checked",
                        offset,
                    )
                )
            fields[current] = value
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


def fenced_lines(text: str, start: int) -> list[tuple[int, str, str | None]]:
    """Each line with its number and, inside a code fence, the fence's language ('' when untagged)."""
    out: list[tuple[int, str, str | None]] = []
    fence: str | None = None
    for offset, line in enumerate(text.splitlines(), start=start):
        stripped = line.lstrip()
        if stripped.startswith("```"):
            fence = stripped[3:].strip().lower() if fence is None else None
            continue
        out.append((offset, line, fence))
    return out


def arrow_findings(label: str, text: str, start: int) -> list[Finding]:
    """No arrow glyphs in prose; a fence or a code span holding one is literal data."""
    out: list[Finding] = []
    for offset, line, fence in fenced_lines(text, start):
        if fence is not None:
            continue
        prose = CODE_SPAN.sub("", HTML_COMMENT.sub("", line))
        match = ARROW.search(prose)
        if match:
            out.append(Finding(Level.WARN, "arrow", label, f"arrow in prose: {match.group(0)!r}", offset))
    return out


def bare_id_findings(label: str, text: str, start: int) -> list[Finding]:
    """AGENTS.md §VI: a template the agent shows the user links every id with its title."""
    out: list[Finding] = []
    for offset, line, fence in fenced_lines(text, start):
        if fence is None or fence in CODE_FENCE_LANGUAGES:
            continue
        match = BARE_ID.search(CODE_SPAN.sub("", MARKDOWN_LINK.sub("", line)))
        if match:
            out.append(Finding(Level.WARN, "bare-id", label, f"bare id in a template: {match.group(0)!r}", offset))
    return out


def emoji_findings(label: str, text: str, start: int, *, fences_are_data: bool = False) -> list[Finding]:
    """With `fences_are_data`, a fence holds a literal a file format requires, such as a template header."""
    return [
        Finding(Level.FAIL, "emoji", label, "emoji or pictograph", offset)
        for offset, line, fence in fenced_lines(text, start)
        if EMOJI.search(line) and not (fences_are_data and fence is not None)
    ]


def history_findings(label: str, text: str, start: int) -> list[Finding]:
    return [
        Finding(Level.WARN, "history", label, f"history wording: {match.group(0)!r}", offset)
        for offset, line in enumerate(text.splitlines(), start=start)
        for match in [HISTORY.search(line)]
        if match
    ]


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
        "no_arrows",
        "no_bare_ids",
        "no_mcp_wire_names",
        "no_h1",
        "cited_references_declared",
        "declared_references_cited",
        "no_history",
        "posture_matches_declaration",
        "present_first_flow_declared",
        "auto_invoke_is_model_invocable",
    )

    def __init__(self, root: Path, slugs: set[str]):
        self.root = root
        self.slugs = slugs
        # Every reference name in the tree, shared or skill-local, by file stem.
        self.reference_names = {path.stem for path in root.glob("**/references/**/*.md")}

    @staticmethod
    def declared_names(skill: Skill) -> dict[str, Path]:
        return {Path(entry).stem: (skill.directory / entry).resolve() for entry in skill.reference_paths}

    def cited_references_declared(self, skill: Skill) -> list[Finding]:
        """config-skills: a reference name resolves only through a manifest the reader holds.

        A WARN, not a FAIL: `config-*` bodies name references as examples, and a
        body may reach one through a skill it loads.
        """
        declared = self.declared_names(skill)
        out: list[Finding] = []
        for name in sorted(set(CITED_NAME.findall(skill.body))):
            if name in self.reference_names and name not in declared and name not in self.slugs:
                out.append(Finding(Level.WARN, "ref-undeclared", skill.slug, f"cites `{name}` without declaring it"))
        return out

    def declared_references_cited(self, skill: Skill) -> list[Finding]:
        """A declaration nothing uses is a manifest row the reader pays for with no instruction to fetch it.

        Counts as used: named in the body, named by another declared reference
        (transitive citation), or a member of a `<consumer>-harness-<provider>`
        family the body names with the placeholder.
        """
        declared = self.declared_names(skill)
        texts = [skill.body]
        for path in declared.values():
            if path.is_file():
                texts.append(path.read_text(encoding="utf-8", errors="replace"))
        corpus = "\n".join(texts)
        out: list[Finding] = []
        for name in sorted(declared):
            family, _, _ = name.partition("-harness-")
            used = f"`{name}`" in corpus or ("-harness-" in name and f"{family}-harness-<provider>" in corpus)
            if not used:
                out.append(Finding(Level.WARN, "ref-unused", skill.slug, f"declares `{name}` but nothing cites it"))
        return out

    def no_history(self, skill: Skill) -> list[Finding]:
        """current-state-only: this system's own past is deleted, not annotated."""
        return history_findings(skill.slug, skill.body, skill.body_offset + 1)

    def no_arrows(self, skill: Skill) -> list[Finding]:
        return arrow_findings(skill.slug, skill.body, skill.body_offset + 1)

    def no_bare_ids(self, skill: Skill) -> list[Finding]:
        return bare_id_findings(skill.slug, skill.body, skill.body_offset + 1)

    @staticmethod
    def declares_present_first(skill: Skill) -> bool:
        return any(Path(entry).stem == PRESENT_FIRST for entry in skill.reference_paths)

    def posture_matches_declaration(self, skill: Skill) -> list[Finding]:
        """config-skills Posture: a declaring skill opens with the line, and no other skill carries it."""
        if skill.slug == PRESENT_FIRST:
            return []
        line = POSTURE_LINE.search(skill.body)
        declared = self.declares_present_first(skill)
        if line and not declared:
            offset = skill.body_offset + 1 + skill.body.count("\n", 0, line.start())
            return [
                Finding(Level.FAIL, "posture", skill.slug, "Posture line without declaring `present-first`", offset)
            ]
        if declared and not line:
            return [Finding(Level.WARN, "posture", skill.slug, "declares `present-first` without the Posture line")]
        return []

    def present_first_flow_declared(self, skill: Skill) -> list[Finding]:
        """Only a skill declaring `present-first` presents before writing; every other one acts, then reports."""
        if self.declares_present_first(skill):
            return []
        return [
            Finding(Level.WARN, "present-flow", skill.slug, f"present-then-approve wording: {match.group(0)!r}", offset)
            for offset, line, fence in fenced_lines(skill.body, skill.body_offset + 1)
            if fence is None
            for match in [PRESENT_FIRST_FLOW.search(line)]
            if match
        ]

    def auto_invoke_is_model_invocable(self, skill: Skill) -> list[Finding]:
        """config-skills Invocation Tiers: auto-invoke is a model-invocable sub-case."""
        if is_manual(skill) and "Auto-invoked" in skill.frontmatter.get("description", ""):
            return [Finding(Level.FAIL, "tier-auto", skill.slug, "Auto-invoked description on a Manual skill")]
        return []

    def name_matches_directory(self, skill: Skill) -> list[Finding]:
        """config-skills Conventions: directory name must match `name`, both kebab-case."""
        name = skill.frontmatter.get("name")
        if name is None:
            return [Finding(Level.FAIL, "name", skill.slug, "no name: field")]
        if name != skill.name:
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
        """config-skills Conventions: directory and `name` are both kebab-case, at every depth."""
        if not all(KEBAB.match(segment) for segment in skill.slug.split("/")):
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
        return emoji_findings(skill.slug, skill.raw, 1)

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
    # Any depth, like the skills server: a directory holding a SKILL.md is a
    # skill wherever it sits. Hidden trees (a script's .venv) are never skills,
    # and a SKILL.md at the root would be a skill with no name.
    for path in sorted(root.rglob("SKILL.md")):
        relative = path.relative_to(root)
        if len(relative.parts) < 2 or any(part.startswith(".") for part in relative.parts):
            continue
        skill, problems = parse_skill(path, root)
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


def is_manual(skill: Skill) -> bool:
    return skill.frontmatter.get("disableModelInvocation", "").strip("'\"").lower() == "true"


def tier_examples(skills: list[Skill]) -> list[Finding]:
    """config-skills Invocation Tiers: every slug named as a tier's example carries that tier."""
    by_slug = {skill.slug: skill for skill in skills}
    out: list[Finding] = []
    for skill in skills:
        for offset, line, fence in fenced_lines(skill.body, skill.body_offset + 1):
            match = TIER_BULLET.match(line) if fence is None else None
            if not match:
                continue
            tier = match.group(1)
            for slug in CITED_NAME.findall(line):
                example = by_slug.get(slug)
                if example is None:
                    continue
                if (tier == "Manual") != is_manual(example):
                    actual = "Manual" if is_manual(example) else "Model-invocable"
                    out.append(
                        Finding(Level.FAIL, "tier-example", skill.slug, f"{tier} example `{slug}` is {actual}", offset)
                    )
                elif tier == "Auto-invoke" and "Auto-invoked" not in example.frontmatter.get("description", ""):
                    out.append(
                        Finding(
                            Level.WARN,
                            "tier-example",
                            skill.slug,
                            f"Auto-invoke example `{slug}` has no Auto-invoked description",
                            offset,
                        )
                    )
    return out


def guidance_files(root: Path, guidance: tuple[str, ...]) -> list[Path]:
    """The shared references, plus the central guidance: named, or `AGENTS.md` beside the catalog."""
    files = sorted((root / "references").rglob("*.md")) if (root / "references").is_dir() else []
    named = [Path(entry).expanduser().resolve() for entry in guidance]
    if not named and (root.parent / "AGENTS.md").is_file():
        named = [root.parent / "AGENTS.md"]
    return files + named


def lint_guidance(root: Path, paths: list[Path]) -> list[Finding]:
    """Files no manifest parses, held to the catalog's prose rules: emoji, arrows, history."""
    out: list[Finding] = []
    for path in paths:
        label = str(path.relative_to(root)) if path.is_relative_to(root) else str(path)
        text = path.read_text(encoding="utf-8", errors="replace")
        out.extend(emoji_findings(label, text, 1, fences_are_data=True))
        out.extend(arrow_findings(label, text, 1))
        out.extend(history_findings(label, text, 1))
    return out


@click.command(context_settings={"help_option_names": ["-h", "--help"]})
@click.argument("root", required=False)
@click.option("--warnings/--no-warnings", default=True, help="Show warnings as well as failures.")
@click.option(
    "--guidance",
    multiple=True,
    help="Central guidance file to lint for emoji, arrows and history (default: AGENTS.md beside ROOT).",
)
@click.option("-v", "--verbose", is_flag=True, help="Debug logging on stderr.")
def cli(root: str | None, warnings: bool, guidance: tuple[str, ...], verbose: bool) -> None:
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
        emit(f"error: no SKILL.md found under {catalog}")
        raise SystemExit(ExitCode.USAGE)
    missing = [entry for entry in guidance if not Path(entry).expanduser().is_file()]
    if missing:
        emit(f"error: no such guidance file: {missing[0]}")
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
    findings.extend(tier_examples(skills))
    findings.extend(lint_guidance(catalog, guidance_files(catalog, guidance)))

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
