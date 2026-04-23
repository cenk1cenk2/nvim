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
| User picks up an issue (`linear-issue-implement`, `linear-next-task`, `linear-triage` promote) | `In Progress` | the pickup skill itself (already wired). |
| A worker is dispatched for a Linear-linked task (`agents-delegate`, `agents`) | `In Progress` | the dispatch skill before launching the agent. |
| An MR/PR is created that references the issue (`refs K-xxx` / `closes K-xxx` in commit trailers or MR body) | `In Review` | `gitlab-mr` / `github-pr` after successful MR/PR create. |
| An MR/PR merges | `Done` | `linear-issue-comment` when posting the delivery comment against a merged MR/PR. |
| An MR/PR is closed without merging | *no change* | never auto-advance on close — user decides whether to cancel the issue. |

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

## Issue-id extraction from commits

When a skill processes a branch / MR / PR rather than a single issue,
it extracts Linear ids from commit messages and MR/PR bodies:

- **Commit trailer syntax:** `refs K-xxx`, `closes K-xxx`,
  `fixes K-xxx`, `resolves K-xxx` — case-insensitive, stops at
  newline. One id per line of trailer, but a line can repeat the
  same id.
- **MR/PR body:** the `closes K-xxx` / `refs K-xxx` trailer at the
  bottom, or a `K-xxx` mentioned inline (less reliable — only
  mentioned at the top near the summary is treated as a trigger id).
- **Regex target:** `/(?:^|\s)(K|CLOUD)-\d+/i` — match the team
  prefixes the current workspace supports. Check `linear-prerequisite`
  for the active workspace's id prefix.
- Dedupe ids before transitioning — one `save_issue` call per unique
  id.

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

> **PREREQUISITE: A Linear workspace skill MUST be active before
> calling `save_issue`.**
>
> Auto-invoke the matching workspace skill when the trigger surfaces
> an issue id:
>
> - **kilic-dev workspace** (K-xxx): `skills://skill/linear-kilic`
> - **Laravel workspace** (CLOUD-xxx): `skills://skill/linear-work`
>
> Route through the workspace's own `save_issue` tool name — they
> use the same API but different MCP server prefixes.
