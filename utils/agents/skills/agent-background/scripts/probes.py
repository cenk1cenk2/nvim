"""The conditions themselves. A probe answers `(met, observed)` and nothing else.

`observed` is what gets printed on a CHANGE line and on a ceiling, so it is the
whole diagnostic value of a watch that did not fire. A probe that cannot run at
all raises `CannotRun`, which is exit 3 - a different thing from "not met",
because polling will never change it.
"""

from __future__ import annotations

import json
import os
import subprocess
import time
from typing import Protocol

import httpx
from agentlib.cli import ScriptError
from agentlib.models import Expectations
from jsonpath_ng.exceptions import JSONPathError
from jsonpath_ng.ext import parse as jsonpath_parse

VALUE_PRINT_LIMIT = 200
HTTP_TIMEOUT = 20
HTTP_READ_BYTES = 65536
# A real browser UA: an edge proxy will serve a challenge page to a default
# client string, which reads as a wrong status rather than as a blocked probe.
USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"


class CannotRun(Exception):
    """The check itself is broken - a missing binary, an unreadable file. Exit 3."""


def truncate(value: str) -> str:
    value = value.replace("\n", "\\n")
    return value[:VALUE_PRINT_LIMIT] + "..." if len(value) > VALUE_PRINT_LIMIT else value


def _is_jsonpath(path: str) -> bool:
    """A JSONPath expression, as opposed to the plain dotted form.

    The prefix must be `$.` or `$[`, not a bare `$`: `$schema`, `$ref` and `$id`
    are ordinary JSON keys, and treating them as expressions turned a working
    dotted path into a parse error. A bracket anywhere else is unambiguous,
    since the dotted form indexes a list with a bare integer segment.
    """
    return path.startswith(("$.", "$[")) or "[" in path


def check_json_path(path: str) -> None:
    """Parse a JSONPath once, at arm time, so a bad one is a usage error.

    Parsed only per poll it raises inside the loop, after the watcher has
    reported itself armed, and the traceback exits 1 - which a caller reads as
    a ceiling rather than as the usage error it is.
    """
    if not _is_jsonpath(path):
        return
    try:
        jsonpath_parse(path)
    except Exception as err:  # jsonpath_ng raises several unrelated types
        raise ScriptError(f"--json-path is not a valid JSONPath expression: {err}") from err


def json_walk(text: str, path: str) -> str:
    """Narrow a JSON document by a path expression.

    Two accepted forms, told apart by shape:

    - **Dotted** - `pipeline.status`, `jobs.0.status`. Integer segments index
      lists. This is the terse form and stays the default.
    - **JSONPath** - `$.jobs[0].status`, `$.jobs[?(@.name=='lint')].status`.
      Anything jq-shaped, for the cases the dotted form cannot express:
      filters, wildcards, recursive descent.

    A JSONPath matching several nodes is an error rather than a silent first
    match - a watcher firing on whichever node happened to sort first is the
    same class of bug as a glob.
    """
    data = json.loads(text)
    if _is_jsonpath(path):
        matches = jsonpath_parse(path).find(data)
        if not matches:
            raise KeyError(path)
        if len(matches) > 1:
            raise ValueError(f"{path} matched {len(matches)} nodes; narrow it to one")
        data = matches[0].value
    else:
        for segment in [s for s in path.strip(".").split(".") if s]:
            if isinstance(data, list):
                if not segment.lstrip("-").isdigit():
                    raise KeyError(segment)
                data = data[int(segment)]
            elif isinstance(data, dict):
                data = data[segment]
            else:
                raise KeyError(segment)
    return data if isinstance(data, str) else json.dumps(data, sort_keys=True)


class Probe(Protocol):
    def describe(self) -> str:
        """One line naming exactly what is being watched, printed in the header."""
        ...

    def __call__(self) -> tuple[bool, str | None]:
        """Return (met, observed). `observed` may be None when there is nothing to report."""
        ...


class FileExists:
    def __init__(self, path: str):
        self.path = path

    def describe(self) -> str:
        return f"{self.path} exists"

    def __call__(self) -> tuple[bool, str | None]:
        return os.path.exists(self.path), None


class FileGone:
    def __init__(self, path: str):
        self.path = path

    def describe(self) -> str:
        return f"{self.path} is gone"

    def __call__(self) -> tuple[bool, str | None]:
        return not os.path.exists(self.path), None


class FileFlat:
    """Met once the file has stopped growing for `for_seconds`. A stall detector."""

    def __init__(self, path: str, for_seconds: float):
        self.path = path
        self.for_seconds = for_seconds
        self._size: int | None = None
        self._since: float | None = None

    def describe(self) -> str:
        return f"{self.path} size unchanged for {self.for_seconds:g}s"

    def __call__(self) -> tuple[bool, str | None]:
        try:
            size = os.path.getsize(self.path)
        except OSError:
            # Absent is not flat: it has not started, so the clock does not run.
            self._size = None
            self._since = None
            return False, "absent"
        now = time.monotonic()
        if size != self._size:
            self._size = size
            self._since = now
            return False, f"{size} bytes"
        return (now - (self._since or now)) >= self.for_seconds, f"{size} bytes"


# A watched command that blocks forever never lets the ceiling count down, so
# no wake ever arrives - the one outcome worse than a wrong answer, because
# nothing is ever reported at all. Every poll is bounded, and stdin is closed so
# a command that reads it fails fast instead of waiting on a terminal that a
# detached watcher does not have.
COMMAND_TIMEOUT = 120.0


def _run(command: list[str]) -> tuple[int, str]:
    try:
        proc = subprocess.run(
            command,
            capture_output=True,
            text=True,
            # A vendor CLI may emit a stray non-UTF-8 byte. Decoding strictly
            # raised UnicodeDecodeError out of the poll, and an exception here
            # exits 1 - which the contract defines as CEILING, telling the agent
            # the watch merely timed out.
            errors="replace",
            check=False,
            stdin=subprocess.DEVNULL,
            timeout=COMMAND_TIMEOUT,
        )
    except FileNotFoundError:
        raise CannotRun(f"command not found: {command[0]}") from None
    except PermissionError:
        raise CannotRun(f"command not executable: {command[0]}") from None
    except subprocess.TimeoutExpired:
        # Not-met rather than fatal: one slow poll is not a broken watch, and
        # the ceiling is what decides when to give up.
        return 124, ""
    except OSError as err:
        # NotADirectoryError (a path routed through a file), ENOEXEC, and the
        # rest of the exec-time family. All of them mean this check cannot run.
        raise CannotRun(f"cannot run {command[0]}: {err}") from None
    return proc.returncode, proc.stdout


class ExitZero:
    def __init__(self, command: list[str]):
        self.command = command

    def describe(self) -> str:
        return f"`{' '.join(self.command)}` exits 0"

    def __call__(self) -> tuple[bool, str | None]:
        code, _ = _run(self.command)
        return code == 0, f"exit {code}"


class Command:
    """Compare a command's stdout, optionally narrowed by a JSON path, to an expected set."""

    # The first observation is the state the watch started from - the single
    # most useful line in a wake, unlike a file condition's opening "absent".
    reports_first_value = True

    def __init__(
        self,
        command: list[str],
        expect: Expectations,
        describe_as: str | None = None,
        expect_source: str | None = None,
    ):
        self.command = command
        self.expect = expect
        self._describe_as = describe_as
        # Where the expected value came from, when it was a file. The header
        # names the file rather than its contents, which may be a quoted payload.
        self._expect_source = expect_source

    def describe(self) -> str:
        if self._describe_as:
            return self._describe_as
        via = f" via json path {self.expect.json_path}" if self.expect.json_path else ""
        test = "contains" if self.expect.contains else "equals"
        values = self._expect_source or " | ".join(repr(value) for value in self.expect.values)
        negation = "does not " if self.expect.negate else ""
        return f"`{' '.join(self.command)}`{via} {negation}{test} {values}"

    def __call__(self) -> tuple[bool, str | None]:
        code, out = _run(self.command)
        if code != 0:
            # glab and friends exit 1 with empty output when the API reply does
            # not parse. That is "not met", never "met".
            return False, f"exit {code}"
        observed = out.strip()
        if self.expect.json_path:
            try:
                observed = json_walk(out, self.expect.json_path)
            except (ValueError, KeyError, IndexError, TypeError, JSONPathError) as err:
                return False, f"json path {self.expect.json_path} unresolved ({err.__class__.__name__})"
        return self.expect.matches(observed), observed


class Http:
    """A health probe. A refused connection is not met, never an error - the service is still coming up."""

    def __init__(self, url: str, status: int = 200, contains: str | None = None):
        self.url = url
        self.status = status
        self.contains = contains

    def describe(self) -> str:
        body = f" and body contains {self.contains!r}" if self.contains else ""
        return f"GET {self.url} returns {self.status}{body}"

    def __call__(self) -> tuple[bool, str | None]:
        # httpx rather than urllib: it sends a browser-shaped request and follows
        # redirects, so a probe through Cloudflare or any edge proxy is not
        # bounced the way a bare urllib User-Agent is. An HTTP error status is a
        # normal response here, not an exception, so there is no error branch
        # duplicating the status check below.
        try:
            # `stream` rather than `get`: a probe polls on a cadence, and a
            # large endpoint would otherwise be downloaded in full every poll.
            with httpx.stream(
                "GET",
                self.url,
                timeout=HTTP_TIMEOUT,
                follow_redirects=True,
                headers={"User-Agent": USER_AGENT},
            ) as response:
                body = ""
                if self.contains is not None:
                    for chunk in response.iter_text():
                        body += chunk
                        if len(body) >= HTTP_READ_BYTES or self.contains in body:
                            break
                status = response.status_code
        except httpx.HTTPError as err:
            # Refused, DNS failure, TLS failure, timeout. The service is still
            # coming up: not met, never an error.
            return False, f"connection error: {err}"
        if status != self.status:
            return False, f"status {status}"
        if self.contains is not None and self.contains not in body:
            return False, f"status {status}, body without {self.contains!r}"
        return True, f"status {status}"
