"""Logger and error helpers shared by the scripts beside this package."""

from __future__ import annotations

import logging
import sys


class ScriptError(Exception):
    """An error the entry point prints as one line and turns into an exit code."""

    def __init__(self, message: str, exit_code: int = 2):
        super().__init__(message)
        self.exit_code = exit_code


class EarlyExit(Exception):
    """A watch ending on its own code rather than met/not-met, carrying the lines to print."""

    def __init__(self, exit_code: int, result: str, advice: str):
        super().__init__(result)
        self.exit_code = exit_code
        self.result = result
        self.advice = advice


def create_logger(verbose: bool, name: str) -> logging.Logger:
    """Configure stderr logging once; DEBUG when verbose, WARNING otherwise."""
    root = logging.getLogger()
    if not root.handlers:
        handler = logging.StreamHandler(sys.stderr)
        handler.setFormatter(logging.Formatter("%(name)s: %(message)s"))
        root.addHandler(handler)
    root.setLevel(logging.DEBUG if verbose else logging.WARNING)
    return logging.getLogger(name)
