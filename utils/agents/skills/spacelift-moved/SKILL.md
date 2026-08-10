---
name: spacelift-moved
description: 'spacelift-moved Analyze Spacelift plan output for delete/create cycles replaceable with Terraform moved blocks. Accepts a PR, branch, commit, or Actions link. Triggers: "spacelift moved", "avoid destroy/create". Do NOT use for general Spacelift ops (spacelift-laravel), impact reports (spacelift-report), or PR descriptions (github-pr-create).'
references:
  - ../references/scm-github.md
  - ../references/spacelift-github.md
  - ../references/output-diff.md
---

## Spacelift Moved Block Analysis

## Prerequisite

> **PREREQUISITE:** The `spacelift-laravel` skill MUST be active before this skill runs.
> If no Spacelift workspace context exists in the current session, auto-invoke `spacelift-laravel` via the `spacelift-laravel` skill (load it as defined in `load-skills`).

## Process

1. **Parse input and resolve to PR + head commit:**
   - Input parsing and PR resolution per `spacelift-github` — detect input form (current branch, branch name, PR, Actions URL, commit SHA), extract identifiers, and resolve to owner/repo/PR/branch/SHA. GitHub MCP tools, local `git` CLI, and CLI fallbacks per `scm-github`.
   - If no PR is found and no commit SHA is available, inform the user and stop.

2. **Discover affected stacks and collect run changes:**
   - Run discovery per `spacelift-github` — list stacks, find proposed runs matching the branch/SHA. If the input was a check run or Spacelift URL, the stack and run ID are already known — skip discovery.
   - For each affected stack, call `spacelift-laravel__get_stack_run_changes` to get the full resource change list.
   - **If `get_stack_run_changes` returns empty** (common during APPLYING state and after completion), fall back to parsing the terraform plan output from `get_stack_run_logs` — see the "Log Parsing Fallback" section of `spacelift-github`.

3. **Identify moved block candidates:**
   - Scan the change list for **delete + create pairs** — resources being destroyed and recreated under a different address.
   - A pair is a candidate when:
     - Same resource **type** appears in both a delete and a create action.
     - The resource **attributes** are identical or nearly identical (minor drift is acceptable).
     - The address changed — e.g., renamed, moved to a different module path, index key changed (`count` → `for_each`), or refactored into a child module.
   - Also look for **standalone deletes** where the resource type still exists elsewhere in the plan under a new address — these may be moves that Terraform could not automatically detect.
   - Exclude pairs where the resource is genuinely being replaced due to an immutable attribute change (e.g., AWS `name_prefix`, `ami`, `engine_version`). These are real recreations, not address changes.

4. **Classify each candidate:**

   | Classification | Meaning |
   |---|---|
   | **High confidence** | Same type, same or near-identical attributes, address clearly changed (rename, module move, index change). |
   | **Medium confidence** | Same type, most attributes match, but some attribute drift exists that may or may not be intentional. |
   | **Low confidence** | Same type, but significant attribute differences — could be a genuine replacement rather than a move. |
   | **Not a move** | Immutable attribute changed, or resource types differ. Skip these. |

5. **Generate the reasoning report:**
   - Build the report following the **Report Format** below.
   - For each candidate, explain:
     - What the old and new addresses are.
     - Why this looks like a move (what is the same, what changed).
     - Confidence level and any caveats.
   - Group candidates by stack.

6. **Present the report:**
   - Show the full reasoning report in chat.
   - If there are high or medium confidence candidates, offer: "Would you like me to generate a `moved.tf` file for these?"
   - If user approves, follow step 7.

7. **Generate `moved.tf`:**
   - Ask the user where to place the file — suggest the repository root or the relevant module directory.
   - Generate `moved` blocks for approved candidates only.
   - Present the file content per `output-diff` — show the full content, wait for explicit approval.
   - After approval, write the file.

## Report Format

```markdown
## <Stack Name> — Moved Block Analysis

<1-3 sentence summary: how many delete/create pairs found, how many are move candidates, overall confidence.>

### High Confidence (<number>)

#### `<old.address>` → `<new.address>`
<Why this is a move — what stayed the same, what changed in the address.>
- Type: `<resource type>`.
- Address change: <rename / module move / index key change / etc.>.
- Attribute drift: none (or list minor differences).

### Medium Confidence (<number>)

#### `<old.address>` → `<new.address>`
<Why this might be a move, and what introduces uncertainty.>
- Type: `<resource type>`.
- Address change: <description>.
- Attribute drift: <list differences that may or may not be intentional>.
- ⚠️ <Caveat — e.g., "tags differ, verify if intentional.">.

### Low Confidence (<number>)

#### `<old.address>` → `<new.address>`
<Why this is unlikely but worth flagging.>
- Type: `<resource type>`.
- Significant differences: <list>.
- Recommendation: verify manually before adding a moved block.

### Skipped (Not Moves)

- `<resource.address>` — <reason, e.g., "AMI changed, genuine replacement.">.
```

**Format rules:**

- Omit empty confidence sections.
- Always end list items with a period (`.`).
- Use inline code for resource addresses and attribute names.
- Group related moves together (e.g., a module being renamed affects multiple resources — present them under one heading).

## `moved.tf` Format

```hcl
# Moved blocks generated from Spacelift plan analysis.
# Stack: <stack-name>
# PR: #<number> (<branch>)

moved {
  from = <old.address>
  to   = <new.address>
}
```

**Rules:**

- One `moved` block per candidate.
- Only include high and medium confidence candidates by default. Include low confidence only if user explicitly requests.
- Group by stack with a comment header.
- Use the exact Terraform address syntax (module paths, index keys, etc.).

## Examples

**User says:** "Check if we can use moved blocks for this PR"

1. Auto-invoke `spacelift-laravel` if not already active.
2. Get current branch, find PR, discover affected stacks.
3. Find 4 delete/create pairs across 2 stacks.
4. Classify: 2 high confidence (module rename), 1 medium (index key change with tag drift), 1 not a move (AMI change).
5. Present reasoning report.
6. User approves — generate `moved.tf` with 3 moved blocks.
7. Present file content, wait for approval, write the file.

**Result:** Reasoning report + `moved.tf` written to the repository.

---

**User says:** "spacelift moved for https://github.com/org/repo/actions/runs/12345"

1. Parse Actions URL, resolve to branch/SHA.
2. Discover affected stacks, analyze changes.
3. No delete/create pairs found — report "No moved block candidates detected."

**Result:** Clean report, no file generated.

## Related Skills

- **`spacelift-laravel`** — workspace initialization. Auto-invoked as prerequisite.
- **`spacelift-report`** — full infrastructure impact report. Do not auto-invoke.
- **`github-pr-create`** — for writing PR descriptions. Do not auto-invoke.
