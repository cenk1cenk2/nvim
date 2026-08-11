# Commit Trailers

Conventions for referencing and closing issues across platforms, from commit messages and
PR/MR titles and descriptions. Which of those surfaces actually links varies by platform —
Linear ignores commit messages entirely. Check the platform section before assuming.

## Format

Trailers go in the commit footer — separated from the body by a blank line. One trailer per line.

```
<type>(<scope>): <subject>

<body>

<trailer-1>
<trailer-2>
```

## Refs vs Closes

| Trailer | When to use |
|---------|-------------|
| `closes` | **Default.** This commit/PR/MR resolves the issue and nothing else is pending on it — let it auto-close on merge. |
| `refs` | Only when the work is genuinely partial — one of several deliverables, related work, or the issue is still waiting on something after this merges. |

**Default to `closes` (autoclose) — same rule for Linear, GitHub, and GitLab issue links.** If this commit/PR/MR completes the issue's work and nothing else is waiting on the issue, use a closing keyword (`closes`) so the issue auto-closes on merge — do NOT fall back to `refs`/reference-only just because closing intent wasn't spelled out.

**Defer `closes` to the final deliverable.** If additional work, PRs/MRs, or steps are still needed before the issue can actually close, use `refs` (or reference-only) on this one and put the closing keyword ONLY on the last piece that completes it. Never put `closes` on a commit/PR/MR that isn't the final thing — that closes the issue early. Reach for `refs` whenever there is genuinely more to do: another PR/MR pending, a follow-up step, or an explicit hold/wait.

For Linear IDs, choose the trailer from the delivery shape:

- **Default:** `closes <Linear-id>` — this commit/PR/MR fully resolves the issue and nothing else is pending.
- Use `refs <Linear-id>` only when the change is one of several deliverables (this is not the final one) or the issue still has open work after this merges.
- Single PR/MR completing one issue → `closes K-123`.
- Multiple PRs/MRs for one issue → non-final PRs/MRs use `refs K-123`; only the final completing PR/MR uses `closes K-123`.
- One PR/MR can close multiple independent issues. **The syntax differs per platform** — see each platform's "Multiple issues" rule below. Linear takes one keyword followed by a comma-separated list; GitHub requires the keyword repeated per issue.
- Mix `closes` and `refs` when some linked issues are closed and others are only related. On Linear that means one line per kind: `Closes K-1, K-2` and `Refs K-3`.

## Linear

Linear links issues to work via exactly three surfaces: the **branch name**, the
**MR/PR title**, and **magic words in the MR/PR description**.

**Linear cannot link via commit messages or comments.** Linear's integration docs state
this outright. A `(K-123)` in a commit subject is repo convention for human readers — it
creates no Linear link, moves no state, and closes nothing.

Do not generalise across platforms here: GitHub and GitLab *native* issues DO close from
commit messages; Linear does not. Getting this backwards produces a branch whose every
commit names the issue and which still leaves it open on merge.

### Issue ID Formats

| Workspace | Pattern | Example |
|-----------|---------|---------|
| kilic-dev | `K-<number>` | `K-219` |
| Laravel | `CLOUD-<number>` | `CLOUD-4298` |

### Closing Keywords

`close`, `closes`, `closed`, `closing`, `fix`, `fixes`, `fixed`, `fixing`, `resolve`, `resolves`, `resolved`, `resolving`, `complete`, `completes`, `completed`, `completing`, `implement`, `implements`, `implemented`, `implementing`.

### Contributing Keywords (link without closing)

`ref`, `refs`, `references`, `part of`, `related to`, `contributes to`, `towards`.

A contributing keyword still lets the MR/PR drive the issue through the team's configured
workflow statuses; it only suppresses the status automation **on merge**.

### Multiple issues on one MR/PR

**One keyword, then a comma-separated list.** This is the form Linear documents:

```
Closes K-879, K-881
```

Do NOT repeat the keyword per issue for Linear — that is the GitHub form.
Unverified whether repeated keywords also work; the list form is the only shape Linear
documents, so use it.

An issue linked to several MRs/PRs does not close until **all** of them are merged or
closed — so a `closes` on one of several open MRs is not premature the way it would be on
GitHub.

### Put the IDs in the title too

Linear treats a bare issue ID in the MR/PR title as a link — no magic word needed there:

```
fix(scope): subject (K-879, K-881)
```

Title and description linking are independent. Use **both**: the description trailer is
what guarantees the close on merge, and the title keeps the link legible in the MR list
and survives into the squash commit.

### Behavior

- Issue moves to **In Progress** when the branch matching its ID is pushed.
- Issue moves to **Done** when the **MR/PR** carrying a closing keyword merges to the
  default branch — not when a commit merges.
- Contributing keywords such as `refs` link the work but do NOT close the issue on merge.
- The issue ID must appear with a magic word **in the MR/PR description**, or bare in the
  MR/PR title, or in the branch name. Nowhere else counts.

### Trailer Format

```
refs K-219
closes K-383
closes K-879, K-881
closes CLOUD-4298
```

Do NOT use `#` prefix for Linear IDs — `refs K-219`, not `refs #K-219`.

### Detection

When the user provides a Linear reference, detect the issue ID from:

| Source | Detection | Example |
|--------|-----------|---------|
| Direct issue ID | Regex `[A-Z]+-\d+` | `K-219` |
| Linear URL | Extract ID from path | `https://linear.app/kilic-dev/issue/K-219/...` → `K-219` |
| Branch name | Match issue prefix pattern | `k-219` branch → `K-219` |

Fetch issue context via the appropriate Linear MCP tool:
- `K-` prefix → `linear-kilic__get_issue`.
- `CLOUD-` prefix → `linear-laravel__get_issue`.

## GitHub

GitHub closes issues automatically when a commit with a closing keyword is merged to the default branch.

### Closing Keywords

`close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves`, `resolved`.

Case-insensitive. Can be followed by a colon: `closes: #10`.

### Syntax

| Scope | Format | Example |
|-------|--------|---------|
| Same repo | `keyword #NUMBER` | `closes #42` |
| Cross-repo | `keyword OWNER/REPO#NUMBER` | `fixes octo-org/octo-repo#100` |
| Multiple | Repeat keyword per issue | `resolves #10, resolves #123` |

### Referencing Without Closing

Mention `#NUMBER` in the body without a closing keyword — GitHub auto-links it. GitHub has NO dedicated `refs` / `references` keyword: a bare `#N` (optionally after a phrase like "part of") links but never closes; only the closing keywords above close.

Follow the **Refs vs Closes** default above: use a closing keyword (`closes #N`) by default when this PR resolves the issue and nothing else is pending; reference-only (a bare `#N`) when the work is partial — deferring the closing keyword to the final PR.

### Trailer Format

```
closes #42
#17
```

(`#17` is reference-only — links, does not close.) Fetch issue context via `github__issue_read` or `github__pull_request_read`.

## GitLab

GitLab closes issues when a commit or MR with a closing keyword is merged to the default branch.

### Closing Keywords

`close`, `closes`, `closed`, `closing`, `fix`, `fixes`, `fixed`, `fixing`, `resolve`, `resolves`, `resolved`, `resolving`, `implement`, `implements`, `implemented`, `implementing`.

Case-insensitive.

### Syntax

| Scope | Format | Example |
|-------|--------|---------|
| Same project | `keyword #NUMBER` | `closes #4` |
| Cross-project | `keyword GROUP/PROJECT#NUMBER` | `fixes backend/api#20` |
| Full URL | `keyword URL` | `closes https://gitlab.example.com/group/project/-/issues/123` |
| Multiple | Comma-separated | `closes #4, #6` |

### Referencing Without Closing

`related to #5` — marks as related but does not close.

Follow the **Refs vs Closes** default above: use a closing keyword (`closes #N`) by default when this MR resolves the issue and nothing else is pending; `related to #N` when the work is partial — deferring the closing keyword to the final MR.

### Trailer Format

```
closes #4
related to #5
```

Fetch issue context via `gitlab__get_issue` or `gitlab__get_merge_request`.
