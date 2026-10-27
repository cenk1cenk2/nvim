#!/usr/bin/env -S sh -c 'd="$(dirname "$0")"; uv sync -q --project "$d" && exec "$d/.venv/bin/python" "$0" "$@"'
"""Mechanical checks and edits on Grafana dashboard JSON.

\b
subcommands:
  lint      grid overlaps, duplicate ids, range-mode tables, repeated rows, stray thresholds
  queries   every target expression as JSON lines, variables substituted, for a live check
  reflow    re-stack gridPos from panel order, keeping each panel's w and h
  retitle   rename link and data-link titles exactly, refusing a mapping that matches nothing

\b
exit codes:
  0  clean, or the edit was written
  1  lint findings, or a retitle mapping matched nothing
  2  usage error, nothing was read or written
  3  a file is not readable dashboard JSON

Files are rewritten at indent 2, keeping each file's own non-ASCII escaping, so
a run churns only the lines it changed.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path

import click
from agentlib.cli import ExitCode, ScriptError, emit

FINDINGS = 1
GRID_WIDTH = 24
PERCENT_UNITS = {"percent", "percentunit"}
DEFAULT_SUBSTITUTIONS = {
    "$__rate_interval": "5m",
    "$__interval": "1m",
    "$__range": "1h",
}
CONTEXT_SETTINGS = {"help_option_names": ["-h", "--help"], "max_content_width": 100}


@dataclass
class Dashboard:
    path: Path
    data: dict
    ascii: bool

    @classmethod
    def read(cls, path: Path) -> Dashboard:
        try:
            text = path.read_text()
            data = json.loads(text)
        except (OSError, json.JSONDecodeError) as err:
            raise ScriptError(f"{path}: {err}", ExitCode.CANNOT_RUN) from err
        if not isinstance(data, dict) or not isinstance(data.get("panels"), list):
            raise ScriptError(f"{path}: no top-level panels list", ExitCode.CANNOT_RUN)
        return cls(path, data, json.dumps(data, indent=2, ensure_ascii=True) + "\n" == text)

    def write(self) -> None:
        self.path.write_text(json.dumps(self.data, indent=2, ensure_ascii=self.ascii) + "\n")

    def panels(self) -> list[dict]:
        out = []
        for panel in self.data["panels"]:
            out.append(panel)
            out.extend(panel.get("panels") or [])
        return out

    def variables(self) -> dict[str, dict]:
        return {v["name"]: v for v in self.data.get("templating", {}).get("list", []) if "name" in v}


def load(paths: tuple[Path, ...]) -> list[Dashboard]:
    if not paths:
        raise ScriptError("no dashboard files given")
    return [Dashboard.read(path) for path in paths]


def overlaps(dashboard: Dashboard) -> list[str]:
    taken: dict[tuple[int, int], str] = {}
    found = []
    for panel in dashboard.data["panels"]:
        grid = panel.get("gridPos") or {}
        title = panel.get("title", "?")
        if grid.get("x", 0) + grid.get("w", 0) > GRID_WIDTH:
            found.append(f"panel {panel.get('id')} {title!r} overflows the {GRID_WIDTH}-column grid")
        hit = None
        for x in range(grid.get("x", 0), grid.get("x", 0) + grid.get("w", 0)):
            for y in range(grid.get("y", 0), grid.get("y", 0) + grid.get("h", 0)):
                hit = hit or taken.get((x, y))
                taken[(x, y)] = title
        if hit:
            found.append(f"panel {panel.get('id')} {title!r} overlaps {hit!r}")
    return found


def lint_dashboard(dashboard: Dashboard) -> list[str]:
    findings = overlaps(dashboard)
    seen: dict[int, str] = {}
    for panel in dashboard.panels():
        pid, title, kind = panel.get("id"), panel.get("title", "?"), panel.get("type")
        if pid in seen:
            findings.append(f"panel id {pid} is used by {seen[pid]!r} and {title!r}")
        seen[pid] = title
        if kind == "row" and panel.get("repeat"):
            findings.append(f"row {title!r} repeats per ${panel['repeat']}; stack hosts on shared panels instead")
        if kind == "table":
            for target in panel.get("targets", []):
                if target.get("format") == "table" and not target.get("instant"):
                    findings.append(f"table {title!r} target {target.get('refId')} is a range query; set instant")
        if kind == "stat":
            defaults = panel.get("fieldConfig", {}).get("defaults", {})
            steps = defaults.get("thresholds", {}).get("steps", [])
            if (
                len(steps) > 1
                and defaults.get("unit") not in PERCENT_UNITS
                and steps[1].get("value") in (0.8, 0.85, 0.9)
            ):
                findings.append(f"stat {title!r} carries percent thresholds on unit {defaults.get('unit')!r}")
    multi = [name for name, v in dashboard.variables().items() if v.get("multi")]
    text = json.dumps(dashboard.data)
    for name in multi:
        if re.search(rf"var-{re.escape(name)}=\$\{{?{re.escape(name)}\}}?", text):
            findings.append(f"link passes multi-select ${name} as var-{name}=${{{name}}}; use ${{{name}:queryparam}}")
    return findings


def substitute(expr: str, values: dict[str, str]) -> str:
    for key in sorted(values, key=len, reverse=True):
        expr = expr.replace(f"${{{key}}}", values[key]).replace(f"${key}", values[key])
    for key, value in DEFAULT_SUBSTITUTIONS.items():
        expr = expr.replace(key, value)
    return expr


def parse_pairs(pairs: tuple[str, ...], flag: str) -> dict[str, str]:
    out = {}
    for pair in pairs:
        if "=" not in pair or not pair.split("=", 1)[0]:
            raise ScriptError(f"{flag} takes KEY=VALUE, got {pair!r}")
        key, value = pair.split("=", 1)
        out[key] = value
    return out


def restack(panels: list[dict]) -> None:
    y, x, line = 0, 0, 0
    for panel in panels:
        grid = panel.setdefault("gridPos", {})
        w, h = grid.get("w", GRID_WIDTH), grid.get("h", 1)
        if panel.get("type") == "row" or x + w > GRID_WIDTH:
            y, x, line = y + line, 0, 0
        grid.update({"x": x, "y": y, "w": w, "h": h})
        x, line = x + w, max(line, h)
        if panel.get("type") == "row":
            y, x, line = y + h, 0, 0


def rename_links(node, mapping: dict[str, str], counts: dict[str, int], in_links: bool = False) -> None:
    if isinstance(node, dict):
        title = node.get("title")
        if in_links and title in mapping:
            node["title"] = mapping[title]
            counts[title] += 1
        for key, value in node.items():
            rename_links(value, mapping, counts, in_links or key == "links")
    elif isinstance(node, list):
        for value in node:
            rename_links(value, mapping, counts, in_links)


@click.group(context_settings=CONTEXT_SETTINGS, help=__doc__)
def cli() -> None:
    pass


paths_argument = click.argument("paths", nargs=-1, type=click.Path(path_type=Path, dir_okay=False))


@cli.command()
@paths_argument
def lint(paths: tuple[Path, ...]) -> None:
    """Report layout and convention defects; exit 1 when any are found."""
    total = 0
    for dashboard in load(paths):
        findings = lint_dashboard(dashboard)
        total += len(findings)
        for finding in findings:
            emit(f"{dashboard.path}: {finding}")
    emit(f"RESULT: {len(paths)} dashboard(s) checked, {total} finding(s)")
    raise SystemExit(FINDINGS if total else ExitCode.MET)


@cli.command()
@paths_argument
@click.option("--set", "sets", multiple=True, metavar="VAR=VALUE", help="Value for a variable. Unset ones become .*")
def queries(paths: tuple[Path, ...], sets: tuple[str, ...]) -> None:
    """Print one JSON line per target: file, panel id, title, refId and the substituted expr."""
    overrides = parse_pairs(sets, "--set")
    for dashboard in load(paths):
        values = {name: ".*" for name in dashboard.variables() if name != "datasource"}
        values.update(overrides)
        for panel in dashboard.panels():
            for target in panel.get("targets", []):
                if "expr" not in target:
                    continue
                record = {
                    "file": str(dashboard.path),
                    "panel": panel.get("id"),
                    "title": panel.get("title"),
                    "refId": target.get("refId"),
                    "expr": substitute(target["expr"], values),
                }
                emit(json.dumps(record))


@cli.command()
@paths_argument
@click.option("--renumber", is_flag=True, help="Also renumber panel ids 1..N in order.")
def reflow(paths: tuple[Path, ...], renumber: bool) -> None:
    """Re-stack every panel from its position in the list, so inserting one needs no y arithmetic."""
    for dashboard in load(paths):
        panels = dashboard.data["panels"]
        restack(panels)
        if renumber:
            for number, panel in enumerate(dashboard.panels(), 1):
                panel["id"] = number
        dashboard.write()
        emit(f"RESULT: {dashboard.path} reflowed, {len(panels)} panel(s)")


@cli.command()
@paths_argument
@click.option("--map", "maps", multiple=True, required=True, metavar="OLD=NEW", help="Exact link title to rename.")
def retitle(paths: tuple[Path, ...], maps: tuple[str, ...]) -> None:
    """Rename dashboard-link and data-link titles; panel titles are never touched."""
    mapping = parse_pairs(maps, "--map")
    counts = dict.fromkeys(mapping, 0)
    dashboards = load(paths)
    for dashboard in dashboards:
        rename_links(dashboard.data, mapping, counts)
    unmatched = [old for old, count in counts.items() if not count]
    if unmatched:
        for old in unmatched:
            emit(f"unmatched: {old!r}")
        emit("RESULT: nothing written, a mapping matched no link title")
        raise SystemExit(FINDINGS)
    for dashboard in dashboards:
        dashboard.write()
    emit(f"RESULT: {sum(counts.values())} link title(s) renamed across {len(dashboards)} file(s)")


def main() -> None:
    try:
        cli.main(standalone_mode=False)
    except ScriptError as err:
        emit(f"ERROR: {err}")
        raise SystemExit(err.exit_code) from err
    except click.ClickException as err:
        err.show()
        raise SystemExit(ExitCode.USAGE) from err
    except click.Abort:
        raise SystemExit(130) from None


if __name__ == "__main__":
    main()
