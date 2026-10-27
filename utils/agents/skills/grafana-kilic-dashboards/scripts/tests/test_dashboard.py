"""Each subcommand against a throwaway dashboard: exit code, stdout line, and the file it leaves."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent.parent / "dashboard.py"


def run(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run([str(SCRIPT), *args], capture_output=True, text=True)


def panel(pid: int, kind: str = "timeseries", x: int = 0, y: int = 0, w: int = 12, h: int = 10, **extra) -> dict:
    return {"id": pid, "type": kind, "title": f"p{pid}", "gridPos": {"x": x, "y": y, "w": w, "h": h}, **extra}


def write(
    tmp_path: Path, panels: list[dict], variables: list[dict] | None = None, links: list[dict] | None = None
) -> Path:
    path = tmp_path / "d.json"
    data = {"panels": panels, "templating": {"list": variables or []}, "links": links or []}
    path.write_text(json.dumps(data, indent=2) + "\n")
    return path


def test_lint_clean(tmp_path):
    path = write(tmp_path, [panel(1, "row", w=24, h=1), panel(2, y=1), panel(3, x=12, y=1)])
    result = run("lint", str(path))
    assert result.returncode == 0
    assert "0 finding(s)" in result.stdout


def test_lint_overlap_and_duplicate_id(tmp_path):
    path = write(tmp_path, [panel(1), panel(1, x=6)])
    result = run("lint", str(path))
    assert result.returncode == 1
    assert "overlaps" in result.stdout
    assert "panel id 1 is used by" in result.stdout


def test_lint_repeated_row_and_range_table(tmp_path):
    table = panel(2, "table", y=1, w=24, targets=[{"refId": "A", "expr": "up", "format": "table"}])
    path = write(tmp_path, [panel(1, "row", w=24, h=1, repeat="node"), table])
    result = run("lint", str(path))
    assert result.returncode == 1
    assert "repeats per $node" in result.stdout
    assert "range query" in result.stdout


def test_lint_multi_select_plain_link(tmp_path):
    links = [{"title": "x", "url": "/d/a/a?var-node=${node}"}]
    path = write(tmp_path, [panel(1)], variables=[{"name": "node", "multi": True}], links=links)
    result = run("lint", str(path))
    assert result.returncode == 1
    assert "queryparam" in result.stdout


def test_queries_substitutes(tmp_path):
    target = {"refId": "A", "expr": 'rate(x{node=~"$node", pbs=~"${pbs}"}[$__rate_interval])'}
    variables = [{"name": "node", "multi": True}, {"name": "pbs"}, {"name": "datasource"}]
    path = write(tmp_path, [panel(1, targets=[target])], variables=variables)
    result = run("queries", str(path), "--set", "pbs=norsu")
    assert result.returncode == 0
    record = json.loads(result.stdout.strip())
    assert record["expr"] == 'rate(x{node=~".*", pbs=~"norsu"}[5m])'


def test_reflow_stacks_in_order(tmp_path):
    panels = [
        panel(1, "row", y=40, w=24, h=1),
        panel(2, y=3),
        panel(3, x=0, y=99),
        panel(4, "row", y=0, w=24, h=1),
        panel(5, w=24, h=5),
    ]
    path = write(tmp_path, panels)
    assert run("reflow", str(path)).returncode == 0
    grids = [(p["gridPos"]["x"], p["gridPos"]["y"]) for p in json.loads(path.read_text())["panels"]]
    assert grids == [(0, 0), (0, 1), (12, 1), (0, 11), (0, 12)]
    assert run("lint", str(path)).returncode == 0


def test_retitle_links_only(tmp_path):
    links = [{"title": "Old", "url": "/d/a/a"}]
    data_link = panel(1, fieldConfig={"defaults": {"links": [{"title": "Old"}]}}, title="Old")
    path = write(tmp_path, [data_link], links=links)
    result = run("retitle", str(path), "--map", "Old=New")
    assert result.returncode == 0
    data = json.loads(path.read_text())
    assert data["links"][0]["title"] == "New"
    assert data["panels"][0]["fieldConfig"]["defaults"]["links"][0]["title"] == "New"
    assert data["panels"][0]["title"] == "Old"


def test_retitle_refuses_unmatched(tmp_path):
    path = write(tmp_path, [panel(1)], links=[{"title": "Old"}])
    before = path.read_text()
    result = run("retitle", str(path), "--map", "Old=New", "--map", "Missing=X")
    assert result.returncode == 1
    assert "unmatched: 'Missing'" in result.stdout
    assert path.read_text() == before


def test_unreadable_file_is_cannot_run(tmp_path):
    path = tmp_path / "bad.json"
    path.write_text("{")
    assert run("lint", str(path)).returncode == 3


def test_usage_errors(tmp_path):
    assert run("lint").returncode == 2
    path = write(tmp_path, [panel(1)])
    assert run("queries", str(path), "--set", "novalue").returncode == 2
