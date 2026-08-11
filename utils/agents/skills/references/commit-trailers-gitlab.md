# Commit Trailers — GitLab

How a GitLab native issue closes from a commit or MR. Shared `closes` versus `refs` policy is in `commit-trailers`; this file covers only GitLab's keywords and syntax.

GitLab closes issues when a commit or MR with a closing keyword is merged to the default branch — unlike Linear, where commit messages link nothing.

## Closing Keywords

`close`, `closes`, `closed`, `closing`, `fix`, `fixes`, `fixed`, `fixing`, `resolve`, `resolves`, `resolved`, `resolving`, `implement`, `implements`, `implemented`, `implementing`.

Case-insensitive.

## Syntax

| Scope | Format | Example |
|-------|--------|---------|
| Same project | `keyword #NUMBER` | `closes #4` |
| Cross-project | `keyword GROUP/PROJECT#NUMBER` | `fixes backend/api#20` |
| Full URL | `keyword URL` | `closes https://gitlab.example.com/group/project/-/issues/123` |
| Multiple | Comma-separated after one keyword | `closes #4, #6` |

## Referencing Without Closing

`related to #5` — marks as related but does not close.

Follow the **Refs vs Closes** default in `commit-trailers`: use a closing keyword (`closes #N`) by default when this MR resolves the issue and nothing else is pending; `related to #N` when the work is partial — deferring the closing keyword to the final MR.

## Trailer Format

```
closes #4
related to #5
```

Fetch issue context via `gitlab__get_issue` or `gitlab__get_merge_request`.
