# Identifier Legibility

How to present anything addressed by an identifier — issues, merge requests, pull requests, stacks, runs — in a table, a list, a report, or a sentence.

## The rule

**An identifier is an address, not a name. Never present one bare.**

`K-219` tells the reader nothing: not whether it matters, not whether it is theirs, not whether they already know. A table of ten bare ids is ten round trips before the first decision.

Every mention carries two things:

1. **The title**, so the reader knows what it is without opening it.
2. **The full URL as a markdown link**, so they can open it in one click when they want to.

- **Tables:** an id column is always followed by a title or summary column, and the id itself is the link.
- **Prose:** `[K-219 — Rotate the JWT signing key](https://linear.app/<workspace>/issue/K-219/rotate-the-jwt-signing-key)`, or the name first with the id after.
- **Inline, mid-sentence:** the same, and this is the position where the rule is most often dropped. An id inside a clause, an aside, or a parenthetical is not a lesser mention exempt from linking — referring to a thing in passing is exactly when the reader wants to click it. The only relief is the same id repeated within one paragraph, which may stay bare after its first linked mention there.

```markdown
| Issue | Title | State |
|---|---|---|
| [K-219](https://linear.app/<workspace>/issue/K-219/rotate-the-jwt-signing-key) | Rotate the JWT signing key | In Progress |
```

## Give it a link

**Markdown link form, with the absolute URL inside it.** It renders clickable where markdown renders, and where it does not the raw URL is still on screen for the terminal to autolink — so the link form degrades into the plain form rather than into nothing. A bare id is clickable nowhere, and a shortened or relative URL is clickable only sometimes.

**A run of ids in one sentence is the worst case.** Sequencing and dependency sentences — merge order, blocked-on chains, apply-before-apply — pile up identifiers faster than anything else, and each bare one makes the sentence less readable rather than more precise. `Merge order: !320 first, then !319, then undraft !987` is five addresses and nothing to act on. Give every id a parenthetical description or a link, **both by default**; a link alone is the floor, for when titles would genuinely drown the sentence. If the result reads long, use fewer ids per sentence or a table — never the same sentence with the titles stripped back out.

**Announcements are the case that matters most.** "The MR is ready", "the issue is done", "picked up K-219", "opened the PR" — a one-line announcement is exactly where the reader wants to click straight through, and exactly where a bare id most often survives because there is no table to force a title column. Announce with the link every time:

```markdown
MR ready: [rustfs!315 — Revert the renovate kustomize bump](https://gitlab.example.com/cluster/workloads/rustfs/-/merge_requests/315)
```

**Not just issue trackers — anything whose address you already hold.** Repositories and projects, ArgoCD applications, Grafana dashboards and panels, Spacelift stacks and runs, CI pipelines and jobs, Slack messages and channels, Notion pages, a docs page fetched to answer the question. A local file has no web address and stays a path, not a link. The test is never which provider owns it; it is whether the thing has a web address and whether you already have it. Both true means the name is a link.

Backticks and links compose: put the code span inside the link — ``[`argocd-system`](https://gitlab.example.com/cluster/argocd-system)`` — so a name that wants monospace keeps it and still clicks.

**You already have the URL.** It arrives in the same response the id did:

| Provider | Field | Notes |
|---|---|---|
| Linear | `url` | Present in the default response alongside `title` — nothing extra to request. |
| GitLab | `web_url` | On the MR, issue, project and user objects alike. |
| GitHub | `html_url` | Selectable in `fields`; returned by default when `fields` is omitted. |
| Grafana | deeplink tools | `generate_deeplink` builds dashboard, panel and Explore URLs. |
| Anything else | whatever the tool returned | Most APIs carry a self/web link on the object; look before deciding you lack one. |

A git remote is an address too: `ssh://git@host/group/repo.git` is `https://host/group/repo` on GitHub and GitLab, and you have already read the remote by the time you name the repo.

Printing a bare id therefore means you read the link and discarded it. If a path genuinely did not return one — an id parsed out of a branch name, a commit trailer, or the user's own message — fetch the object. One call is cheaper than the reader opening every row by hand.

**Derive freely, invent never.** Building a URL from parts you actually observed is expected — the git remote gives the repo, a known project URL plus a known number gives the MR or PR. What is forbidden is supplying any part from memory or plausibility: a host, a group path, a slug, or a URL shape you have not seen this provider use. That produces a link that looks right and 404s, which is worse than no link. When a part is missing, fetch it or leave the name bare.

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

`[!41 (update config)](https://…/merge_requests/41) — switches the ruler to the new tenant list`

Truncate a long title at a word boundary rather than dropping it; a truncated title still identifies.

## When you do not have the title

Fetch it — one call is cheaper than the reader opening every row. If it genuinely cannot be fetched, say so in the column: `| !9001 | (title unavailable - 404) |`.

## Where bare identifiers are correct

Commit trailers (`closes K-219`), branch names, URLs, API parameters, code and query expressions. The rule governs what a **human reads**, not what a tool parses.

Include fields that change what the reader does next — state, assignee when it is not the user, blocked-ness — and nothing nobody acts on.
