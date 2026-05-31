# Commit Trailers

Conventions for referencing and closing issues from commit messages across platforms.

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
| `refs` | Link or contribute without closing — partial progress, one commit/PR/MR in a multi-deliverable issue, related work, or unclear completion intent. |
| `closes` | The commit/PR/MR is the single or final deliverable that should close the issue when merged. |

For Linear IDs, choose the trailer from the delivery shape:

- Use `closes <Linear-id>` when this commit, PR, or MR is expected to fully resolve and close the issue after merge.
- Use `refs <Linear-id>` when the change only contributes to the issue, several PRs/MRs are needed and this is not the final one, or closing intent is unclear.
- Single PR/MR completing one issue → `closes K-123`.
- Multiple PRs/MRs for one issue → non-final PRs/MRs use `refs K-123`; only the final completing PR/MR uses `closes K-123`.
- One PR/MR can close multiple independent issues by including one `closes <ID>` trailer per closed issue.
- Mix `closes` and `refs` when some linked issues are closed and others are only related.

## Linear

Linear links commits to issues via **magic words** in commit messages, MR/PR titles, or descriptions.

### Issue ID Formats

| Workspace | Pattern | Example |
|-----------|---------|---------|
| kilic-dev | `K-<number>` | `K-219` |
| Laravel | `CLOUD-<number>` | `CLOUD-4298` |

### Closing Keywords

`close`, `closes`, `closed`, `closing`, `fix`, `fixes`, `fixed`, `fixing`, `resolve`, `resolves`, `resolved`, `resolving`, `complete`, `completes`, `completed`, `completing`.

### Contributing Keywords (link without closing)

`ref`, `refs`, `references`, `part of`, `related to`, `contributes to`, `towards`.

### Behavior

- Issue moves to **In Progress** when the branch is pushed.
- Issue moves to **Done** when the commit/PR/MR is merged to the default branch (only with closing keywords).
- Contributing keywords such as `refs` link the work but do NOT close the issue on merge.
- The issue ID must appear with a magic word — bare ID alone does not auto-link.

### Trailer Format

```
refs K-219
closes K-383
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
- `K-` prefix → `linear-kilic-dev__get_issue`.
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

Mention `#NUMBER` in the body without a closing keyword — GitHub auto-links it.

### Trailer Format

```
closes #42
refs #17
```

Fetch issue context via `github__issue_read` or `github__pull_request_read`.

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

### Trailer Format

```
closes #4
related to #5
```

Fetch issue context via `gitlab__get_issue` or `gitlab__get_merge_request`.
