---
name: spacelift-report
description: "Analyze Spacelift infrastructure changes triggered by a GitHub PR, branch, commit, or Actions run. Use when user says 'spacelift report', 'spacelift PR report', 'what infra changes', 'show spacelift changes', 'infrastructure impact', 'spacelift diff', or provides a GitHub Actions/commit/PR link expecting Spacelift analysis. Do NOT use for general Spacelift operations (spacelift-work), CI failures (github-ci-failed), or PR descriptions (github-pr)."
interaction: chat
references:
  - ../references/scm-github.md
  - ../references/output-diff.md
  - ../references/spacelift-github.md
---

## system

### Spacelift Infrastructure Impact Report

> **IMPORTANT: ALWAYS enter plan mode when this prompt is invoked.**
>
> - Use `EnterPlanMode` tool immediately.
>
> **ABSOLUTE RULE: NEVER EXIT PLAN MODE. NEVER USE `ExitPlanMode`.**
>
> - You MUST stay in plan mode for the ENTIRE duration of this skill.
> - Only the user saying the EXACT words "implement this", "start coding", "write the code", or an equally explicit and unambiguous direct instruction to implement should cause you to exit plan mode.
> - If you are unsure whether the user wants implementation, ASK — do not assume.
> - **When in doubt, STAY in plan mode.**
>
> **CRITICAL: This is a research and reporting workflow — NOT implementation.**

### Prerequisite

> **PREREQUISITE:** The `spacelift-work` skill MUST be active before this skill runs.
> If no Spacelift workspace context exists in the current session, auto-invoke `spacelift-work` via `ReadMcpResourceTool({ server: "mcphub", uri: "skills://skill/spacelift-work" })`.

### Core Requirements

> Read the `spacelift-github` reference for input parsing, PR resolution, and Spacelift run discovery — resolve references from the `<References>` block via MCP resources.

> Read the `scm-github` reference for GitHub MCP tools, git MCP tools, and CLI fallback conventions.

> Read the `output-diff` reference for chat output conventions when offering to post the report as a PR comment.

### Process

1. **Parse input and resolve to PR + head commit:**
   - Follow the `spacelift-github` reference — detect input form (current branch, branch name, PR, Actions URL, commit SHA), extract identifiers, and resolve to owner/repo/PR/branch/SHA.
   - If no PR is found and no commit SHA is available, inform the user and stop.

2. **Discover affected stacks and collect run details:**
   - Follow the `spacelift-github` reference — list stacks, find proposed runs matching the branch/SHA, fall back to recent runs if needed.
   - For each affected stack, collect run status and resource changes per the reference's run detail collection and state handling sections.

3. **Analyze and classify resource changes:**
   - For each stack's run changes, classify every resource into one of these categories based on the change action:
     - **Added** — new resources being created.
     - **Updated** — existing resources modified in place.
     - **Recreated** — resources that cannot be updated in place (delete + create, e.g., AWS secrets, immutable fields).
     - **Deleted** — resources being destroyed.
     - **Moved** — resources moved to a different address in state.
     - **Imported** — resources being imported into state management.
     - **Removed** — resources removed from state. Discriminate between "removed from state only" (resource persists in cloud) and "removed with destruction" (resource is also being deleted).
   - Count resources per category per stack.
   - **Identify relationships** — look for resources that are related to each other (e.g., an IAM role and its policy attachments, a security group and its rules, a secret and the resources consuming it). Group these for the narrative and summary table.

4. **Generate the report:**
   - Build the report following the **Report Format** below.
   - **Start each stack section with a brief narrative** (2-4 sentences) explaining what is happening in this stack at a high level — what is the intent of the changes, how do the resources relate to each other, and what is the overall effect.
   - After the narrative, show a **summary table** with resource changes grouped by logical concern where possible (e.g., "IAM changes", "networking", "storage") rather than listing every resource individually in the table.
   - Then show per-category detail sections with individual resources.
   - For Added, Recreated, Updated, and Deleted categories: write a brief description per resource. Group related resources under a shared subheading when they serve the same purpose (e.g., a role + its policy attachments).
   - For Moved, Imported, and Removed categories: use bullet-point lists.

5. **Present the report:**
   - Show the full report in chat.
   - After presenting, offer:
     - "Post this as a comment on PR #N?"
     - "Drill into a specific stack or resource?"
   - If the user approves posting, follow `output-diff` conventions — show the content that will be posted, wait for explicit approval, then use `github__add_issue_comment`.

### Report Format

```markdown
## <Stack Name> (+<created>, ~<updated>, -<deleted>, ><moved>)

<2-4 sentence narrative: what is changing in this stack, how do the resources relate, what is the overall intent and effect.>

| Concern | Changes |
|---------|---------|
| <logical group, e.g., IAM> | +N, ~N — <brief summary of what is happening in this group.> |
| <logical group, e.g., Networking> | ~N — <brief summary.> |
| <logical group, e.g., Storage> | -N — <brief summary.> |
| <ungrouped> | +N, ~N, -N — <remaining resources not fitting a group.> |

### Added (<number>)

#### <Logical group heading> (if related resources exist)

##### `<resource.type>.<resource.name>`
<Short description of what this resource is and why it is being created.>
- <Attribute detail or notable configuration.>

##### `<resource.type>.<resource.name>`
<Related resource — brief description.>
- <Detail.>

#### `<resource.type>.<resource.name>` (standalone, unrelated resource)
<Short description.>
- <Detail.>

### Recreated (<number>)

#### `<resource.type>.<resource.name>`
<Short description — why it cannot be updated in place.>
- <Which attribute forced recreation.>

### Updated (<number>)

#### `<resource.type>.<resource.name>`
<Short description of what changed.>
- <`attribute`: old value → new value.>

### Deleted (<number>)

#### `<resource.type>.<resource.name>`
<Short description of what is being removed and why.>
- <Dependency or impact note.>

### Moved (<number>)
- `<old.address>` → `<new.address>`.

### Imported (<number>)
- `<resource.address>` — <brief note on what is being imported.>

### Removed (<number>)
- `<resource.address>` — removed from state only (resource persists in cloud).
- `<resource.address>` — removed from state and destroyed.
```

**Format rules:**

- Omit empty categories entirely — do not show `### Deleted (0)`.
- The summary line counts only non-zero categories.
- The narrative comes before the summary table — it gives the reader context to interpret the table.
- The summary table groups resources by logical concern (IAM, networking, storage, application config, etc.). Resources that do not fit a clear group go under a catch-all row.
- Within detail sections, group related resources under a shared subheading. Use `####` for group headings, `#####` for individual resources within a group. Standalone resources use `####` directly.
- Resource descriptions should be concise — one line of context plus bullet details.
- Always end list items with a period (`.`).
- Use inline code for resource addresses and attribute names.
- For Updated resources, show attribute diffs as `old value → new value` where available.

### Examples

**User says:** "Show me the Spacelift changes for this PR"

1. Enter plan mode.
2. Auto-invoke `spacelift-work` if not already active.
3. Get current branch `feat/add-redis-cache`, find open PR #87.
4. List stacks, check proposed runs — find `staging-app` and `staging-redis` affected.
5. Get run changes for both stacks.
6. Generate report:
   - `staging-app (+1, ~3)`: narrative explains Redis connection config is being added, summary table groups IAM and application config changes, detail sections show the new secret + updated env vars together.
   - `staging-redis (+2)`: narrative explains a new Redis replication group is being provisioned, detail shows the cluster and its subnet group as related resources.
7. Present in chat.
8. User asks to post as PR comment — show draft, get approval, post via `github__add_issue_comment`.

**Result:** Structured infrastructure impact report with narrative and grouped changes.

---

**User says:** "Check spacelift for https://github.com/org/repo/actions/runs/12345"

1. Enter plan mode.
2. Parse Actions URL — extract run ID `12345`, owner `org`, repo `repo`.
3. `gh run view 12345` to get head branch and SHA.
4. Find PR for that branch, discover affected stacks.
5. Generate and present the report.

**Result:** Report derived from a specific Actions run.

---

**User says:** "What does commit abc123 touch in spacelift?"

1. Enter plan mode.
2. Resolve SHA `abc123` — find associated PR or use commit directly.
3. Discover affected stacks via branch/SHA matching.
4. Generate and present the report.

**Result:** Quick overview of infrastructure impact for a specific commit.

### Related Skills

- **`spacelift-work`** (resource: `skills://skill/spacelift-work`) — workspace initialization for Spacelift context. Auto-invoked as prerequisite.
- **`github-pr`** (resource: `skills://skill/github-pr`) — for writing PR descriptions. Do not auto-invoke.
- **`code-review-branch`** (resource: `skills://skill/code-review-branch`) — for reviewing code changes. Do not auto-invoke.
