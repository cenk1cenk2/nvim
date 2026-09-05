"""Validated inputs, as pydantic types shared by every condition.

Validation lives here rather than in each command so a refusal reads the same
whichever condition raised it, and so the rules that keep a watcher from arming
on nothing cannot be forgotten by a new condition.

Pydantic's own constrained types do the ordinary work (`NonNegativeFloat`,
`PositiveInt`, `AnyHttpUrl`). Only two rules are ours, because they are domain
rules rather than type rules: a path must be absolute, and it must not glob.
"""

from __future__ import annotations

from pathlib import Path
from typing import Annotated

from pydantic import AfterValidator, AnyHttpUrl, BaseModel, ConfigDict, NonNegativeFloat, PositiveFloat, PositiveInt

GLOB_CHARS = "*?["


def _no_glob(value: str) -> str:
    """A glob matches a finished sibling item and fires the watcher on the wrong one."""
    for char in GLOB_CHARS:
        if char in value:
            raise ValueError(f"contains the glob character {char!r}; pass the exact path")
    return value


def _absolute(value: str) -> str:
    """A relative path resolves against whatever cwd the background launcher had."""
    if not Path(value).is_absolute():
        raise ValueError(f"must be an absolute path, got: {value}")
    return value


AbsolutePath = Annotated[str, AfterValidator(_no_glob), AfterValidator(_absolute)]


def http_url(value: str) -> str:
    """Validate with pydantic, then hand back the ORIGINAL string.

    `AnyHttpUrl` normalises - it will append a trailing slash to a bare host -
    and the watched URL must be exactly what the caller passed, since a probe
    that quietly rewrites its target is the same class of bug as a glob.
    """
    from pydantic import TypeAdapter

    TypeAdapter(AnyHttpUrl).validate_python(value)
    return value


class Cadence(BaseModel):
    """How often to look and how many times, shared by every condition."""

    model_config = ConfigDict(frozen=True)

    # Zero is allowed so a test can poll as fast as the loop runs.
    interval: NonNegativeFloat = 30.0
    max_polls: PositiveInt = 120
    label: str | None = None
    quiet: bool = False


class FlatFor(BaseModel):
    """The stall window for `file-flat`."""

    model_config = ConfigDict(frozen=True)

    seconds: PositiveFloat


class WatchedPath(BaseModel):
    """A path a watcher polls: absolute, and never a glob."""

    model_config = ConfigDict(frozen=True)

    path: AbsolutePath


class Expectations(BaseModel):
    """The value set a `command` condition compares against."""

    model_config = ConfigDict(frozen=True)

    values: tuple[str, ...] = ()
    json_path: str | None = None
    contains: bool = False
    negate: bool = False

    def matches(self, observed: str) -> bool:
        # Kept as if/else rather than the ternary ruff suggests: this is the
        # decision that fires a watcher, and it should read as two named cases.
        if self.contains:  # noqa: SIM108
            hit = any(value in observed for value in self.values)
        else:
            hit = observed in self.values
        return not hit if self.negate else hit
