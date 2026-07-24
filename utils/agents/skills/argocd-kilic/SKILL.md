---
name: argocd-kilic
description: argocd-kilic Operate ArgoCD interactively — rollover deployments, refresh external secrets, fetch logs, investigate sync errors, sync apps, and browse resources. Use when user says "use argocd mcp for", "rollover deployments", "refresh external secret", "check argocd", "sync the app", or "get logs from argocd". Do NOT use for creating ArgoCD workload configs (/argocd-kilic-workload) or MCP server setup (/config-mcp).
references:
  - ../references/present-first.md
disable-model-invocation: true
argument-hint: "[operation] [application-name] - e.g., 'rollover deployments for my-app', 'logs for notifications', 'investigate sync error on cert-manager'"
---

## ArgoCD Operator

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Context

This skill uses the `argocd-kilic` MCP server to operate on ArgoCD applications. The server connects to the ArgoCD instance and exposes tools for reading application state, fetching logs, and running resource actions.

**MCP server:** `argocd-kilic` (stdio, `argocd-mcp`).

## Tools

| Tool | Auto-approved | Purpose |
|------|--------------|---------|
| `argocd-kilic__list_applications` | Yes | Find applications by name (supports partial search). |
| `argocd-kilic__get_application` | Yes | Get app details — sync status, health, source, destination. |
| `argocd-kilic__get_application_resource_tree` | Yes | List all Kubernetes resources managed by an app. |
| `argocd-kilic__get_application_managed_resources` | Yes | Get managed resources with filtering (kind, namespace, name). |
| `argocd-kilic__get_application_workload_logs` | Yes | Fetch logs for a workload (Deployment, StatefulSet, Pod). |
| `argocd-kilic__get_application_events` | Yes | Get application-level events. |
| `argocd-kilic__get_resource_events` | Yes | Get events for a specific managed resource. |
| `argocd-kilic__get_resources` | Yes | Get full resource manifests. |
| `argocd-kilic__get_resource_actions` | Yes | List available actions on a resource (restart, refresh, etc.). |
| `argocd-kilic__run_resource_action` | **No — requires user approval** | Execute an action on a resource. |
| `argocd-kilic__sync_application` | **No — requires user approval** | Trigger an application sync. |

## Process

### Step 1: Understand the Request

Parse the user's message to determine:

- **Operation** — what they want to do (rollover, logs, investigate, sync, browse, etc.).
- **Application** — which ArgoCD application. May be explicit or need discovery.
- **Resource** — which specific resource within the app (if applicable).

If any of these are unclear, ask. Do not guess.

### Step 2: Resolve the Application

If the user provides an application name:

- Use `list_applications` with `search` to find matching apps.
- If exactly one match, use it.
- If multiple matches, present the list and ask the user to pick.
- If no matches, tell the user and ask them to clarify.

If the user describes the app indirectly (e.g., "the cert-manager app on rubik"):

- Search by the descriptive term.
- Check the `destination` field to match cluster context if mentioned.

### Step 3: Execute the Workflow

Route to the appropriate workflow based on the operation:

---

**Rollover Deployments / StatefulSets**

1. `get_application_resource_tree` to find Deployment and StatefulSet resources.
2. Present the list of rollover-able resources to the user.
3. Ask which ones to restart (or "all").
4. For each selected resource, `get_resource_actions` to confirm `restart` is available.
5. `run_resource_action` with `restart` for each — summarize what will be restarted and ask for confirmation before executing.

---

**Refresh External Secrets**

1. `get_application_resource_tree` to find ExternalSecret resources.
2. Present the list.
3. Ask which ones to refresh (or "all").
4. For each, `get_resource_actions` to find the refresh action name.
5. `run_resource_action` with the refresh action — confirm before executing.

---

**Fetch Logs**

1. `get_application_resource_tree` to list workloads (Deployments, StatefulSets, Pods).
2. If the user didn't specify which workload, present the list and ask.
3. `get_application_workload_logs` with the selected resource ref and container.
   - If the workload has multiple containers, ask which one.
   - Use the `applicationNamespace` from the app's metadata.
4. Present the logs to the user.

---

**Investigate Sync Errors**

1. `get_application` — check `status.sync` and `status.health` fields.
2. `get_application_events` — look for error/warning events.
3. `get_application_resource_tree` — identify resources with degraded health or sync issues.
4. For resources showing errors, `get_resource_events` to get detailed error messages.
5. Summarize findings:
   - Overall sync status and health.
   - Which resources are failing and why.
   - Error messages from events.
   - Suggest next steps (fix source, sync with prune, etc.).

---

**Sync Application**

1. `get_application` to show current sync status.
2. Tell the user the current state and ask for confirmation.
3. Ask if they want any sync options (prune, dry-run, specific revision).
4. `sync_application` with the chosen options — confirm before executing.
5. After sync, optionally re-check status with `get_application`.

---

**List / Search Applications**

1. `list_applications` with optional `search` term.
2. Present results as a table: name, project, sync status, health, destination.

---

**Get Application Details**

1. `get_application` for full details.
2. Optionally `get_application_resource_tree` if the user wants to see managed resources.
3. Present: source repo, target revision, destination cluster/namespace, sync status, health, conditions.

---

**Get Resource Manifests**

1. `get_application_resource_tree` to list resources.
2. Ask the user which resource(s) they want manifests for.
3. `get_resources` with the selected resource refs.
4. Present the manifests.

---

**Check Resource Events**

1. `get_application_resource_tree` to find the resource.
2. `get_resource_events` with the resource details.
3. Present events chronologically.

## Key Principles

- **Ask, don't guess.** When the application or resource is ambiguous, use search tools to present options rather than assuming.
- **Confirm before mutating.** Always summarize what `run_resource_action` or `sync_application` will do and get explicit user confirmation.
- **Use resource trees for discovery.** The resource tree is the map — use it to find what resources exist before operating on them.
- **Present structured output.** When listing apps or resources, use tables or formatted lists for readability.
- **Chain operations naturally.** If the user asks to "rollover and then check logs", execute both in sequence without re-asking for the application.
