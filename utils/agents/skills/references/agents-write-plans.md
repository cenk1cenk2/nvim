# Agent Plan Quality

When agent skills create implementation plans (during plan mode), the plan must be concrete enough for a subagent or teammate with zero context to execute. Vague plans produce vague work.

## Plan Structure

Every plan task must have:

- **Id:** Short stable identifier (e.g., `task-a`, `auth-core`). Used for dependency references.
- **What:** Clear description of the change.
- **Files:** Exact file paths — every file that will be created or modified. No "and related files."
- **Steps:** Concrete actions. Each step is one thing to do, not a paragraph of intent.
- **Verification:** How to confirm the task is done — which commands to run, what output to expect.

Optional (used by DAG-scheduled skills like `agents-plan`):

- **Dependencies (`depends_on: [task-id, ...]`):** List of task ids this task must run after. Empty or absent = no dependencies (runs in the first layer). Use for semantic coupling — task B reads a schema defined by task A even though their file lists don't overlap.

## No Placeholders

These are plan failures — never write them:

| Placeholder | Fix |
|-------------|-----|
| "TBD", "TODO", "implement later" | Write the actual content now. |
| "Add appropriate error handling" | Specify which errors and how to handle them. |
| "Write tests for the above" | Write the actual test descriptions or code. |
| "Similar to Task N" | Repeat the details — the agent may read tasks out of order. |
| "Handle edge cases" | List the specific edge cases. |
| "Update as needed" | Specify exactly what to update. |

If you can't be specific, the plan isn't ready — investigate further before writing it.

## Step Granularity

Each step should be a single action:

- "Create `src/auth/validate.ts` with the validation function" — good.
- "Add the validation function, wire it up to the router, update the tests, and handle errors" — too many things in one step.

If the project has tests in the area being changed, steps should include writing/updating tests. If the project doesn't have tests, don't force TDD — follow implement → verify → commit.

## File Structure First

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This locks in decomposition decisions before implementation starts.

- Each file should have one clear responsibility.
- Files that change together should be in the same task.
- Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. Don't restructure unless the plan explicitly calls for it.

## Self-Review

After writing the plan, review it before presenting to the user:

1. **Spec coverage** — can you point to a task for every requirement? List gaps.
2. **Placeholder scan** — search for any patterns from the "No Placeholders" table. Fix them.
3. **Consistency** — do types, function names, and file paths used in later tasks match what earlier tasks define?
4. **Completeness** — does every task have Files, Steps, and Verification? Are file paths exact?

Fix issues inline. If a requirement has no task, add one.
