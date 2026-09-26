# Agent Planning & Task Split

Shared planning phase for agent orchestration skills. Walks through understanding the goal, discovering project tooling, establishing conventions, writing the plan, splitting into non-overlapping tasks, declaring task dependencies, and building the execution schedule (layers). Used by `agent-plan` (all steps) and `agent-pickup`.

## Process

### 1. Understand the goal

- Read the codebase, gather context, understand what needs to be done.
- For organization-wide or unknown-repository investigations, use Sourcebot first when available to build an evidence-backed repo/file shortlist before provider-specific SCM calls.
- If the user provides a high-level goal, break it down into concrete tasks.
- If the user provides pre-decomposed tasks, validate they are complete and clear.

### 2. Discover project tooling

- Follow the `project-tooling` reference to discover verification commands (lint, test, build, etc.).
- Present discovered commands to the user for confirmation.
- These commands will be included in each agent's prompt and run after merge / after every task.

### 3. Establish conventions

- Follow the `agent-conventions` reference — read existing code to discover testing framework, code style, patterns, formatting, commit style.
- Present the conventions block to the user for confirmation.
- This block will be included in every agent's prompt as the `## Conventions` section.

### 4. Plan the implementation

- Create a full implementation plan following the `agent-write-plans` reference — exact file paths, concrete steps, no placeholders.
- Identify all files and areas of the codebase that will be touched.
- Self-review the plan (spec coverage, placeholder scan, consistency) before presenting.
- Present the plan to the user and iterate.

### 5. Split into tasks

Break the plan into logically independent units. Think of it as developers branching off — each task is a unit of work that could plausibly run in parallel with unrelated work.

**Split on the boundaries the work already has** — one PR or MR, one worktree, one repository, one tracker issue. Each task gets its own agent, so a task spanning two of those boundaries is two tasks.

For each task, define:

- **Id:** Short stable identifier (e.g., `task-a`, `auth-core`) — used for dependency references.
- **What:** Clear description of what to implement.
- **Files:** Explicit list of files this task writes to (reads from anywhere, writes only to these).
- **Dependencies:** Optional `depends_on: [task-id, ...]` — other tasks that must complete before this one starts. Empty/absent means "no dependencies" (runs in the first layer).
- **Context:** What this task needs to know about the broader goal and adjacent tasks.
- **Constraints:** What NOT to touch — boundaries with other tasks' work.

**Two kinds of collisions to watch for:**

- **Hard file collision:** two tasks write the same file. **Prefer handing both to the SAME named agent** in dependency order — it already holds the context and the worktree — one turn per task, each keeping its own brief and report. Sequentialise instead (add a `depends_on`) when no such agent is reachable. Merge into a single task only when they were never separate deliverables; two PRs never become one task to dodge a collision.
- **Semantic dependency:** task B reads a schema/type/output defined by task A, even in a different file. The plan author must declare this via `depends_on` — it's not detectable from file lists alone.
- **Stacked branches follow `depends_on`, nothing else.** A task that depends on another bases its branch on that task's branch and targets it; independent tasks in one layer branch from the same base in parallel, even when they will touch a shared file like CI config. When a prerequisite merges, dependents merge trunk in; they never rebase or force-push a pushed branch.

### 6. Build the layer schedule

Partition tasks into layers using the DAG:

- `layer(task) = max(layer(dep) for dep in depends_on) + 1`, or `0` if `depends_on` is empty.
- Tasks in the same layer run in parallel. Layers run sequentially.
- **Within a layer, verify no two tasks write the same file.** If overlap exists, flag it to the user — propose promoting one task to a later layer (adding a dep), splitting the overlap into a new task, or merging the two tasks. Do NOT auto-resolve.

Present the resulting schedule to the user as a layer-by-layer table:

| Layer | Task id | What | Tier | Depends on | Files (write) |
|-------|---------|------|------|-----------|---------------|
| 0 | task-a | Add auth core | default | — | src/auth/core.ts |
| 0 | task-b | Add logging | cheap | — | src/log.ts |
| 1 | task-c | Auth integration tests | default | task-a | tests/auth.test.ts |

### 7. Decide agent count per layer

- Number of agents in a layer = number of tasks in that layer.
- **One task never shares an agent with another in the same layer, and no agent takes two.** Across layers, a dependent task MAY go to the named agent that did the task it depends on — that is steering, one turn per task, not batching.
- **Each task carries its own tier**, chosen from that task's signals per `agent-harness` and shown in the schedule. A layer's tasks routinely differ.
- 2–4 tasks per layer is the sweet spot for parallel work. Single-task layers are fine (sequential points in the DAG).
- If a layer has >4 tasks, consider merging some — agent overhead scales linearly.

## Degenerate DAG shapes

The DAG model covers the flat shapes too:

- **All-parallel** (everything independent): all tasks have empty `depends_on`; one layer with N tasks.
- **All-sequential** (everything chained): each task depends on the previous; N layers of 1 task each.
- **Mixed DAG** (real-world): some layers have parallel tasks, some have a single task — the scheduler handles all cases uniformly.

A plan without any `depends_on` declarations defaults to the all-parallel shape — everything lands in layer 0.

## Linear-aligned splits

When the user provides Linear issues or a Linear project as input, load `linear-pickup` and align the split with existing issue boundaries per its `linear-chunk-issues`. Each task maps to an issue id where practical — this keeps state transitions clean and simplifies per-task commit trailers.

## Self-check before proceeding

Before leaving plan mode / dispatching agents, confirm:

1. Verification commands are discovered and user-confirmed.
2. Conventions block is drafted and user-confirmed.
3. Plan has exact file paths and no placeholders.
4. Each task has an id, `files` list, and optional `depends_on`.
5. Layer schedule is computed and presented; no file overlaps within a layer.
6. Each task description is self-contained enough to paste into an agent prompt.
