# Commit Trailers — Linear

How a Linear issue links to work and closes on merge. Shared `closes` versus `refs` policy is in `commit-trailers`; this file covers only Linear's own surfaces and keywords. **Whether to link at all is decided first, per `scm-linear-follow-up`** — every surface below moves the issue, including one that is already Done.

Linear links issues to MRs/PRs via three surfaces: the **branch name**, the **MR/PR title**, and **magic words in the MR/PR description**.

**On GitLab, Linear cannot link via commit messages or comments.** Linear's GitLab docs state this outright. A `(K-123)` in a commit subject is repo convention for human readers — it creates no Linear link, moves no state, and closes nothing. On GitHub, a magic word before the ID in a commit message does link and move the issue when the workspace has commit linking enabled; a bare ID still does not.

Do not generalise across platforms here: GitHub and GitLab *native* issues DO close from commit messages; Linear on GitLab does not. Getting this backwards produces a branch whose every commit names the issue and which still leaves it open on merge.

## Issue ID Formats

| Workspace | Pattern | Example |
|-----------|---------|---------|
| kilic-dev | `K-<number>` | `K-219` |
| Laravel | `CLOUD-<number>` | `CLOUD-4298` |

## Closing Keywords

`close`, `closes`, `closed`, `closing`, `fix`, `fixes`, `fixed`, `fixing`, `resolve`, `resolves`, `resolved`, `resolving`, `complete`, `completes`, `completed`, `completing`, `implement`, `implements`, `implemented`, `implementing`.

## Contributing Keywords (link without closing)

Linear documents a different list per platform. Pick from the list for the platform the MR/PR lives on, never from memory.

- **GitLab:** `ref`, `references`, `part of`, `related to`, `contributes to`, `towards`, `updates`.
- **GitHub:** `ref`, `refs`, `references`, `part of`, `contributes to`, `toward`, `towards`.

`refs` is on the GitHub list only. Copied onto a GitLab MR description out of GitHub habit, it may produce no link at all - on GitLab write `References`, or `Part of` when the close is explicitly deferred per Choosing the Keyword.

A contributing keyword still lets the MR/PR drive the issue through the team's configured workflow statuses; it only suppresses the status automation **on merge**. It therefore reopens a Done issue when the MR/PR opens — a follow-up to a closed issue uses none of these, per `scm-linear-follow-up`.

## Relation Keywords (GitHub only)

`relates to`, `related to` — link with no status change. Linear documents these only for GitHub; on GitLab `related to` is a contributing keyword above. `skip <ID>` or `ignore <ID>` prevents the link, also documented only for GitHub.

## Choosing the Keyword

| Shape of work | Write | Note |
|---|---|---|
| Satisfies the implementation of the issue it is named for | `Closes K-xxx` | Moves the issue to Done on merge. Pending verification does not change this. |
| The user explicitly deferred the close ("we will verify and close after"), or known work beyond verification remains | `Part of K-xxx` | Contributing word on both platforms - links without closing. |
| Mentions another issue it does not close | `Refs K-xxx` | `refs` is GitHub-documented only. Fine on GitHub; on GitLab write `References K-xxx`. |
| Several issues of the same kind | One keyword, comma-separated list | Per Multiple issues below. |

**Verification never makes work partial.** An MR that satisfies the implementation closes the issue, even when the issue text asks for verification. Verification happens after Done, or as its own follow-up issue when explicitly needed. A closed issue is not frozen - it reopens to In Review or In Progress if something does not work as intended - so closing with verification outstanding is not premature. `Part of` is reserved for an explicitly user-deferred close or explicitly known remaining work.

On GitLab the keyword goes in the MR description, not the commit message - per Behavior below.

## Multiple issues on one MR/PR

**One keyword, then a comma-separated list.** This is the form Linear documents:

```
Closes K-879, K-881
```

Do NOT repeat the keyword per issue for Linear — that is the GitHub form. Unverified whether repeated keywords also work; the list form is the only shape Linear documents, so use it.

Mixed kinds get one line each: `Closes K-879, K-881` and `Part of K-884`.

An issue linked to several MRs/PRs does not close until **all** of them are merged or closed — so a `closes` on one of several open MRs is not premature the way it would be on GitHub.

## Put the IDs in the title too

For an issue this MR/PR delivers, Linear treats a bare issue ID in the MR/PR title as a link — no magic word needed there:

```
fix(scope): subject (K-879, K-881)
```

Title and description linking are independent. Use **both**: the description trailer is what guarantees the close on merge, and the title keeps the link legible in the MR list and survives into the squash commit.

## Behavior

- Issue moves to **In Progress** when the branch matching its ID is pushed, or when a linked MR/PR opens per the team's workflow settings — Done included.
- Issue moves to **Done** when the **MR/PR** carrying a closing keyword merges to the default branch — not when a commit merges.
- Contributing keywords such as `part of` link the work but do NOT close the issue on merge.
- On GitLab, the issue ID must appear with a magic word **in the MR/PR description**, or bare in the MR/PR title, or in the branch name. Nowhere else counts.

## Trailer Format

```
part of K-219
closes K-383
closes K-879, K-881
closes CLOUD-4298
```

Do NOT use `#` prefix for Linear IDs — `closes K-219`, not `closes #K-219`.

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
