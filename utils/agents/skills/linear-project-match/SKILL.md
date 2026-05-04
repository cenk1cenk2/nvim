---
name: linear-project-match
description: Reconcile Linear issue states in a project against external reality — user statements, merged GitLab MRs, merged GitHub PRs, or user-provided notes/docs. Extract signals (issue ids in trailers/branch names, title keyword matches, user's verbal reports), propose state transitions per issue with evidence, apply in batch after approval. Use when user says "match linear to reality", "clean up issue states", "reconcile with recent MRs/PRs", "I did X, Y, Z — update linear", or when composing with /linear-project-revisit to act on mismatches. Do NOT use for auditing project structure/priorities/estimates (/linear-project-update) or deep per-issue revisit (/linear-issue-revisit).
interaction: chat
argument-hint: "[project-name or Linear URL] [evidence sources: MR/PR URLs, repo names, 'recent merged', user statements, notes]"
references:
  - ../references/scm-detect.md
  - ../references/scm-github.md
  - ../references/scm-gitlab.md
  - ../references/linear-state-transitions.md
  - ../references/output-diff.md
---

## system

### Linear Project Match

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Gather all evidence sources (Linear issues + external inputs) before proposing changes.
> - Present proposals per issue with inline evidence.
> - **NEVER modify issue state without user approval.**
> - Iterate on the proposal list; apply in batch after approval.

### Prerequisite

> **PREREQUISITE: A Linear workspace skill MUST be active before this skill runs.**
>
> If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:
> - **kilic-dev workspace:** Load skill `linear-kilic` via the `linear-kilic` skill (load it as defined in `load-skills`)
> - **Laravel workspace:** Load skill `linear-work` via the `linear-work` skill (load it as defined in `load-skills`)
>
> Deduce the workspace from context: issue ID prefixes (K-xxx → kilic-dev, CLOUD-xxx → Laravel), Linear URLs, repository hosting (GitLab → kilic-dev, GitHub → Laravel). If a full Linear URL is provided, deduce the workspace from the URL directly.

> Read the `scm-detect` reference to determine GitHub vs GitLab from repo URL before pulling MR/PR data.
> Read `scm-github` or `scm-gitlab` based on detection to pick the right MCP tools.
> Read the `linear-state-transitions` reference for the monotonic-forward-move rule; every state proposal MUST pass the never-downgrade guard.
> Read the `output-diff` reference for chat output conventions before writing to Linear — present proposals in logical chunks for approval.

### Purpose

Linear's ground truth drifts from reality: an MR merges but the issue stays `In Progress`; a task gets silently dropped but the issue still sits in `Todo`; the user finishes three issues in an afternoon and forgets to click Done. This skill pulls external evidence, correlates it with open issues in a project, and proposes the state transitions needed to bring Linear in line with what actually happened.

**Composability:**

- **Standalone:** user invokes with evidence sources ("check these merged PRs", "I finished X Y Z, clean up states").
- **After `linear-project-revisit`:** that skill flags mismatched states; `linear-project-match` is the natural follow-up to act on them.
- **Inside other workflows:** can be chained from PR/MR-close hooks or cycle cleanup flows.

### Evidence Sources

The skill accepts any combination:

| Source | How to gather | Signals extracted |
|--------|---------------|-------------------|
| User statements | Inline in invocation ("I finished K-45, dropped K-67, still working on K-89") | Direct issue IDs + verbal state ("finished" → Done, "working on" → In Progress, "dropped" → Canceled candidate). |
| Merged MRs | `gitlab__list_merge_requests` (filter: merged, recent) or user-provided URLs via `gitlab__get_merge_request` | Branch name, commit trailers (`refs K-xxx`, `closes K-xxx`), MR title/description, MR state (merged/open/closed). |
| Merged PRs | `github__list_pull_requests` (filter: merged, recent) or user-provided URLs via `github__pull_request_read` | Branch name, commit trailers, PR title/body, PR state. |
| Notes / docs | User pastes content or points to a file | Issue IDs mentioned inline + prose hints ("shipped X", "parked Y"). |

### Process

#### Step 1: Identify project scope

- Parse the project name or URL from the user's invocation.
- Fetch project issues via `list_issues` with the `project` parameter. Build a dict keyed by issue ID with `{title, status, statusType, updatedAt}`.
- Report the issue count and current state distribution as a baseline.

#### Step 2: Gather evidence

For each evidence source the user named (or offered), gather:

- **User statements:** parse into `{issue-id: verbal-state}` pairs. If a statement references work without naming an issue (e.g., "I finished the auth migration"), attempt to match against issue titles by keyword; ask the user to confirm the match before using it.
- **MRs/PRs:** fetch each one. Extract issue IDs from:
  - Branch name (regex: `/(K|CLOUD)-\d+/i` — use the workspace's id prefix from `linear-prerequisite`).
  - Commit trailers in the MR/PR commits: `refs K-xxx`, `closes K-xxx`, `fixes K-xxx`, `resolves K-xxx` (case-insensitive).
  - MR/PR body trailer lines.
  - MR/PR title if it contains an issue id.
  Dedupe per unique MR/PR. Record: `{mr-or-pr-url, state, issue-ids, title}`.
- **Notes/docs:** grep for issue ids; capture surrounding prose as context.

If no evidence source is named, ask the user what to use — don't silently fall back to "everything recent" (noisy and expensive).

#### Step 3: Correlate evidence with issues

For each issue in the project, find matching evidence:

- **Direct match:** issue id appears in evidence.
- **Keyword match (weaker):** issue title keywords appear in MR/PR title or user statement prose. Treat as a candidate, not a confirmed match — flag for user confirmation.

Record the evidence per issue as a list (an issue may have multiple signals — e.g., an MR + a user statement).

#### Step 4: Propose state transitions

Apply these rules, in order, per issue. Respect the **never-downgrade guard** from `linear-state-transitions`: only propose monotonic forward moves on the status rank (`backlog`/`unstarted` < `In Progress` < `In Review` < `Done` / `Canceled`). Skip any proposal that would move backward.

| Evidence signal | Proposed state | Notes |
|-----------------|---------------|-------|
| Merged MR/PR references issue, issue is `In Progress` or `In Review` | `Done` | High-confidence forward move. |
| Open MR/PR references issue, issue is `Todo` or `In Progress` | `In Review` | Forward move. |
| User statement "finished/shipped/done with X", issue not already closed | `Done` | Requires user confirmation (user could be imprecise). |
| User statement "working on X", issue is `Todo` or `Backlog` | `In Progress` | Forward move. |
| User statement "dropped/parked/descoping X", issue not closed | `Canceled` (ask first) | Treat as canceled-candidate — always ask before cancelling. |
| Closed MR/PR (not merged) references issue | no auto-proposal | Closure without merge is ambiguous — flag for user decision. |
| Keyword match only (no direct id) | no auto-proposal | Surface as "candidate match" — user confirms. |
| No evidence touches the issue | no change | Skip silently. |

#### Step 5: Present the proposal

Format per the `output-diff` reference — one logical chunk per issue, each with reasoning + the proposed transition in a fenced block.

```
### K-123 — Add cert-manager to cluster-rubik
Evidence: merged MR https://gitlab.com/.../merge_requests/42 (closes K-123). Issue is currently In Progress.

```diff
- state: In Progress
+ state: Done
```
```

Group issues by proposed target state (Done candidates, In Review candidates, In Progress candidates, Canceled candidates requiring confirmation, flagged ambiguities).

At the bottom, summarise unchanged issues (not enough evidence) and explicit no-ops (would-be downgrades, skipped).

#### Step 6: Iterate and apply

- User approves all, some, or none. They can edit target states inline ("K-123 should be In Review, not Done — haven't deployed yet").
- Apply approved transitions in batch via parallel `save_issue` calls.
- For each applied transition, report one line (matches the `linear-state-transitions` silent-with-report format): `Linear state: moved K-123 → Done (was In Progress). Evidence: MR !42.`
- For canceled candidates, confirm once more before dispatching the `save_issue` call — cancellation is a terminal move.

### Key Rules

- **Never move backward.** Respect the never-downgrade guard from `linear-state-transitions`. Done/Canceled are terminal; don't propose transitions that would reverse them.
- **Evidence over convenience.** Every proposed transition must cite an evidence source the user can verify. Unsourced proposals are a failure mode — flag and ask instead of guessing.
- **Confirm cancellations.** `Canceled` is terminal. Always get explicit approval before cancelling, even when the user said "dropped".
- **Keyword matches are candidates, not matches.** If you can't find a direct issue-id reference, surface it as a candidate for the user to confirm.
- **Batch application.** Apply approved transitions in parallel `save_issue` calls to minimise round trips.
- **No scope creep.** This skill only moves issue states. For priority/estimate/label/description changes, refer the user to `linear-project-update`.

### Report Format (final summary after apply)

```
## Project Match Applied: <project-name>

### Applied transitions
- K-123 → Done (was In Progress). Evidence: MR !42.
- K-124 → In Review (was Todo). Evidence: open MR !45.
- K-125 → Canceled (was Todo). Evidence: user stated "dropped this week". [User-confirmed.]

### Unchanged
- K-130, K-131: no evidence found this run.

### Still needs user attention
- K-127: keyword-match candidate to PR #89 — user declined.
- K-128: MR !50 closed without merging — user decision needed.
```

### Related Skills

- **`linear-project-revisit`** — read-only project survey. Surfaces mismatched states; this skill acts on them.
- **`linear-project-update`** — audit + modify project structure (priorities, estimates, labels). Complementary scope.
- **`linear-issue-update`** — update a single issue's fields (any field, not just state). Use when the match involves more than a state transition.
- **`linear-state-transitions`** (reference) — defines the forward-move rank order and the never-downgrade guard.
