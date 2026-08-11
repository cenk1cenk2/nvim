# Agent Watchers

What to watch, how often, what a wake means, and how to keep the set legible. Read this whenever you
arm a watcher — from `agent-background` (which owns the launch mechanics), `agent-bulldozer` (never
idle), `agent-supervisor` (never drift), or `agent-coordinator` (covering a wait).

The runtime facility and its parameters live in `harness-<provider>-agent-background`. Subagents are
tracked separately, per `agent-roster`.

## Discipline

1. **One watcher per independent condition.** Five MRs are five watchers. Bundle only when a gate
   genuinely cannot move until all of them clear together — otherwise one stalling blinds you to the
   rest.
2. **Arm it the moment the condition opens**, not when you next remember it. The gap between "the MR is
   open" and "did it merge?" is where both momentum and tracker accuracy are lost.
3. **Bound every loop.** A cap is a runaway backstop, not a deadline: on exhaustion, report "not met"
   and re-arm rather than looping forever.
4. **Size cap × cadence to the real wait, not to your impatience.** A human action you expect
   overnight needs hours of cap; a 60-cycle 60-second watch on it expires long before the merge and the
   silence then reads as "nothing happened". Estimate how long the thing genuinely takes, then add
   margin.
5. **Cadence follows how fast the signal can actually change** (table below). Never poll faster than the
   state can move; never leave a fast signal unchecked for minutes.
6. **On wake, re-verify authoritatively.** The signal may be a proxy, and proxies lag — a merge can read
   done before the downstream apply has converged. Do the real check on the main loop before acting.
7. **A dead watcher is not an answer.** If it exits without the condition met — cap exhausted, signal
   broke, process killed — diagnose which, fix that, and re-arm. Never let a lapsed watch silently
   become "no news".
8. **Reap what you armed**, and reap *before* re-arming a replacement, or duplicates double-wake and can
   contradict each other. Reap when: the condition fired and you acted, you learned the answer another
   way, the signal proved unreliable, or the work was superseded.
9. **Account for every live watcher in each report** — what it polls, its cadence, its handle. An
   unexplained live watcher at the end of a flow is a bug, not diligence.

**Bash cannot call MCP tools.** When the truth is only reachable via MCP (Linear state, ArgoCD, Grafana,
Spacelift where no CLI exists), poll a bash-visible **proxy** and do the authoritative MCP check
yourself on wake.

## Which wake is this? — routing by posture

The mechanics are identical across modes. **What the wake is *for* is not**, and you decide that before
arming, because it determines whether the wake fires work.

| | **Momentum** — `agent-bulldozer` | **Routing** — `agent-coordinator` | **Awareness** — `agent-supervisor` |
|---|---|---|---|
| Purpose | Unblock the next action | Decide what gets dispatched next | Keep the record true |
| Cadence bias | Tight — idle time after the blocker cleared is pure waste | Tight enough not to stall the queue | Matched to the signal; late costs accuracy, not speed |
| On wake | Re-verify, fire the already-staged next step, arm the follow-on | Re-verify, then choose the next dispatch; delegate the bulk of it | Re-verify, reconcile the tracker and the report, arm the follow-on |
| Does it act? | Yes — that is the point | It routes: the acting is a subagent's | No. It corrects and reports; pushing work needs the user's ask |
| Cost of not arming | You sit idle while the blocker cleared long ago | The queue drains and nothing is dispatched | Your next report is confidently wrong |

**The same condition serves any of the three** — an open MR is a blocker to a bulldozer, a routing
trigger to a coordinator, and a pending fact to a supervisor. Decide which you are arming and say so
when you report it, because "MR merged" means *fire the next stage* to one, *dispatch the next agent* to
another, and *move the issue to Done* to the third.

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

```bash
[ "$(gh pr view "$N" --repo "$OWNER/$REPO" --json state --jq .state)" = "MERGED" ]
# GitLab: glab mr view "$N" --repo "$PROJECT" -F json | jq -r .state  → "merged"
```

Cadence 60s; cap sized to how long the human plausibly takes — hours, not minutes, when they may merge
after a meeting or overnight. On wake, **the merge is a proxy**: the thing you actually care about is
usually what the merge triggers, so re-verify and arm the follow-on rather than declaring done.

**One watcher per PR.** When several are in flight and any one merging is independently actionable, a
single loop that exits naming *whichever merged first* is not a bundle — it is a first-event detector.
Handle that one, then re-arm for the remainder.

### CI and pipeline runs

```bash
# GitHub Actions: check conclusions, and exclude every in-flight state explicitly
gh pr checks "$N" --repo "$OWNER/$REPO" --json name,state \
  | jq -e '[.[] | select(.state=="PENDING" or .state=="IN_PROGRESS" or .state=="QUEUED")] | length == 0'
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

```bash
# Spacelift, via its CLI (tracked runs only — proposed/PR runs come from the MCP or the PR checks)
spacectl stack run list --id "$STACK" --max-results 5 --output json \
  | jq -r --arg r "$RUN" '.[] | select(.id==$r) | .state'
```

On wake, **read the delta, not just the state.** A settled plan with the wrong resource counts is the
finding; a state field alone never tells you whether it is safe to apply. Where the plan detail is only
in the platform's MCP or its logs, poll the CLI as the proxy and do the delta check on the main loop.

A **zero-delta run may finish with no confirmation step at all** — do not wait for an apply nobody will
be asked for.

### Deploy convergence — ArgoCD, operators, rollouts

Reconcile loops run on their own interval, so cadence 30–60s. The signal is usually MCP-only or
cluster-only, so poll a bash-visible proxy (a CLI status, an HTTP probe) and confirm through the
authoritative tool on wake.

```bash
curl -fsS -o /dev/null "$HEALTH_URL"          # reachability
[ "$(some-cli app get "$APP" -o json | jq -r .status.sync.status)" = "Synced" ]
```

Convergence is where **"applied" and "working" diverge most** — the apply finishing is not the workload
being healthy. Chain a second watcher on the health signal rather than inferring it.

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

If the truth is not bash-reachable, that is not a reason to skip it — poll a proxy and confirm on wake.
If nothing is pollable at all, say so explicitly rather than quietly deciding to remember.

## Cadence by signal

| Signal | Cadence | Why |
|--------|---------|-----|
| CI run, pipeline job, merge, apply finishing | 15–30 s | Fast, and the whole point is catching it immediately. |
| Deploy or operator convergence (ArgoCD, rollout) | 30–60 s | Reconcile loops run on their own interval. |
| Human action — review, approval, manual gate | 60–300 s | Bounded by a person, not a machine — and cap for hours, not minutes. |
| Long batch job with a known runtime | one check near the expected finish, then tighten | Early checks are pure waste. |
| Remote API with rate limits | ≥ 30 s | A tight loop gets you throttled, not informed. |

## Check recipes

A watcher's `<check>` is any command that **exits zero only when the condition holds** — that is the
entire contract. Four shapes cover almost everything above.

**State query** — a CLI or API reporting a status field:
```bash
[ "$(some-cli show "$ID" --output json | jq -r .state)" = "$TERMINAL_STATE" ]
```

**Reachability** — something coming up or responding:
```bash
curl -fsS -o /dev/null "$URL"
```

**Appearance** — an artifact produced, or a line showing up in a log:
```bash
[ -s "$ARTIFACT" ] || grep -qE 'DONE|FAILED|Traceback' "$LOGFILE"
```

**Change** — a value moving off a known baseline (a ref, a count, a version). Capture the baseline
*before* triggering the work:
```bash
[ "$(probe-current-value)" != "$KNOWN_BASELINE" ]
```

**Adapt to what this environment actually has.** Do not reach for a CLI because it appeared in an
example — check what is installed, or fall back to the API over `curl`, or to a filesystem signal.

**Cover failure, not just success.** A check matching only the happy path stays silent through a crash,
and silence looks exactly like "still running". Match every terminal state, or bound the loop tightly
enough that exhaustion tells you something.

**Keep the filter simple enough to be right.** A parsing helper that errors — a quoting bug, a wrong
field path — makes the loop exit early and report a settle that never happened. Prefer `jq` over an
inline script in another language, and verify the filter against one real response before arming.

## Announce every armed watcher as a table

**Arming without announcing is the same failure as not arming** — the user cannot see a background loop,
so an unannounced watcher is indistinguishable from a session that quietly stopped waiting. State it
when armed, again when re-armed, and whenever asked what is running:

| Watcher | Watching for | Cadence | Cap | On wake | Handle |
|---|---|---|---|---|---|
| `pr-4821` | `gh pr view 4821 --json state` returns `MERGED` | 60s | 180 (~3h), then report and re-arm | verify the merge, arm the apply watcher | `task_01H…` |
| `deploy-prod` | all 8 prod pipeline jobs settled | 5m | 24 (2h), then surface as stalled | verify, then open the follow-up MR | `task_01H…` |

- **Watching for** is the done-condition *as it will be tested*, not the topic. "PR merged" is a topic;
  the command and its expected value is a condition. If you cannot write it as a testable line, the
  watcher is not ready to arm.
- **Cadence** matches how fast the signal actually changes. A 5-minute deploy does not need a
  30-second poll.
- **Cap** always states what happens when it is hit, because a watcher that expires silently is worse
  than one that never armed.
- **On wake** is the action it exists to trigger. A watcher with no stated action is an alarm nobody
  answers.
- **Handle** is the task id the runtime returned. **No handle means you detached instead of arming** —
  nothing will wake you.

When `plan-compact` is active, these columns are exactly what its anchor records — copy the row across
rather than writing it twice.

## Announce every watcher that ends, the same way

A watcher that stops is a decision point, not a cleanup detail. Report it the moment it fires, expires,
or is reaped:

| Watcher | Outcome | What the condition actually said | Re-arm? | Next / deviation |
|---|---|---|---|---|
| `pr-4821` | fired | merged at 14:02, CI green | no - done | resumed the rollout; moved the issue to In Review |
| `deploy-prod` | expired at cap | 6 of 8 jobs settled, 2 still queued | yes, cadence 10m | runner capacity looks like the holdup |
| `ci-lint` | reaped | superseded, branch was force-pushed | replaced | new watcher armed on the new head |

- **Fired means the condition was met and verified** — not merely that the loop exited. A loop can exit
  on its own backstop, or on a broken filter; check the artifact before writing "fired".
- **Expired is never silently dropped.** Every expiry ends in an explicit choice: re-arm with a longer
  cadence or cap, escalate, or abandon the wait and say so. Leaving it off the table reads as
  "it completed".
- **Deviation is the valuable column** — the condition met late, partially, or in a way you did not
  predict. That is what changes the next step, and the first thing lost when a watcher is reported as a
  bare "done".
- **Reaped needs its reason** — superseded, moot, or replaced — because a reaped watcher and a fired one
  look identical afterwards.

Never reap a watcher to tidy up before its outcome is in the table. Collect the outcome first;
reaping is terminal.

## Audit the ledger against reality, not against your notes

**What you believe is armed and what is actually running drift apart**, and every mechanism that
causes it is silent. A watcher exits on its cap. A process dies. One was described in a report but
never launched. A replacement was armed without reaping its predecessor, so two now poll the same
condition and can wake you with contradicting answers. None of these announce themselves — the
symptom of all of them is quiet, which is also what a healthy watcher produces.

So **verify, do not recall**. Enumerate what the runtime says is running and compare it against your
ledger, rather than re-reading your own last report and trusting it.

Run the audit:

- **Every time you report armed state.** A table row claiming a watcher is live is a factual claim;
  check it before writing it.
- **On every wake**, before acting on what woke you — including that the waker itself is now spent.
- **Before standing down, parking, or handing off**, per `mode-toggle`. An unexplained live watcher
  at the end of a flow is a bug.

Each row resolves to exactly one of: **live** and still earning its keep, **fired** with its outcome
recorded, **expired** and needing a diagnosis before re-arming, or **deliberately not armed** with
the reason stated. Anything that resolves to none of those is drift, and the fix happens in the same
turn that finds it — re-arm it, reap it, or say why neither.

**A discrepancy is a finding, not a bookkeeping error.** A watcher you thought was live and was not
means the thing it guarded has been unobserved for however long, and whatever you concluded from its
silence was unfounded. Say so plainly rather than quietly re-arming and moving on.

## Anti-patterns

- **Detaching inside the command** (`&`, `nohup`, `disown`) instead of using the runtime's facility —
  the process runs, exits into silence, and nothing wakes you. You made a log file, not a watcher.
- **Re-reading a watcher's output each turn** to see whether it fired. If you are polling the watcher,
  the watcher is not waking you.
- **Reporting a watcher you have not launched.** Describing one, naming what it would poll, or
  intending to arm it after one more check are all "no watcher". It exists when a launch returned a
  handle you can quote, and not before.
- **One watcher over a set of items** — a single loop across five stacks, eight pipelines, or three MRs.
  It can only report "all done", so one stall hides the rest and a failure waits for the slowest sibling.
  One item, one stable id, one watcher.
- **An in-context poll loop** — burning turns on checks a background loop does for free.
- **Arming the whole chain up front** — the later ids do not exist yet, so those watchers key on a guess.
- **Treating a wake as user input.** A notification is never approval, consent, or an answer to a
  pending question.
- **Treating silence as a verdict.** No wake means no information, never a pass.
- **Watching something the harness already tracks.** Work you dispatched (subagents, workflows) reports
  its own completion where the runtime supports it — check the harness reference before arming.
