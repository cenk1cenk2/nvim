# Linear State Transitions

Automatic state transitions that skills apply silently whenever they touch a
Linear-linked workflow. Read this alongside `linear-issue-states.md` —
that reference defines the state machine; this one defines the
*triggers* that advance an issue along it.

## Scope

Applies to any skill that wraps a meaningful lifecycle moment for a
Linear issue (pickup, worker dispatch, MR/PR creation, merge,
post-merge comment). The issue itself does not drive state — the
**action** does.

## Trigger → target table

| Trigger | Target state | Applied by |
|---|---|---|
| User picks up an issue (`linear-pickup`, `linear-next-task`, `linear-triage` promote) | `In Progress` | the pickup skill itself. |
| A worker is dispatched for a Linear-linked task (`agent-delegate`, `agent-plan`) | `In Progress` | the dispatch skill before launching the agent. |
| User or workflow explicitly updates status (`linear-issue-status`) | requested state | `linear-issue-status`, respecting never-downgrade and terminal-state guards. |
| An MR/PR is created that links the issue (a contributing or closing keyword, or the id in its title or branch) | `In Review` | `gitlab-mr-create` / `github-pr-create` after successful MR/PR create. |
| A merged MR/PR carries a Linear closing keyword for the issue | `Done` | `linear-issue-comment` when posting the delivery comment against a merged MR/PR, or `linear-project-match` when reconciling merged work. |
| A merged MR/PR only links the issue with a contributing keyword | *no automatic Done transition* | a contributing keyword means related or partial work; user decides whether remaining scope is complete. |
| An MR/PR is closed without merging | *no change* | never auto-advance on close — user decides whether to cancel the issue. |

## Closing vs reference semantics

Contributing keywords and bare issue mentions are link signals only. They can
advance an issue to `In Review` when an MR/PR opens, but they MUST NOT
drive a `Done` transition when the MR/PR merges.

Closing keywords are close signals. When an MR/PR mentions multiple
Linear IDs, apply `Done` only to IDs linked by a closing keyword; keep
contributing IDs out of the `Done` transition unless the user
explicitly says to close them.

Both keyword lists, per platform, are `commit-trailers-linear`.

## Never-downgrade invariant

`linear-issue-states.md` bans moving an issue to a lower state. Every
trigger here is a **monotonic forward move**. Before calling
`save_issue`, skills MUST check the current `statusType`:

- `statusType: "completed"` (Done) → skip the transition entirely. A
  `save_issue` would downgrade.
- `statusType: "canceled"` → skip. The issue is terminal.
- `statusType: "started"` (`In Progress` or `In Review`) vs the
  target state → only write if the target is the same or higher in
  the hierarchy from `linear-issue-states.md`.
- `statusType: "unstarted"` or `"backlog"` → always safe to advance.

Pseudocode the calling skill should apply:

```
current = get_issue(id).statusType
if current in ("completed", "canceled"):  skip
if target_rank <= current_rank:           skip  # downgrade guard
save_issue(id, state=target)
```

The rank order is: `backlog`/`unstarted` < `In Progress` < `In Review`
< `Done` / `Canceled`.

## Issue-id extraction

When a skill processes a branch / MR / PR rather than a single issue,
it extracts Linear ids from the MR/PR title and body, the branch name,
and — on GitHub only — commit messages:

- **Trailer syntax:** match contributing and closing keywords
  case-insensitively, stopping at newline, using the platform's lists.
- **A keyword applies to EVERY id in its comma/`and`-separated run,
  not just the first.** `Closes K-879, K-881` closes *both*. Parse the
  run to end-of-line and tag every id in it with that keyword's kind.
  Matching only the id adjacent to the keyword leaves the rest
  classified as bare mentions, which silently skips their `Done`
  transition — the MR merges, one issue closes, the others sit open
  looking like the automation is broken.
- **MR/PR body:** the keyword trailer at the
  bottom, or a `K-xxx` mentioned inline (less reliable — only
  mentioned at the top near the summary is treated as a trigger id).
- **MR/PR title:** ids there are a real Linear linking surface — parse
  them too, e.g. `fix(scope): subject (K-879, K-881)`. Treat a bare
  title id as a *link*, not a close signal; the closing kind still
  comes from the description trailer.
- **Commit messages link on GitHub only.** On GitLab, Linear never
  links via commit messages — a commit-only id there is a discovery hint
  for which issues a branch touches, never evidence Linear will move or
  close it. On GitHub, a keyword before the id in a commit message links
  and moves the issue when the workspace has commit linking enabled; a
  bare id in a commit still does not.
- **Regex target:** `/(?:^|\s)(K|CLOUD)-\d+/i` — match the team
  prefixes the current workspace supports. Check `linear-prerequisite`
  for the active workspace's id prefix.
- Dedupe ids before transitioning — one `save_issue` call per unique
  id.
- Preserve the match kind (`reference` vs `closing`) when the target
  state is `Done`. Open MR/PR transitions to `In Review` use both
  kinds; merged MR/PR transitions to `Done` use closing matches only.

When zero Linear ids are found, the skill skips the transition step
silently — no warning. Not every branch is tied to a Linear issue.

## Silent-with-report contract

Transitions are applied **without interrupting the user** and
reported in the skill's normal summary output. Format for reporting:

```
Linear state: moved K-240 → In Review (was Todo).
Linear state: K-241 already Done, skipped downgrade.
```

- One line per issue touched (or skipped).
- Always say the *target* + *prior* state so the user can spot
  misfires at a glance.
- If the transition fails (MCP error, not-found, permissions), log a
  warning line and continue — never fail the whole skill over a
  state transition.

## Opt-out

The user can suppress auto-transitions for a single invocation by
saying "don't move the Linear state" / "skip the state update" / "I'll
flip the state myself" in the same turn that triggered the skill. The
skill reports: `Linear state: auto-transition suppressed by user.`
Per-session / persistent opt-out is out of scope — one-turn only.

## Workspace prerequisite

The workspace skill for the surfaced issue id must be active before
`save_issue`, per `linear-prerequisite`.
