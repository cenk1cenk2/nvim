# Linear Issue States

State semantics, transition rules, and decision patterns for Linear issues. Read this when transitioning issue states or analyzing issue readiness.

## State Hierarchy

States follow a progression. Higher states represent more advanced work stages.

```
Triage → Backlog → Todo → In Progress → In Review → Done
                                                   ↘ Canceled
```

| State | Meaning | Semantic Role |
|-------|---------|---------------|
| `Triage` | Unprocessed — needs classification. | API default when state is not specified. **NEVER intentionally set this state** — always specify an explicit state. |
| `Backlog` | Planned but not committed to a cycle. | Default for new issues. Safe parking state. |
| `Todo` | Committed to the current cycle. | Signals intent to work on it soon. |
| `In Progress` | Actively being worked on. | Someone is writing code or doing the work right now. |
| `In Review` | Work complete, awaiting review. | **Counts as complete for dependency purposes** — issues blocked by an "In Review" issue are actionable. |
| `Done` | Finished. | Terminal state. |
| `Canceled` | No longer needed. | Terminal state. American spelling (one 'l'). |

## Transition Rules

### Never Downgrade

**NEVER move an issue to a lower state** — only promote forward in the hierarchy.

- `In Progress` → `Todo` is **forbidden**.
- `Todo` → `Backlog` is **forbidden**.
- If an issue needs to be deprioritized, leave its state and remove it from the cycle instead.

### State Floor

- **Triage → Backlog** is the minimum transition. Issues leaving triage must reach at least `Backlog`.
- Skills that process triage queues (e.g., triage skill) enforce this floor.

### Dependency Resolution

- `Done` and `In Review` both satisfy `blockedBy` dependencies — an issue blocked by an "In Review" issue **can proceed**.
- `Todo` and `In Progress` blockers mean the dependent issue is **not yet actionable**.
- `Canceled` blockers are treated as resolved — the dependency is void.

## Decision Patterns

### New Issue Creation

Ask the user about timing: "Do you want to work on this issue in the current cycle?"

- YES → `state: "Todo"`.
- NO or UNSURE → `state: "Backlog"` (default).
- If user says nothing about timing → `state: "Backlog"`.

### Picking Up Work

When a user starts working on an issue, move it to `In Progress` immediately — before any research or planning begins.

### Cycle Planning

When assigning issues to a cycle:

- `Triage` or `Backlog` → promote to `Todo`.
- `Todo`, `In Progress`, or beyond → **do not change the state**. Preserve current state.

### Triage Processing

When processing the triage queue:

- Default recommendation: `Backlog`.
- Recommend `Todo` only if the issue is urgent or the user explicitly wants it in the current cycle.
- Never leave an issue in `Triage` after processing.
