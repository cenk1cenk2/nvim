# Commit Message Style

Shared conventions for writing commit messages and PR/MR titles.

## Format

```
<type>(<scope>): <imperative summary>

<body — only when why isn't obvious>

<trailers — see commit-trailers reference for issue linking>
```

## Subject Line

- `<type>(<scope>): <summary>` — scope is optional.
- Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`.
- Imperative mood: "add", "fix", "remove" — not "added", "adds", "adding".
- ≤50 chars preferred, 72 hard cap.
- No trailing period.
- Match project convention for capitalization after the colon.

## Body

- Skip entirely when the subject is self-explanatory.
- Add body only for: non-obvious *why*, breaking changes, migration notes, linked issues.
- Wrap at 72 chars.
- Bullets with `-` not `*`.
- Issue/PR trailers go in the footer — see `commit-trailers` reference for platform-specific conventions.

## What Never Goes In

- "This commit does X", "I", "we", "now", "currently" — the diff says what.
- "As requested by..." — use `Co-authored-by` trailer.
- "Generated with Claude Code" or any AI attribution.
- Emoji (unless project convention requires).
- Restating the file name when scope already says it.

## Always Include Body For

- Breaking changes (`BREAKING CHANGE:` trailer required).
- Security fixes (what was vulnerable, what changed).
- Data migrations (what moves where, rollback path).
- Reverts (why the original was reverted, not just "revert X").

## Examples

```
feat(api): add GET /users/:id/profile

Mobile client needs profile data without the full user payload
to reduce LTE bandwidth on cold-launch screens.
```

```
feat(api)!: rename /v1/orders to /v1/checkout

BREAKING CHANGE: clients on /v1/orders must migrate to /v1/checkout
before 2026-06-01. Old route returns 410 after that date.
```

```
fix(auth): reject expired tokens at boundary

Token expiry check used < instead of <=, allowing 1-second window
where expired tokens passed validation.
```
