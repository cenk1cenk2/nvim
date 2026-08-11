---
name: agent-watcher-recipes
description: agent-watcher-recipes Concrete watcher signals per domain and the shell checks that poll them - merge gates, CI runs, terraform and Spacelift, deploy convergence, chaining, tracker reconciliation. Load the entry for the thing you are about to watch. Not for watcher discipline, cadence, or the announce tables.
---

# Agent Watcher Recipes

Concrete signals per domain, and the shell checks that poll them. Read the entry for the thing you are about to watch; skip the rest.

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

