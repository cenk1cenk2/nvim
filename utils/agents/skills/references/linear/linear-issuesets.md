# Issuesets

An **issueset** is a parent issue plus the sub-issues nested under it — one body of work split into executable pieces that share a description. The term names the whole; `parentId` stays the mechanism and "sub-issue" stays the name of a child. Read this whenever a skill resolves, audits, documents, or writes into one.

## What Makes One

- **The parent is a container, never work.** It holds the shared description every child reads. It is not picked up, produces no PR of its own, and closes when its children do.
- **A sub-issue carries only its delta** — what differs for its repository or slice. A copied parent description is exactly the drift the shape exists to prevent.
- **Nesting is `parentId`, and the structure lives in Linear's own fields.** Never write the hierarchy into prose: Linear renders it natively, and a written-out tree is stale the first time the set changes.

## Working With One

- **Resolve the whole set, not the issue you were handed.** An id given as a single issue that turns out to carry children is an issueset — say so, and treat the children as in scope.
- **The set is the reconciliation unit.** Status, estimate, and label consistency are judged across it: children all done under an open parent, a parent closed over open children, a child carrying labels the parent lacks.
- **Shared context attaches at the tightest level that covers it** — one child's detail on that child, anything the set shares on the parent, anything wider on the project.
- **Orphans and missing links are the most-missed defect.** A child with no `parentId`, a parent whose children were never linked, a flat set that wants one: check explicitly every time the set is read or reconciled.
- **A blessing is scoped to the issueset it named.** A different parent, or the project above it, needs its own.

Ownership: `linear-structure-agent` decides the shape, `linear-reconcile` audits it, the create and update skills write it.
