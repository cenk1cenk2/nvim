# Current State Only

Applies to everything authored here — skills, references, guidance files, repository knowledge bases.

## The rule

⛔ **Write what is true now. Never what changed, what it used to be, or what replaced what.**

An agent reads these at the moment of acting. A past shape named anywhere is a shape it can match by mistake — so a deprecation note is not a helpful caveat, it is a live instruction to consider the wrong thing. **Delete the old wording and state the new one.** A reader must not be able to tell which parts are new.

No compatibility shims, no aliases kept "just in case", no `formerly X`, no "this used to be Y", no migration history, no changelog, no record of what was tried and failed.

## Rewrite, don't annotate

| Instead of | Write |
|---|---|
| "Renamed in v2; the old name no longer works" | *(delete the old name entirely)* |
| "We moved X to Y because Z broke" | "X lives in Y — Z cannot hold it because …" |
| "`foo` is deprecated, use `bar`" | "Use `bar`." |
| "Previously recorded as `a`; now `b`" | "`b`." |
| "Verified live that layers deep-merge" | "Layers deep-merge; `<example>` shows the shape." |

Caveats, gotchas, and constraints are always welcome — phrase them as **standing properties** of how the thing works, not as the story of how it got that way.

## The two exceptions

- **Version-marked runtime behavior** in a `harness-*` reference (`Since v2.1.186, …`). That dates a *live* claim so it can be re-verified, rather than narrating what it replaced.
- **The user explicitly asks for history** — a migration note, a postmortem, a changelog they want written.

## Check before finishing

Grep the file you touched for `formerly`, `deprecated`, `used to`, `no longer`, `previously`, `legacy`, `migrated`, `renamed`. Every hit must be either describing a live external thing (a file format that exists, a vendor's own deprecation, a state a resource can be in) or one of the two exceptions. Anything describing *this system's* own past gets deleted, not softened.
