# Identifier Legibility

How to present issues, merge requests, pull requests, and anything else addressed by an identifier. Read this whenever output contains one — a table, a list, a status report, or a sentence.

## The rule

**An identifier is an address, not a name. Never present one bare.**

`K-219` tells the reader nothing. They cannot tell whether it matters, whether it is theirs, or whether they already know about it — they have to open it to find out, and a table of ten of them means ten round trips before the first decision.

**Every reference carries enough to know what it is without opening it.**

## In tables

An id column is **always** followed by a title or summary column. The id is never the only identifying column.

```markdown
| Issue | Title | State | Repo |
|---|---|---|---|
| K-219 | Rotate the JWT signing key | In Progress | `api-gateway` |
| K-244 | Drop the v1 auth middleware | Todo | `api-gateway` |
```

Not:

```markdown
| Issue | State |
|---|---|
| K-219 | In Progress |
```

The same holds for merge requests and pull requests — `!262` and `#41` need their titles beside them.

## In prose and lists

Put the name in parentheses after the id, or lead with the name and put the id after it. Either reads; a bare id does not.

- `K-219 (rotate the JWT signing key)` — blocked on the key rotation MR.
- Opened `monitoring!262 (align Loki labels with Prometheus names)`.

## Carry the scope when more than one is in play

A title says what something is. **Scope says where it lives**, and without it a list spanning several places reads as one undifferentiated pile — the reader cannot tell that three rows are the same change in three repositories, or that two issues belong to different projects.

| Kind | Scope to carry |
|---|---|
| Merge request or pull request | The repository — `cluster/workloads/monitoring!262`, or an `org/repo` column |
| Linear issue | Its parent issue or its project |
| Anything cross-repository | The repository, always |

The provider short forms already encode it and are the cheapest way to carry it: `<group>/<project>!<number>` for GitLab, `<owner>/<repo>#<number>` for GitHub. Prefer them over a bare `!262` whenever more than one repository appears anywhere in the output.

**Collapse it when it is uniform.** If every row shares one scope, state it once above the table and drop the column — a repeated identical column is noise that crowds out the title:

```markdown
All in `cluster/workloads/monitoring`:

| MR | Title | State |
|---|---|---|
| !262 | Align Loki labels with Prometheus names | Open |
```

The test is whether the reader could mistake one row's scope for another's. If yes, carry it per row. If no, say it once.

## When the title does not explain it

Some titles are useless — "update config", "fix stuff", a Renovate branch name. **The title is the minimum, not the goal.** When it fails to convey what the thing does, add a short clause that does:

- `!41 (update config) — switches the ruler to the new tenant list`

Truncate a long title rather than dropping it. Cut at a word boundary around 60-80 characters and mark the cut; a truncated title still identifies, a missing one never does.

## When you do not have the title

Fetch it. One extra call is cheaper than the reader opening every row. If it genuinely cannot be fetched — a deleted resource, a permissions error — say so in the column rather than leaving the id alone:

`| !9001 | (title unavailable - 404) |`

## Where bare identifiers are correct

These are machine-read, and adding prose would break them:

- Commit trailers — `closes K-219`.
- Branch names.
- URLs and API parameters.
- Code, config values, and query expressions.

The rule governs what a **human reads**, not what a tool parses.

## Also worth carrying

Include the fields that change what the reader does next, when they are known and cheap: state or status, assignee when it is not the user, the repository for anything multi-repo, and whether something is blocked. Do not pad a table with fields nobody acts on.
