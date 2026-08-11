# Commit Trailers

The shared trailer policy: where trailers go, and when to close an issue versus merely reference it. **Which surface actually links is per platform, and they disagree** — fetch the one for the platform in play:

| Platform | Reference | The trap it carries |
|---|---|---|
| Linear | `commit-trailers-linear` | Linear ignores commit messages entirely — only branch name, MR/PR title, and MR/PR description link. |
| GitHub | `commit-trailers-github` | Native issues DO close from commit messages; there is no `refs` keyword. |
| GitLab | `commit-trailers-gitlab` | Native issues DO close from commit messages; multiple issues are comma-separated after one keyword. |

Fetch only the platforms in play. A GitHub repo with no Linear issue needs this file and `commit-trailers-github`, and nothing else.

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

Applied to delivery shape, on any platform:

- Single PR/MR completing one issue → `closes`.
- Multiple PRs/MRs for one issue → non-final ones use `refs`; only the final completing PR/MR uses `closes`.
- One PR/MR can close multiple independent issues. **The syntax differs per platform** — see each platform's "Multiple issues" rule.
- Mix `closes` and `refs` when some linked issues are closed and others are only related.
