---
name: linear-status
description: linear-status Move Linear state forward on evidence and keep checklists honest - one issue's state, its checklist items, or a whole project matched to merged PRs/MRs and what the user did. Use on "mark K-123 done", "move it to in review", "tick items", "check off this item", "match Linear to reality". Not for editing a description, leaving a comment, or a structure audit.
argumentHint: '[issue id, project, or URL] [target state, items, or evidence: PR/MR URLs, repos, ''recent merged'', notes]'
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear/linear-prerequisite.md
  - ../references/linear/linear-issue-states.md
  - ../references/linear/linear-state-transitions.md
  - ../references/linear/linear-description-structure.md
  - ../references/scm/commit-trailers-linear.md
  - ../references/scm/scm-detect.md
  - ../references/scm/scm-github.md
  - ../references/scm/scm-gitlab.md
  - ../references/output-diff.md
  - ../references/identifier-legibility.md
---

Issues, MRs and PRs carry their title and link, per `identifier-legibility`.

## Linear Status

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

State semantics and the never-downgrade rule: `linear-issue-states`. Triggers, the monotonic guard, issue-id extraction, closing vs contributing semantics, the report line, and the opt-out wording: `linear-state-transitions`. Every proposal at every scope passes that guard.

## Scope

| Scope | Members | Resolve it with | Depth |
|---|---|---|---|
| Issue | one issue's workflow state, then its checklist | `get_issue` | the state, status type, title, description, and checklist |
| Checklist | the checklist lines of one issue's description | `get_issue`, then `list_comments` | every checklist item, plus comments that report items completed, cancelled, or changed |
| Project | every issue in the project, against outside evidence | `list_issues` with the `project` parameter, then the evidence sources | a `{title, status, statusType, updatedAt}` baseline per issue, correlated with each evidence signal |

- **Resolve the scope first and name which one you resolved.** A request naming items to tick is checklist scope; a request naming a target state is issue scope; a request naming a project or a batch of PRs/MRs is project scope.
- **This skill moves state and checklist lines only.** Title, description, labels, priority, estimate, and relation changes are out of scope.

## Close-Out

**The checklist is part of close-out.** Whenever an issue moves to `In Review` or `Done`, at any scope, inspect its checklist:

- Mark items done that the current work clearly completed. **Close-out exception** — inside a status move or a pickup workflow, clear implementation evidence marks items done without a second confirmation.
- When the issue moves to `Done`, remaining items that are implementation acceptance criteria with no contrary evidence are marked done unless the user says not to.
- Leave ambiguous, canceled, or out-of-scope items untouched and report them.
- **Cancel an item only on explicit user wording.** Never assume it.

Equally, when a standalone checklist update completes the implementation or puts it into review, move the issue to `In Review` or `Done` through the issue scope here.

## Verbal State Mapping

| User wording | Target |
|---|---|
| "backlog", "park for later" | `Backlog`. |
| "todo", "next", "ready" | `Todo`. |
| "start", "working", "in progress", "picked up", "working on X" | `In Progress`. |
| "review", "PR open", "MR open", "awaiting review" | `In Review`. |
| "done", "complete", "merged", "shipped", "finished X" | `Done`. |
| "cancel", "drop", "won't do", "not needed", "dropped/parked/descoping X" | `Canceled` — a candidate that always needs confirmation. |

Set `Triage` only when the user explicitly asks for it.

## Process — Issue Scope

1. **Identify the issue** from an id or Linear URL in the prompt or active context, and fetch it per the Scope table. If none is identifiable, ask for the id.
2. **Resolve the target state** from explicit user wording first, per the Verbal State Mapping. When the state is only inferred from the situation, apply the monotonic transitions (`In Progress`, `In Review`, `Done`) when the evidence is clear; otherwise ask.
3. **Apply guardrails.** Never downgrade — explain the rule and leave the state as is. `Canceled` is terminal and needs explicit wording or confirmation. Skip issues already `Done` or `Canceled` unless the user explicitly requests a supported change.
4. **Update the state.** An explicitly requested state is applied directly and reported. An inferred one is presented per `output-diff` and applied only when the evidence is clear or the user confirms. Report with the `linear-state-transitions` line.
5. **Close out** per the Close-Out section when the target is `In Review` or `Done`.

## Process — Checklist Scope

1. **Fetch the issue and its comments** per the Scope table, and extract the current checklist from the description.
2. **Present the checklist** per `output-diff` and confirm which items to update. The Close-Out exception skips this confirmation.
3. **Apply** only after confirmation, as a `patch` touching only the checklist lines — done, canceled, and pending markup and the patch rules per `linear-description-structure`. Preserve all other issue content.
4. **Hand off state** per the Close-Out section when the update completes the implementation or puts it into review.

## Process — Project Scope

Linear drifts from reality: an MR merges but the issue stays `In Progress`, a task is silently dropped but sits in `Todo`, the user finishes three issues in an afternoon and never clicks Done. This scope pulls outside evidence, correlates it with the project's open issues, and proposes the transitions that bring Linear in line.

### Step 1: Baseline the project

Fetch the issues per the Scope table and report the issue count and current state distribution.

### Step 2: Gather evidence

Use only the sources the user named. If none is named, ask — never fall back to "everything recent".

| Source | How to gather | Signals extracted |
|--------|---------------|-------------------|
| User statements | Inline in the invocation ("I finished K-45, dropped K-67, still working on K-89") | Issue ids plus verbal state per the Verbal State Mapping. |
| Merged or open MRs | `gitlab__list_merge_requests` (merged, recent) or given URLs via `gitlab__get_merge_request` | Branch name, title, description, state, and each id's kind. |
| Merged or open PRs | `github__list_pull_requests` (merged, recent) or given URLs via `github__pull_request_read` | Branch name, title, body, state, and each id's kind. |
| Notes / docs | Pasted content or a file the user points to | Issue ids mentioned inline plus prose hints ("shipped X", "parked Y"). |

- Determine GitHub vs GitLab from the repo URL per `scm-detect`, then pick the MCP tools from `scm-github` or `scm-gitlab`.
- Extract ids and their kind (reference vs closing) from each MR/PR per the extraction rules in `linear-state-transitions`, closing keywords per `commit-trailers-linear`. Dedupe per MR/PR and record `{url, state, referenced-issue-ids, closing-issue-ids, title}`.
- A statement naming work but no issue ("I finished the auth migration") is matched against issue titles by keyword, and the match is confirmed with the user before use.

### Step 3: Correlate and propose

For each issue, collect every matching signal — a direct id match, or a weaker keyword match on title.

- **MR/PR signals** map to a target per the trigger table in `linear-state-transitions`: a closing keyword on merged work proposes `Done`, an open MR/PR proposes `In Review`, a contributing-only merge or a closed-unmerged MR/PR proposes nothing and is flagged.
- **User statements and notes** map per the Verbal State Mapping. A `Done` from a statement still needs the user's confirmation.
- **Keyword-only matches** propose nothing; surface them as candidates.
- **No evidence** — skip silently.

### Step 4: Present the proposal

Per `output-diff`, one chunk per issue — the evidence, then the transition:

````
### K-123 — Add cert-manager to the cluster
Evidence: merged MR https://gitlab.example.com/.../merge_requests/42 (closes K-123). Issue is currently In Progress.

```diff
- state: In Progress
+ state: Done
```
````

Group by target state — Done, In Review, In Progress, Canceled candidates needing confirmation, flagged ambiguities — and close with the unchanged issues and the skipped would-be downgrades.

### Step 5: Iterate and apply

- The user approves all, some, or none, and may edit targets inline ("K-123 should be In Review, not Done — haven't deployed yet").
- Confirm each `Canceled` once more before writing it.
- Apply the approved transitions in parallel `save_issue` calls, then close out each issue per the Close-Out section.
- Report:

```
## Project Status Applied: <project-name>

### Applied transitions
- K-123 → Done (was In Progress). Evidence: MR !42.
- K-125 → Canceled (was Todo). Evidence: user stated "dropped this week". [User-confirmed.]

### Unchanged
- K-130, K-131: no evidence found this run.

### Still needs user attention
- K-127: keyword-match candidate to PR #89 — user declined.
- K-128: MR !50 closed without merging — user decision needed.
```

## Key Rules

- **Fast path for explicit status.** If the user says exactly which state to use, apply it without a planning detour.
- **Evidence over convenience.** Every inferred transition cites a source the user can verify; when none exists, ask instead of guessing.
- **A contributing keyword is not completion.** Only a closing keyword, per `commit-trailers-linear`, justifies `Done` from merged work.
- **Confirm cancellations.** `Canceled` is terminal — for an issue and for a checklist item alike.
- **Ask one focused question** when the issue, the target state, or the terminal semantics are unclear.
