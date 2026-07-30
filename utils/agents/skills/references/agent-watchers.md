# Agent Watchers

Discipline and concrete recipes for watching an external condition and being woken when it changes. Read this whenever you arm a watcher — from `agent-background` (which owns the launch mechanics), `agent-bulldozer` (never idle), `agent-supervisor` (never drift), or a coordinator covering a wait.

The runtime facility and its parameters live in `harness-<provider>-agent-background`. This file is about *what* to watch, *how often*, and *what a wake means*.

## Discipline

1. **One watcher per independent condition.** Five MRs are five watchers. Bundle only when a gate genuinely cannot move until all of them clear together — otherwise one stalling blinds you to the rest.
2. **Arm it the moment the condition opens**, not when you next remember it. The gap between "the MR is open" and "did it merge?" is where both momentum and tracker accuracy are lost.
3. **Bound every loop.** A cap is a runaway backstop, not a deadline: on exhaustion, report "not met" and re-arm rather than looping forever.
4. **Cadence follows how fast the signal can actually change** (table below). Never poll faster than the state can move; never leave a fast signal unchecked for minutes.
5. **On wake, re-verify authoritatively.** The signal may be a proxy, and proxies lag — a merge can read done before the downstream apply has converged. Do the real check on the main loop before acting on it.
6. **A dead watcher is not an answer.** If it exits without the condition met — cap exhausted, signal broke, process killed — diagnose which, fix that, and re-arm. Never let a lapsed watch silently become "no news".
7. **Reap what you armed**, and reap *before* re-arming a replacement, or duplicates double-wake and can contradict each other. Reap when: the condition fired and you acted, you learned the answer another way, the signal proved unreliable, or the work was superseded.
8. **Account for every live watcher in each report** — what it polls, its cadence, its handle. An unexplained live watcher at the end of a flow is a bug, not diligence.

**Bash cannot call MCP tools.** When the truth is only reachable via MCP (Linear state, ArgoCD through its MCP, Grafana), poll a bash-visible **proxy** and do the authoritative MCP check yourself on wake.

## When to reach for a watcher — broadly

**The trigger is not "a PR is open". It is: something outside this turn will change, and you want to know when.** Three tells, any one of which means arm a watcher:

1. You are about to say *"I'll check back on this later"*.
2. You are about to ask the user to ping you when something happens.
3. You would otherwise re-run the same status command every turn until it changes.

Anything with a bash-checkable signal qualifies — the recipes below are a starting set, not the boundary:

- **Version control** — a merge, a branch moving, a tag or release appearing, a review landing.
- **Pipelines and jobs** — CI, a scheduled job, a long batch run, a cron that must have fired.
- **Infrastructure** — a deploy converging, an apply finishing, a cluster resource going healthy, a certificate or DNS record propagating.
- **Local long work** — a build, a full test suite, a large migration, a big download or import, a compile you started and would otherwise babysit.
- **Artifacts** — a file or report being produced, an image or package published to a registry, a bundle appearing in a bucket.
- **Services and data** — an endpoint coming up, a queue draining, a row count reaching a threshold, a lock releasing, a rate-limit window resetting.
- **People and other agents** — an approval, a reply in a tracker or chat, another team's change landing, work someone else's session is doing.
- **Time-bound conditions** — a window opening (release window, business hours, a maintenance slot ending).

If the truth is not bash-reachable, that is not a reason to skip it — poll a proxy and confirm authoritatively on wake (below). If nothing is pollable at all, say so explicitly rather than quietly deciding to remember.

## Cadence by signal

| Signal | Cadence | Why |
|--------|---------|-----|
| CI run, pipeline job, merge, apply finishing | 15–30 s | Fast, and the whole point is catching it immediately. |
| Deploy or operator convergence (ArgoCD, rollout) | 30–60 s | Reconcile loops run on their own interval. |
| Human action — review, approval, manual gate | 60–300 s | Bounded by a person, not a machine. |
| Long batch job with a known runtime | one check near the expected finish, then tighten | Early checks are pure waste. |
| Remote API with rate limits | ≥ 30 s | A tight loop gets you throttled, not informed. |

## Recipes

A watcher's `<check>` is any command that **exits zero only when the condition holds** — that is the entire contract. Four shapes cover almost everything; arm the same way for any similar condition you need to track.

**State query — a CLI or API reporting a status field** (a merge, a pipeline, a job, a resource going healthy):
```bash
[ "$(some-cli show "$ID" --output json | jq -r .state)" = "$TERMINAL_STATE" ]
```

**Reachability — something coming up or responding:**
```bash
curl -fsS -o /dev/null "$URL"
```

**Appearance — an artifact produced, or a line showing up in a log:**
```bash
[ -s "$ARTIFACT" ] || grep -qE 'DONE|FAILED|Traceback' "$LOGFILE"
```

**Change — a value moving off a known baseline (a ref, a count, a version):**
```bash
[ "$(probe-current-value)" != "$KNOWN_BASELINE" ]
```

**Proxy for MCP-only truth** — poll whatever bash can see, then do the authoritative MCP check on wake.

**Adapt to whatever this environment actually has.** Do not reach for a CLI because it appeared in an example — check what is installed and use that, or fall back to the API over `curl`, or to a filesystem signal. The four shapes above cover nearly everything worth watching; the condition is the point, the tool is incidental.

**Covering failure, not just success.** A check that only matches the happy path stays silent through a crash, and silence looks exactly like "still running". Match every terminal state, or bound the loop tightly enough that exhaustion tells you something.

## Two purposes — momentum and awareness

The mechanics are identical. **What the wake is *for* is not**, and you decide that before arming, because it determines whether the wake fires work.

| | **Momentum watcher** | **Awareness watcher** |
|---|---|---|
| Purpose | Unblock the next action | Keep the record true |
| Typically armed by | `agent-bulldozer`, `agent-coordinator` — anyone pushing work | `agent-supervisor` — anyone who must not be surprised |
| Cadence bias | Tight. Idle time after the blocker cleared is pure waste | Matched to the signal. Being late costs accuracy, not speed |
| On wake | Re-verify, fire the already-staged next step, arm the follow-on | Re-verify, reconcile the tracker and the report, arm the follow-on condition |
| Does it act? | Yes — that is the point | No. It corrects and reports; pushing work needs the user's ask |
| Cost of not arming it | You sit idle while the blocker has long since cleared | Your next report is confidently wrong |

**The same condition can be watched for either reason** — an open MR is a blocker to a bulldozer and a pending fact to a supervisor. Decide which you are arming, and say so when you report it, because "MR merged" means *fire the next stage* to one and *move the issue to Done* to the other.

A coordinator sits between: the wake is a routing decision — re-verify, then decide what gets dispatched next.

## Anti-patterns

- **Detaching inside the command** (`&`, `nohup`, `disown`) instead of using the runtime's facility — the process runs, exits into silence, and nothing wakes you. You made a log file, not a watcher.
- **Re-reading a watcher's output each turn** to see whether it fired. If you are polling the watcher, the watcher is not waking you.
- **An in-context poll loop** — burning turns on checks that a background loop does for free.
- **Treating a wake as user input.** A notification is never approval, consent, or an answer to a pending question.
- **Treating silence as a verdict.** No wake means no information, never a pass.
- **Watching something the harness already tracks.** Work you dispatched (subagents, workflows) reports its own completion where the runtime supports it — check the harness reference before arming.
