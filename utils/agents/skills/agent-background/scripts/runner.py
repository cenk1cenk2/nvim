"""The poll loop: one condition, a cadence, a ceiling, and one line of stdout per event.

Stdout is deliberately plain and stable. It is the wake an agent reads, so the
shapes below (`watching`, `CHANGE:`, `RESULT:`) are a grep contract, not
presentation - rich stays on the stderr logger.
"""

from __future__ import annotations

import logging
import time

from agentlib.cli import emit
from agentlib.models import Cadence

from probes import CannotRun, Probe, truncate

log = logging.getLogger("watch")


def run(probe: Probe, cadence: Cadence) -> int:
    """Poll until met, until the ceiling, or until the check proves unrunnable.

    Exit codes: 0 met, 1 ceiling, 3 the check cannot run.
    """
    label = cadence.label or probe.describe()

    if not cadence.quiet:
        emit(f"watching {label}")
        emit(f"condition:   {probe.describe()}")
        emit(f"ceiling:     {cadence.max_polls} polls at {cadence.interval:g}s")

    last_value: str | None = None
    reports_first = getattr(probe, "reports_first_value", False)

    for poll in range(1, cadence.max_polls + 1):
        try:
            met, value = probe()
        except CannotRun as err:
            emit(f"RESULT: {label} check cannot run at poll {poll}: {err}")
            emit("next: fix the command, then re-arm. Polling would never change this.")
            return 3

        log.debug("poll %d met=%s value=%s", poll, met, value)

        if value is not None and value != last_value:
            # The first value of a command-like probe is itself news: it is the
            # state the watch started from, which a wake needs to be readable.
            if last_value is not None or reports_first:
                emit(f"CHANGE: poll {poll} value={truncate(value)}")
            last_value = value

        if met:
            emit(f"RESULT: {label} met after {poll} poll(s)")
            emit("next: verify the real state on the main loop before acting; a proxy can lag.")
            return 0

        if poll < cadence.max_polls:
            time.sleep(cadence.interval)

    emit(f"RESULT: {label} not met after {cadence.max_polls} poll(s)")
    if last_value is not None:
        emit(f"last observed: {truncate(last_value)}")
    emit("next: check the real state first. A ceiling is a backstop, not a verdict; re-arm only if someone is driving.")
    return 1
