#!/usr/bin/env -S sh -c 'exec uv run --project "$(dirname "$0")" "$0" "$@"'
"""Poll one shell-reachable condition in the background and exit the moment it holds.

\b
exit codes are the contract, because this runs detached and its exit IS the wake:
  0  the condition held        RESULT: <label> met after N poll(s)
  1  ceiling reached           not proof of failure; the last observed value is printed
  2  usage error               nothing was polled
  3  the check cannot run      command not found, unreadable --expect-file

One condition per invocation; arm another watcher for another item.
"""

from __future__ import annotations

import click
from agentlib.cli import ScriptError, create_logger, emit
from agentlib.models import Cadence, Expectations, FlatFor, WatchedPath, http_url
from pydantic import ValidationError

import probes
import runner
from vendors import VENDORS, Vendor

CONTEXT_SETTINGS = {"help_option_names": ["-h", "--help"], "max_content_width": 100}


CADENCE_DEFAULTS = {"interval": 30.0, "max_polls": 120, "label": None, "quiet": False}


def cadence_options(func):
    """The flags every condition shares.

    They are declared on the group AND on each condition, both defaulting to
    None, so an agent composing a command line may put them on either side of
    the condition. The condition's own value wins when both are given.
    """
    func = click.option("--interval", type=float, default=None, help="Seconds between polls. [default: 30]")(func)
    func = click.option("--max-polls", type=int, default=None, help="Ceiling; a backstop. [default: 120]")(func)
    func = click.option("--label", default=None, help="Name this watch in its RESULT line.")(func)
    func = click.option("--quiet", is_flag=True, default=None, help="Drop the header; keep RESULT.")(func)
    return func


def build_cadence(**kwargs) -> Cadence:
    """Merge the condition's flags over the group's, then over the defaults."""
    outer = click.get_current_context().obj or {}
    merged = {}
    for key, fallback in CADENCE_DEFAULTS.items():
        value = kwargs.get(key)
        if value is None:
            value = outer.get(key)
        merged[key] = fallback if value is None else value
    try:
        return Cadence(**merged)
    except ValidationError as err:
        raise ScriptError(_first_error(err)) from err


def _first_error(err: ValidationError) -> str:
    """Pydantic reports a list; a CLI refusal is one line."""
    first = err.errors()[0]
    field = ".".join(str(part) for part in first["loc"]) or "argument"
    return f"--{field.replace('_', '-')}: {first['msg']}"


def validated(model, **kwargs):
    try:
        return model(**kwargs)
    except ValidationError as err:
        raise ScriptError(_first_error(err)) from err


@click.group(context_settings=CONTEXT_SETTINGS, help=__doc__, invoke_without_command=True)
@click.option("-v", "--verbose", is_flag=True, help="Debug logging on stderr.")
@cadence_options
@click.pass_context
def cli(ctx: click.Context, verbose: bool, **cadence) -> None:
    create_logger(verbose, "watch")
    # A bare invocation is a usage error, not a help screen: an agent that armed
    # nothing must see exit 2 rather than a silent success.
    if ctx.invoked_subcommand is None:
        raise ScriptError("a condition is required; see --help for the list")
    # Stashed for build_cadence: a flag given here is the fallback for whatever
    # the condition does not set itself.
    ctx.obj = cadence


@cli.command("file-exists")
@click.argument("path")
@cadence_options
def file_exists(path: str, **cadence) -> None:
    """PATH appeared; a marker written when a job finishes."""
    checked = validated(WatchedPath, path=path)
    raise SystemExit(runner.run(probes.FileExists(checked.path), build_cadence(**cadence)))


@cli.command("file-gone")
@click.argument("path")
@cadence_options
def file_gone(path: str, **cadence) -> None:
    """PATH disappeared; a lock or pid file released."""
    checked = validated(WatchedPath, path=path)
    raise SystemExit(runner.run(probes.FileGone(checked.path), build_cadence(**cadence)))


@cli.command("file-flat")
@click.argument("path")
@click.option("--for", "for_seconds", required=True, type=float, help="Seconds the size must stay unchanged.")
@cadence_options
def file_flat(path: str, for_seconds: float, **cadence) -> None:
    """PATH's size unchanged for --for seconds; a stall detector."""
    checked = validated(WatchedPath, path=path)
    window = validated(FlatFor, seconds=for_seconds)
    probe = probes.FileFlat(checked.path, window.seconds)
    raise SystemExit(runner.run(probe, build_cadence(**cadence)))


@cli.command("exit-zero", context_settings={"ignore_unknown_options": True})
@click.argument("command", nargs=-1, required=True)
@cadence_options
def exit_zero(command: tuple[str, ...], **cadence) -> None:
    """COMMAND exits 0; a health probe, git merge-base --is-ancestor."""
    raise SystemExit(runner.run(probes.ExitZero(list(command)), build_cadence(**cadence)))


@cli.command("command", context_settings={"ignore_unknown_options": True})
@click.argument("command", nargs=-1, required=True)
@click.option("--expect", "expect", multiple=True, help="A value that means met. Repeatable.")
@click.option("--expect-file", default=None, help="Read the expected value from a file; for values carrying quotes.")
@click.option("--json-path", default=None, help="Narrow stdout by a dotted path before comparing.")
@click.option("--contains", is_flag=True, help="Substring match instead of equality.")
@click.option("--negate", is_flag=True, help="Met when the value LEAVES the expected set.")
@cadence_options
def command_condition(
    command: tuple[str, ...],
    expect: tuple[str, ...],
    expect_file: str | None,
    json_path: str | None,
    contains: bool,
    negate: bool,
    **cadence,
) -> None:
    """COMMAND's stdout matches --expect; the general condition."""
    values = _load_expectations(expect, expect_file)
    spec = Expectations(values=values, json_path=json_path, contains=contains, negate=negate)
    probe = probes.Command(list(command), spec)
    raise SystemExit(runner.run(probe, build_cadence(**cadence)))


@cli.command("http")
@click.argument("url")
@click.option("--status", default=200, show_default=True, type=int, help="The status that means met.")
@click.option("--contains", "body_contains", default=None, help="Require this substring in the body.")
@cadence_options
def http(url: str, status: int, body_contains: str | None, **cadence) -> None:
    """GET URL returns --status, body containing --contains."""
    probe = probes.Http(_checked_url(url), status=status, contains=body_contains)
    raise SystemExit(runner.run(probe, build_cadence(**cadence)))


def _checked_url(url: str) -> str:
    try:
        return http_url(url)
    except ValidationError as err:
        raise ScriptError(_first_error(err)) from err
    except ValueError as err:
        raise ScriptError(str(err)) from err


def _load_expectations(expect: tuple[str, ...], expect_file: str | None) -> tuple[str, ...]:
    if expect_file is not None:
        if expect:
            raise ScriptError("pass --expect or --expect-file, not both")
        try:
            with open(expect_file, encoding="utf-8") as handle:
                return (handle.read().strip(),)
        except OSError as err:
            raise ScriptError(f"cannot read --expect-file: {err}") from err
    if not expect:
        raise ScriptError("command needs at least one --expect VALUE, or --expect-file PATH")
    return tuple(expect)


def _register_vendor(vendor: Vendor) -> None:
    """Attach one domain condition as its own click command.

    Each takes `--wait-result` repeatably; omitted, it waits for every TERMINAL
    state so a failure wakes you as early as a success.
    """

    @click.option("--wait-result", multiple=True, help="A state that ends the watch. Repeatable; defaults to terminal.")
    @cadence_options
    def run_vendor(wait_result: tuple[str, ...], _vendor: Vendor = vendor, **kwargs) -> None:
        cadence = {key: kwargs.pop(key) for key in ("interval", "max_polls", "label", "quiet")}
        if not wait_result and not _vendor.terminal:
            raise ScriptError(f"{_vendor.name} has no terminal default; pass --wait-result")
        probe = _vendor.build(kwargs, wait_result)
        raise SystemExit(runner.run(probe, build_cadence(**cadence)))

    for param in reversed(vendor.params):
        run_vendor = click.option(f"--{param}", required=True, help=f"The {param}.")(run_vendor)

    cli.command(vendor.name, help=vendor.help)(run_vendor)


for _vendor in VENDORS:
    _register_vendor(_vendor)


def main() -> None:
    try:
        cli.main(standalone_mode=False)
    except ScriptError as err:
        emit(f"error: {err}")
        raise SystemExit(err.exit_code) from err
    except click.ClickException as err:
        err.show()
        raise SystemExit(err.exit_code) from err
    except click.Abort:
        raise SystemExit(130) from None


if __name__ == "__main__":
    main()
