# Identifier Legibility

How to present anything addressed by an identifier — issues, merge requests, pull requests — in a table, a list, a report, or a sentence.

## The rule

**An identifier is an address, not a name. Never present one bare.**

`K-219` tells the reader nothing: not whether it matters, not whether it is theirs, not whether they already know. A table of ten bare ids is ten round trips before the first decision.

- **Tables:** an id column is always followed by a title or summary column.
- **Prose:** `K-219 (rotate the JWT signing key)`, or the name first with the id after.

```markdown
| Issue | Title | State |
|---|---|---|
| K-219 | Rotate the JWT signing key | In Progress |
```

## Carry the scope when more than one is in play

Scope says *where* it lives. Without it, rows spanning several places read as one pile.

| Kind | Scope |
|---|---|
| MR / PR | The repository — `group/project!262`, `owner/repo#41` |
| Linear issue | Its parent issue or project |

Provider short forms encode it for free; prefer them over a bare `!262` whenever more than one repository appears.

**Collapse it when uniform.** If every row shares one scope, state it once above the table and drop the column — a repeated identical column crowds out the title. The test: could a reader mistake one row's scope for another's?

## When the title does not explain it

Some titles are useless — "update config", a Renovate branch name. **The title is the minimum, not the goal.** Add a clause that explains:

`!41 (update config) — switches the ruler to the new tenant list`

Truncate a long title at a word boundary rather than dropping it; a truncated title still identifies.

## When you do not have the title

Fetch it — one call is cheaper than the reader opening every row. If it genuinely cannot be fetched, say so in the column: `| !9001 | (title unavailable - 404) |`.

## Where bare identifiers are correct

Commit trailers (`closes K-219`), branch names, URLs, API parameters, code and query expressions. The rule governs what a **human reads**, not what a tool parses.

Include fields that change what the reader does next — state, assignee when it is not the user, blocked-ness — and nothing nobody acts on.
