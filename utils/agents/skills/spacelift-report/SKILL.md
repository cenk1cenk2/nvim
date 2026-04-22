---
name: spacelift-report
description: "Analyze Spacelift infrastructure changes triggered by a GitHub PR, branch, commit, or Actions run. Use when user says 'spacelift report', 'spacelift PR report', 'what infra changes', 'show spacelift changes', 'infrastructure impact', 'spacelift diff', or provides a GitHub Actions/commit/PR link expecting Spacelift analysis. Do NOT use for general Spacelift operations (spacelift-work), CI failures (github-ci-fix), or PR descriptions (github-pr)."
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
   - Follow the `spacelift-github` reference — list stacks, find proposed runs matching the branch/SHA, fall back to recent runs if needed. If the input was a check run or Spacelift URL, the stack and run ID are already known — skip discovery.
   - For each affected stack, collect run status and resource changes per the reference's run detail collection and state handling sections.
   - **If `get_stack_run_changes` returns empty** (common during APPLYING state and after completion), fall back to parsing the terraform plan output from `get_stack_run_logs` — see the "Log Parsing Fallback" section in the `spacelift-github` reference.

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
   - **Multi-stack overview (when 2+ stacks are affected):** Before per-stack sections, generate a cross-stack comparison section. Show a summary table of all stacks with their change counts, then describe what patterns are shared across stacks (e.g., "all 5 stacks receive the same `common` module migration") and what is unique to specific stacks (e.g., "only `staging-redis` adds new resources"). This lets the reader understand the blast radius at a glance without reading every stack section.
   - **Start each stack section with a brief narrative** (2-4 sentences) explaining what is happening in this stack at a high level — what is the intent of the changes, how do the resources relate to each other, and what is the overall effect. Explain the *why* — what motivated these changes.
   - After the narrative, show a **summary table** with resource changes grouped by logical concern where possible (e.g., "IAM changes", "networking", "storage") rather than listing every resource individually in the table.
   - Then show per-category detail sections with individual resources.
   - For Added, Recreated, Updated, and Deleted categories: write a brief description per resource explaining both *what* is changing and *why* it is changing (infer from resource type, attribute diffs, PR title, commit message, and surrounding context). Group related resources under a shared subheading with a reasoning sentence for the group.
   - For Moved categories: include a sentence explaining the reason for the move (module refactor, rename, restructuring) before the bullet list.
   - For Imported and Removed categories: include a brief reason per resource.
   - **Markdown spacing** — always leave empty lines between all block-level elements (headings, paragraphs, lists, tables).

5. **Present the report:**
   - Show the full report in chat.
   - After presenting, offer:
     - "Post this as a comment on PR #N?"
     - "Drill into a specific stack or resource?"
   - If the user approves posting, follow `output-diff` conventions — show the content that will be posted, wait for explicit approval, then use `github__add_issue_comment`.

### Report Format

#### Multi-Stack Overview (when 2+ stacks are affected)

```markdown
# Overview (<N> stacks affected)

<2-3 sentence summary: what this PR/commit does across all stacks, the overall blast radius,
and any risk or rollout considerations.>

| Stack | + | ~ | - | > | Status |
|-------|---|---|---|---|--------|
| `<stack-1>` | N | N | N | N | Finished / Applying / etc. |
| `<stack-2>` | N | N | N | N | Finished / Applying / etc. |
| **Total** | **N** | **N** | **N** | **N** | |

### Common Patterns

<Describe change patterns that appear across multiple stacks. Group by pattern, not by stack.
For example: "All N stacks receive the `common` module migration from singleton to indexed
(`module.common` → `module.common[0]`), moving 10 IAM resources each. All stacks also get
the ArgoCD cluster secret rotation adding the `cert-manager` label.">

### Stack-Specific Differences

<Describe what is unique to individual stacks — changes that do NOT appear in other stacks.
For example: "Only `staging-redis` adds 2 new resources (Redis replication group + subnet group).
`production-iam` has 1 additional IAM role deletion not seen in other stacks.">

<If all stacks have identical changes, state: "All stacks have identical change sets — no
stack-specific differences.">
```

#### Per-Stack Sections

```markdown
## <Stack Name> (+<created>, ~<updated>, -<deleted>, ><moved>)

<2-4 sentence narrative: what is changing in this stack, how do the resources relate,
what is the overall intent and effect. Explain the "why" — what motivated these changes
(module upgrade, feature enablement, refactor, cleanup, security rotation, etc.).>

| Concern | Changes |
|---------|---------|
| <logical group, e.g., IAM> | +N, ~N — <brief summary of what is happening in this group.> |
| <logical group, e.g., Networking> | ~N — <brief summary.> |
| <logical group, e.g., Storage> | -N — <brief summary.> |
| <ungrouped> | +N, ~N, -N — <remaining resources not fitting a group.> |

### Added (<number>)

#### <Logical group heading> (if related resources exist)

<1-2 sentence reasoning for this group: why are these resources being added together,
what purpose do they serve collectively.>

##### `<resource.type>.<resource.name>`

<Short description of what this resource is and why it is being created.>

- <Attribute detail or notable configuration.>

##### `<resource.type>.<resource.name>`

<Related resource — brief description of its role in the group.>

- <Detail.>

#### `<resource.type>.<resource.name>` (standalone, unrelated resource)

<Short description — what it does and why it is being added.>

- <Detail.>

### Recreated (<number>)

#### `<resource.type>.<resource.name>`

<Short description — why it cannot be updated in place, what triggered the replacement.
Explain the cause: was it a config value change, a name change, an immutable field update?>

- <Which attribute forced recreation.>
- <Impact: does this cause downtime, data loss, or a brief interruption?>

### Updated (<number>)

#### `<resource.type>.<resource.name>`

<Short description of what changed and why — e.g., version bump, config tuning, label addition.>

- <`attribute`: old value → new value.>

### Deleted (<number>)

#### `<resource.type>.<resource.name>`

<Short description of what is being removed and why — e.g., feature deprecated,
resource consolidated elsewhere, cleanup of legacy config.>

- <Dependency or impact note.>

### Moved (<number>)

<1-2 sentence explanation of why resources moved — e.g., module refactor from singleton
to indexed, rename, restructuring.>

- `<old.address>` → `<new.address>`.

### Imported (<number>)

- `<resource.address>` — <brief note on what is being imported and why.>

### Removed (<number>)

- `<resource.address>` — removed from state only (resource persists in cloud). <Why.>
- `<resource.address>` — removed from state and destroyed. <Why.>
```

**Format rules:**

- **Markdown spacing** — always leave an empty line before and after headings, between list items and paragraphs, and between code blocks and surrounding text. Every block-level element (heading, paragraph, list, table, fenced code block) must be separated by a blank line.
- **Multi-stack overview** — only include when 2+ stacks are affected. Skip for single-stack reports. The overview uses `#` heading level, per-stack sections use `##`. Common patterns should focus on the *pattern*, not enumerate every resource — keep it scannable. Stack-specific differences should call out what makes each stack unique.
- Omit empty categories entirely — do not show `### Deleted (0)`.
- The summary line counts only non-zero categories.
- The narrative comes before the summary table — it gives the reader context to interpret the table.
- The summary table groups resources by logical concern (IAM, networking, storage, application config, etc.). Resources that do not fit a clear group go under a catch-all row.
- Within detail sections, group related resources under a shared subheading. Use `####` for group headings with a reasoning sentence, `#####` for individual resources within a group. Standalone resources use `####` directly.
- **Reasoning is mandatory** — every resource and group must have a brief explanation of *why* the change is happening, not just *what* is changing. Infer the reason from the resource type, attribute diffs, PR title, and surrounding context (e.g., a `release_version` bump is an AMI update; a `secret_string` force-replacement is a config rotation; a module address change is a refactor).
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
