# Commit Trailers — GitHub

How a GitHub native issue closes from a commit or PR. Shared `closes` versus `refs` policy is in `commit-trailers`; this file covers only GitHub's keywords and syntax.

GitHub closes issues automatically when a commit with a closing keyword is merged to the default branch — unlike Linear, where commit messages link nothing.

## Closing Keywords

`close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves`, `resolved`.

Case-insensitive. Can be followed by a colon: `closes: #10`.

## Syntax

| Scope | Format | Example |
|-------|--------|---------|
| Same repo | `keyword #NUMBER` | `closes #42` |
| Cross-repo | `keyword OWNER/REPO#NUMBER` | `fixes octo-org/octo-repo#100` |
| Multiple | Repeat keyword per issue | `resolves #10, resolves #123` |

**Repeat the keyword per issue.** The comma-separated single-keyword form is GitLab's and Linear's, not GitHub's.

## Referencing Without Closing

Mention `#NUMBER` in the body without a closing keyword — GitHub auto-links it. GitHub has NO dedicated `refs` / `references` keyword: a bare `#N` (optionally after a phrase like "part of") links but never closes; only the closing keywords above close.

Follow the **Refs vs Closes** default in `commit-trailers`: use a closing keyword (`closes #N`) by default when this PR resolves the issue and nothing else is pending; reference-only (a bare `#N`) when the work is partial — deferring the closing keyword to the final PR.

## Trailer Format

```
closes #42
#17
```

(`#17` is reference-only — links, does not close.) Fetch issue context via `github__issue_read` or `github__pull_request_read`.
