---
name: agent-watcher-recipes
description: agent-watcher-recipes Concrete watcher signals per domain and the python checks that poll them - merge gates, CI runs, terraform and Spacelift, deploy convergence, detached agent sessions, chaining, tracker reconciliation. Load the entry for the thing you are about to watch. Not for watcher discipline, cadence, or the announce tables.
references:
  - ../references/agent/agent-watchers.md
---

# Agent Watcher Recipes

Concrete signals per domain, and the checks that poll them. Read the entry for the thing you are about to watch; skip the rest.

Checks are python unless the condition is a single-condition one-liner, per the language rule in `agent-watchers`.

Discipline, cadence, the announce tables and the audit live in `agent-watchers`.

## What to arm, by what just happened

The trigger is not "a PR is open". It is: **something outside this turn will change and you want to
know when.** Three tells, any one of which means arm one:

1. You are about to say *"I'll check back on this later"*.
2. You are about to ask the user to ping you when something happens.
3. You would otherwise re-run the same status command every turn until it changes.

### Merge gates — GitHub PRs and GitLab MRs

The most common wait, and the one most often left unwatched because it feels like the user will just
say. Watch the state field, and match **closed-without-merge** too — a watcher that only matches
`MERGED` hangs through an abandonment.

```python
import json, subprocess

out = subprocess.run(
    ["gh", "pr", "view", N, "--repo", REPO, "--json", "state"],
    capture_output=True,
    text=True,
).stdout
state = json.loads(out)["state"]
met = state in ("MERGED", "CLOSED")
# GitLab: glab mr view <N> --repo <project> -F json, then .state in ("merged", "closed")
```

Cadence 60s; cap sized to how long the human plausibly takes — hours, not minutes, when they may merge
after a meeting or overnight. On wake, **the merge is a proxy**: the thing you actually care about is
usually what the merge triggers, so re-verify and arm the follow-on rather than declaring done.

**One watcher per PR.** When several are in flight and any one merging is independently actionable, a
single loop that exits naming *whichever merged first* is not a bundle — it is a first-event detector.
Handle that one, then re-arm for the remainder.

### CI and pipeline runs

```python
# GitHub Actions: exclude every in-flight state explicitly, then read the conclusions
import json, subprocess

IN_FLIGHT = {"PENDING", "IN_PROGRESS", "QUEUED"}
out = subprocess.run(
    ["gh", "pr", "checks", N, "--repo", REPO, "--json", "name,state"],
    capture_output=True,
    text=True,
).stdout
checks = json.loads(out)
met = not any(c["state"] in IN_FLIGHT for c in checks)
# GitLab: glab ci status / the pipelines API, keyed on the pipeline id
```

**Exclude every non-terminal state, not just the obvious one.** A filter that excludes `PENDING` but
not `IN_PROGRESS` fires on a running job and reports a verdict that does not exist yet. Enumerate the
in-flight set for that system and match the complement.

Cadence 15–30s. On wake, read the **conclusion** rather than the presence of a result: a settled check
can be a failure, and "settled" alone is not "green".

### Terraform and Pulumi — plans and applies

These have **two** terminal-ish states and conflating them is the classic error:

| Question | Awaiting-human state counts as | Use when |
|---|---|---|
| *Has it settled?* | **terminal** — you want waking so you can tell the user to confirm | after triggering a plan |
| *Has it finished applying?* | **still waiting** — exclude it | after the user has been asked to confirm |

So the same run needs two different watchers at two different times, and the exclusion list is the only
difference between them. Write the exclusion list from the platform's full state enumeration —
initializing, queued, planning, applying, confirming, and the awaiting-approval state — and match the
complement.

```python
# Spacelift, via its CLI (tracked runs only — proposed/PR runs come from the MCP or the PR checks)
import json, subprocess

NOT_SETTLED = {"INITIALIZING", "QUEUED", "PLANNING", "APPLYING", "CONFIRMING"}
out = subprocess.run(
    [
        "spacectl",
        "stack",
        "run",
        "list",
        "--id",
        STACK,
        "--max-results",
        "5",
        "--output",
        "json",
    ],
    capture_output=True,
    text=True,
).stdout
state = next(r["state"] for r in json.loads(out) if r["id"] == RUN)
met = state not in NOT_SETTLED  # add the awaiting-approval state per the table above
```

On wake, **read the delta, not just the state.** A settled plan with the wrong resource counts is the
finding; a state field alone never tells you whether it is safe to apply. Where the plan detail is only
in the platform's MCP or its logs, poll the CLI as the proxy and do the delta check on the main loop.

A **zero-delta run may finish with no confirmation step at all** — do not wait for an apply nobody will
be asked for.

### Deploy convergence — ArgoCD, operators, rollouts

Reconcile loops run on their own interval, so cadence 30–60s. The signal is usually MCP-only or
cluster-only, so poll a shell-visible proxy (a CLI status, an HTTP probe) and confirm through the
authoritative tool on wake.

```python
import json, subprocess

out = subprocess.run(
    ["some-cli", "app", "get", APP, "-o", "json"], capture_output=True, text=True
).stdout
met = json.loads(out)["status"]["sync"]["status"] == "Synced"
```

A bare reachability probe carries no parsing, so it is one of the cases bash still fits:

```bash
curl -fsS -o /dev/null "$HEALTH_URL"
```

Convergence is where **"applied" and "working" diverge most** — the apply finishing is not the workload
being healthy. Chain a second watcher on the health signal rather than inferring it.

### Detached agent sessions on another server

An agent session started over MCP — a hyprpilot session above all — is a separate OS process your runtime
does not track and will never wake you for. **It is external state, and every detached turn gets its own
watcher armed before the session is reported as running.** One turn, one directory, one watcher: a follow-up
turn on the same session is a new condition, not the same one continuing.

The shell-visible proxy is the turn's completion marker, and the check is two conditions over the exact
per-turn path the call returned:

```python
import os

met = not os.path.isdir(TURN_DIR) or os.path.exists(os.path.join(TURN_DIR, "done.json"))
```

**Both halves are required.** A cleaned-up session — reaped, evicted, or lost with its sidecar — takes the
whole directory with it, so a file-only test waits forever on work that is already gone. A missing
**directory** means finished-and-gone.

Cadence 30 s, cap sized to how long the delegated job plausibly takes. `TURN_DIR` comes from the result of
the call that started this turn and is never reconstructed by hand.

On wake the marker tells you the turn **ended**, never that it succeeded and never what it produced. Do the
authoritative status read and the result collection over MCP on the main loop, then reap the watcher —
reaping the session deletes the directory the loop tests, so a survivor fires on the cleanup and reports a
finish that never happened. Session surface, tools and views per `hyprpilot-sessions`.

### Chaining — the wake that arms the next wake

Most real waits are a chain, and each link is its own watcher:

1. PR merged → 2. its pipeline or tracked run settled → 3. the human confirmed → 4. the apply finished →
5. the deploy converged → 6. post-verification queries are meaningful.

Arm link N+1 **on waking from link N**, after re-verifying. Never arm the whole chain up front: the
later run ids do not exist yet, and a watcher keyed on a guess fires on the wrong thing.

### Tracker reconciliation

A tracker state is not a signal you can poll from bash. Watch the **artifact** that should drive it —
the merge, the pipeline, the apply — and do the tracker write on wake through the tracker's own skills.
That keeps the record event-driven instead of periodically re-audited, and it means the issue moves when
the artifact says so rather than when someone remembers.

### Other things worth watching

- **Local long work** — a build, a full test suite, a large migration, a big import you would otherwise
  babysit.
- **Artifacts** — a file or report produced, an image or package published, a bundle appearing.
- **Services and data** — an endpoint coming up, a queue draining, a count crossing a threshold, a lock
  releasing, a rate-limit window resetting.
- **People and other agents** — an approval, a tracker or chat reply, another team's change landing.
- **Time-bound conditions** — a release window opening, a maintenance slot ending.

If the truth is not shell-reachable, that is not a reason to skip it — poll a proxy and confirm on wake.
If nothing is pollable at all, say so explicitly rather than quietly deciding to remember.

## Check recipes

A watcher's `<check>` is whatever decides the condition holds — an expression in python, or a command
exiting zero in bash. **Write it in python by default**; bash is for the single-condition one-liners at
the end of this section. Four shapes cover almost everything above.

**State query** — a CLI or API reporting a status field:
```python
import json, subprocess

out = subprocess.run(
    ["some-cli", "show", ID, "--output", "json"], capture_output=True, text=True
).stdout
met = json.loads(out)["state"] in TERMINAL_STATES
```

**Appearance** — an artifact produced, or a line showing up in a log:
```python
import os, re

met = (os.path.getsize(ARTIFACT) > 0 if os.path.exists(ARTIFACT) else False) or bool(
    re.search(r"DONE|FAILED|Traceback", open(LOGFILE, errors="replace").read())
)
```

**Change** — a value moving off a known baseline (a ref, a count, a version). Capture the baseline
*before* triggering the work:
```python
import subprocess

current = subprocess.run(
    ["probe-current-value"], capture_output=True, text=True
).stdout.strip()
met = current != KNOWN_BASELINE
```

**Several items** — one watcher still owns one condition (discipline item 1), but a check that consults
a collection holds it in python, never a shell array:
```python
import json, subprocess

out = subprocess.run(
    ["some-cli", "list", "--output", "json"], capture_output=True, text=True
).stdout
met = any(r["id"] == RUN and r["state"] in TERMINAL_STATES for r in json.loads(out))
```

**Reachability is the bash case** — a probe with nothing to parse is a single-condition one-liner, and
the shell says it in less:
```bash
curl -fsS -o /dev/null "$URL"
```

The same goes for a bare file test or one string compared to one field. Anything past that — a JSON
response parsed, several fields weighed, a collection walked, a path built — is python, per the language
rule in `agent-watchers`.

**Adapt to what this environment actually has.** Do not reach for a CLI because it appeared in an
example — check what is installed, or fall back to the API over `curl`, or to a filesystem signal.

**Cover failure, not just success.** A check matching only the happy path stays silent through a crash,
and silence looks exactly like "still running". Match every terminal state, or bound the loop tightly
enough that exhaustion tells you something.

**Verify the field paths against one real response before arming.** A parser that errors — a wrong field
path, a shape that changed — makes the loop exit early and report a settle that never happened. Where a
single field out of a single response is genuinely all you need, `jq` in a bash one-liner is fine; the
moment a second field or a branch appears, it is python.

**Never hold the ids in a shell array.** `${array[@]}` can expand to nothing inside a background-exec
facility, and a loop over an empty list examines nothing and then reports success — the watcher fires on
the first cycle, on a condition that never held. Hold the collection in python, where it is a value
rather than a word the shell re-splits.

