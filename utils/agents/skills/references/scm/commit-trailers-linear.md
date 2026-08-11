# Commit Trailers — Linear

How a Linear issue links to work and closes on merge. Shared `closes` versus `refs` policy is in `commit-trailers`; this file covers only Linear's own surfaces and keywords.

Linear links issues to work via exactly three surfaces: the **branch name**, the **MR/PR title**, and **magic words in the MR/PR description**.

**Linear cannot link via commit messages or comments.** Linear's integration docs state this outright. A `(K-123)` in a commit subject is repo convention for human readers — it creates no Linear link, moves no state, and closes nothing.

Do not generalise across platforms here: GitHub and GitLab *native* issues DO close from commit messages; Linear does not. Getting this backwards produces a branch whose every commit names the issue and which still leaves it open on merge.

## Issue ID Formats

| Workspace | Pattern | Example |
|-----------|---------|---------|
| kilic-dev | `K-<number>` | `K-219` |
| Laravel | `CLOUD-<number>` | `CLOUD-4298` |

## Closing Keywords

`close`, `closes`, `closed`, `closing`, `fix`, `fixes`, `fixed`, `fixing`, `resolve`, `resolves`, `resolved`, `resolving`, `complete`, `completes`, `completed`, `completing`, `implement`, `implements`, `implemented`, `implementing`.

## Contributing Keywords (link without closing)

`ref`, `refs`, `references`, `part of`, `related to`, `contributes to`, `towards`.

A contributing keyword still lets the MR/PR drive the issue through the team's configured workflow statuses; it only suppresses the status automation **on merge**.

## Multiple issues on one MR/PR

**One keyword, then a comma-separated list.** This is the form Linear documents:

```
Closes K-879, K-881
```

Do NOT repeat the keyword per issue for Linear — that is the GitHub form. Unverified whether repeated keywords also work; the list form is the only shape Linear documents, so use it.

Mixed kinds get one line each: `Closes K-879, K-881` and `Refs K-884`.

An issue linked to several MRs/PRs does not close until **all** of them are merged or closed — so a `closes` on one of several open MRs is not premature the way it would be on GitHub.

## Put the IDs in the title too

Linear treats a bare issue ID in the MR/PR title as a link — no magic word needed there:

```
fix(scope): subject (K-879, K-881)
```

Title and description linking are independent. Use **both**: the description trailer is what guarantees the close on merge, and the title keeps the link legible in the MR list and survives into the squash commit.

## Behavior

- Issue moves to **In Progress** when the branch matching its ID is pushed.
- Issue moves to **Done** when the **MR/PR** carrying a closing keyword merges to the default branch — not when a commit merges.
- Contributing keywords such as `refs` link the work but do NOT close the issue on merge.
- The issue ID must appear with a magic word **in the MR/PR description**, or bare in the MR/PR title, or in the branch name. Nowhere else counts.

## Trailer Format

```
refs K-219
closes K-383
closes K-879, K-881
closes CLOUD-4298
```

Do NOT use `#` prefix for Linear IDs — `refs K-219`, not `refs #K-219`.

## Detection

When the user provides a Linear reference, detect the issue ID from:

| Source | Detection | Example |
|--------|-----------|---------|
| Direct issue ID | Regex `[A-Z]+-\d+` | `K-219` |
| Linear URL | Extract ID from path | `https://linear.app/kilic-dev/issue/K-219/...` gives `K-219` |
| Branch name | Match issue prefix pattern | `k-219` branch gives `K-219` |

Fetch issue context via the appropriate Linear MCP tool:

- `K-` prefix → `linear-kilic__get_issue`.
- `CLOUD-` prefix → `linear-laravel__get_issue`.
