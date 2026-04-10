# Review Findings Format

Shared conventions for presenting code review findings across review skills.

## Grouping

Group findings by **logical domain or system** — not by severity or file path. Use `###` headings to name each domain.

- Derive domain names from the code's purpose: "Authentication", "Plugin System", "Database Layer", "API Routing", "Error Handling", "Configuration", etc.
- If changes touch only one domain, use a single heading.
- If a finding doesn't fit a clear domain, group it under "General" or the most relevant file's purpose.
- For small reviews (1-2 files in one domain), the heading can match the component or module name.

## Finding Format

Within each domain, present findings ordered by severity (most critical first).

```
### <Domain Name>

**bug:** `path/to/file:42` — description of what is broken and how to fix it.

`path/to/file:88` — description. Brief explanation only when the fix isn't obvious from the description.

**nit:** `path/to/file:120` — minor observation. Author can ignore.
```

### Severity Tags

Use bold text tags. Optional — omit when severity is obvious from context.

- **bug:** — broken behavior, will cause incident or data loss.
- **risk:** — works but fragile. Race condition, missing null check, swallowed error, missing rollback.
- **nit:** — style, naming, micro-optimization. Author can ignore.
- **question:** — genuine question about intent, not a suggestion.

### Rules

- One finding per paragraph. File path and line number always in backticks.
- Exact symbol/function/variable names in backticks.
- Concrete fix, not "consider refactoring this."
- Include the *why* only when the fix isn't obvious from the problem statement.
- Silence means approval — do not mention files or domains with no issues.

### Tone

- No hedging ("perhaps", "maybe", "I think") — if unsure, use **question:** tag.
- No throat-clearing ("I noticed that...", "It seems like...", "You might want to consider...").
- No filler praise ("Great work!", "Looks good overall but...") — say it once at the top if warranted, not per finding.
- Do not restate what the line does — the reviewer can read the diff.
- Be specific. "This could cause issues" is useless. "This `parseInt` without a radix will parse `'08'` as octal in older engines" is useful.

### Auto-Clarity Exceptions

Write a full paragraph (drop terse format) for:

- **Security findings** — CVE-class bugs need full explanation and reference.
- **Architectural disagreements** — need rationale, not just a one-liner.
- **Onboarding contexts** — when the author is new and needs the "why" explained.

Resume terse format after the expanded section.

## Example

```markdown
### Authentication

**bug:** `src/auth/middleware.ts:42` — `user` can be null after `.findOne()`. Add null guard before accessing `.email`.

**risk:** `src/auth/token.ts:88` — token expiry check uses `<` not `<=`. Expired tokens pass through for up to 1 second.

### Plugin Loader

`src/plugins/loader.ts:15` — plugin init runs before config is loaded. Move after `config.ready()` callback.

**nit:** `src/plugins/loader.ts:90` — redundant null check. `.find()` already returns `undefined` on miss.

### General

**question:** `src/utils/retry.ts:30` — max retries hardcoded to 10. Is this intentional or should it be configurable?
```
