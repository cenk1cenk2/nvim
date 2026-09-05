"""Shared CLI and logging scaffolding for the agent-skill scripts.

Every entry script wires its click root through `create_logger` so `--verbose`
bumps the root to DEBUG and everything else stays quiet. The handler is
stderr-bound on purpose: **stdout is the wake**, read by an agent grepping for
`RESULT:` on a line, so nothing decorative may land there.
"""

from __future__ import annotations

import logging
import sys
from enum import IntEnum

from rich.console import Console
from rich.logging import RichHandler


class ExitCode(IntEnum):
    """The wake contract. A detached script's exit IS its message, so these are API."""

    MET = 0
    CEILING = 1
    USAGE = 2
    CANNOT_RUN = 3
    # Session-shaped endings, used by the hyprpilot harness verbs.
    SESSION_GONE = 10
    STALLED = 11


# Bound to stderr, and `force_terminal` left unset so a detached background
# launch - which is how every watcher runs - degrades to plain text on its own.
_console = Console(stderr=True)


class ScriptError(Exception):
    """An error the entry point prints as one line and turns into an exit code.

    Exit 2 is the default because that is a usage error: the caller passed
    something that would have armed a watcher on nothing.
    """

    def __init__(self, message: str, exit_code: int = ExitCode.USAGE):
        super().__init__(message)
        self.exit_code = int(exit_code)


class EarlyExit(Exception):
    """A run ending on its own code rather than met/not-met, carrying the lines to print."""

    def __init__(self, exit_code: int, result: str, advice: str):
        super().__init__(result)
        self.exit_code = exit_code
        self.result = result
        self.advice = advice


def create_logger(verbose: bool, name: str) -> logging.Logger:
    """Configure stderr logging once; DEBUG when verbose, WARNING otherwise."""
    root = logging.getLogger()
    if not root.handlers:
        root.addHandler(
            RichHandler(
                console=_console,
                show_path=False,
                show_time=False,
                rich_tracebacks=True,
                markup=False,
            )
        )
    root.setLevel(logging.DEBUG if verbose else logging.WARNING)
    return logging.getLogger(name)


def emit(line: str) -> None:
    """Write one line to stdout and flush it.

    Flushing matters: a watcher is killed rather than allowed to exit in some
    endings, and an unflushed buffer is a wake that carries nothing.
    """
    sys.stdout.write(line + "\n")
    sys.stdout.flush()
