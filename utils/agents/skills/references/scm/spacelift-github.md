# Spacelift–GitHub Resolution

How to resolve GitHub inputs (branch, PR, commit, Actions URL) to Spacelift runs. Read this reference when a skill needs to discover which Spacelift stacks are affected by a GitHub change.

## Input Parsing

The user can provide context in several forms. Detect which form was given and extract the relevant identifiers.

| Input Form | Detection | Extract |
|---|---|---|
| **No input** (current branch) | User invokes the skill without specifying a target. | Branch name via `git status`. Owner/repo from git remote URL. |
| **Branch name** | User names a branch (e.g., "check branch `feat/xyz`"). | Branch name directly. Owner/repo from git remote URL. |
| **PR number or URL** | Input matches `#N` or contains `github.com/<owner>/<repo>/pull/<number>`. | Owner, repo, PR number from the URL or `#N` + local repo context. |
| **GitHub Actions URL** | Input contains `github.com/<owner>/<repo>/actions/runs/<run-id>`. | Owner, repo, run ID. Use `gh run view <run-id> --repo <owner>/<repo> --json headBranch,headSha,event` via CLI to get branch and commit. |
| **GitHub Check Run URL** | Input contains `github.com/<owner>/<repo>/runs/<id>` (no `/actions/` prefix). Spacelift reports back to GitHub as check runs, so this is common. | Owner, repo, check run ID. Use `gh api repos/<owner>/<repo>/check-runs/<id>` to get `head_sha`, `name` (contains stack name), `details_url` (direct Spacelift URL with stack ID and run ID), `status`, and `app.name`. |
| **Spacelift URL** | Input contains `<account>.app.spacelift.io/stack/<stack-id>/run/<run-id>`. | Stack ID and run ID directly — skip GitHub and Spacelift discovery, go straight to run detail collection. |
| **Commit URL or SHA** | Input contains `github.com/<owner>/<repo>/commit/<sha>` or looks like a 7–40 char hex string. | Owner, repo, SHA. For bare SHA, owner/repo from git remote URL. |

## Resolution to PR + Head Commit

All input forms must converge to: **owner**, **repo**, **PR number**, **head branch**, **head SHA**.

**From branch name:**

1. `github__list_pull_requests` with `head: "<owner>:<branch>"` and `state: "open"`.
2. If no open PR, try `state: "all"` to find the most recent closed/merged PR.
3. If still no PR, report to user — "No PR found for branch `<branch>`."
4. Read PR via `github__pull_request_read` (method `get`) to get head SHA.

**From PR number/URL:**

1. `github__pull_request_read` with the PR number (method `get`).
2. Extract head branch and head SHA from the response.

**From GitHub Actions URL:**

1. `gh run view <run-id> --repo <owner>/<repo> --json headBranch,headSha,event` via CLI.
2. Use head branch to find the PR (same as "from branch name" above).
3. If the run is not PR-related (`event` is not `pull_request`), use the commit SHA directly for Spacelift discovery — skip PR resolution and note this to the user.

**From GitHub Check Run URL:**

1. `gh api repos/<owner>/<repo>/check-runs/<id> --jq '{name: .name, status: .status, conclusion: .conclusion, head_sha: .head_sha, details_url: .details_url, app_name: .app.name}'` via CLI.
2. The `name` field contains the stack name (e.g., `spacelift/cloud-prd-eu-central-1-acme-2/tracked`). Extract the stack ID from between the first and last `/`.
3. The `details_url` field is a direct Spacelift URL (e.g., `https://<account>.app.spacelift.io/stack/<stack-id>/run/<run-id>`). Parse it to extract stack ID and run ID — then skip Spacelift discovery entirely and go straight to run detail collection.
4. Use `head_sha` to find the associated PR (same as "from commit SHA" below).

**Note:** GitHub MCP tools do not cover check runs or Actions runs. Always use `gh api` / `gh run view` CLI for these.

**From Spacelift URL:**

1. Parse `<stack-id>` and `<run-id>` from the URL path.
2. Skip all GitHub and Spacelift discovery steps — go directly to run detail collection.
3. Optionally resolve the commit SHA from `get_stack_run` to find the associated PR.

**From commit SHA:**

1. `github__list_pull_requests` with `state: "all"` — scan results for a PR whose head SHA matches.
2. Alternatively, `github__search_issues` with query `repo:<owner>/<repo> type:pr <sha>` to find PRs referencing that commit.
3. If no PR found, use the commit SHA directly for Spacelift discovery — skip PR resolution and note this to the user.

## Spacelift Run Discovery

Once you have a **head branch** and/or **head SHA**, find affected Spacelift stacks.

### Step 1: List Stacks

`spacelift-laravel__list_stacks` — get all available stacks.

### Step 2: Find Proposed Runs

For each stack, call `spacelift-laravel__list_stack_proposed_runs`.

A stack is **affected** if it has a proposed run whose branch or commit matches the resolved head branch or head SHA.

### Step 3: Fallback — Recent Runs

If `list_stack_proposed_runs` returns no matches for any stack:

1. For each stack, call `spacelift-laravel__list_stack_runs`.
2. Filter runs by branch name or commit SHA in run metadata.
3. Use the most recent matching run per stack.

### Step 4: No Results

If no affected stacks are found after both steps, report: "No Spacelift stacks were triggered by this branch/commit."

## Run Detail Collection

For each affected stack's run:

| Tool | Purpose |
|---|---|
| `spacelift-laravel__get_stack_run` | Run status, metadata, timing. The `delta` field gives aggregate counts (`addCount`, `changeCount`, `deleteCount`) but does **not** separate moved/imported/removed resources — those are only visible in plan output. |
| `spacelift-laravel__get_stack_run_changes` | Full resource change list (the core data for reports). **May return empty** during APPLYING state or for completed runs — if empty, fall back to log parsing. |
| `spacelift-laravel__get_stack_run_logs` | Full run logs including terraform plan output. Use as **primary fallback** when `get_stack_run_changes` returns empty, and for failed runs to extract error summaries. |

### Log Parsing Fallback

When `get_stack_run_changes` returns empty (common during APPLYING and after FINISHED):

1. Call `get_stack_run_logs` — output may be large, use `skip`/`limit` for pagination if needed.
2. Logs contain **ANSI escape codes** — strip them with `sed 's/\x1b\[[0-9;]*m//g'` before parsing.
3. Look for `Terraform will perform the following actions:` as the start marker.
4. Parse resource actions:
   - `# <address> will be created` → Added.
   - `# <address> will be updated in-place` → Updated.
   - `# <address> must be replaced` (shown as `-/+`) → Recreated.
   - `# <address> will be destroyed` → Deleted.
   - `# <address> has moved to <new-address>` → Moved.
5. Attribute diffs follow each resource block as `~ attribute = old -> new`, `+ attribute = value`, `- attribute = value`.
6. The summary line `Plan: N to add, N to change, N to destroy.` confirms totals.

## Run State Handling

| Run State | Action |
|---|---|
| **Finished** | Full resource change report. |
| **Planning / Planned** | Full resource change report (plan output is available). |
| **Applying** | Show planned changes with note: "Currently applying — changes may still be in progress." |
| **Queued / Preparing** | List the stack with status note: "Run queued — no plan output available yet." |
| **Failed** | Show error summary from logs. Offer to show full logs. |
| **Discarded / Canceled** | Note the run was discarded. If a newer run exists, prefer that instead. |
