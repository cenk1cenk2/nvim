---
name: argocd-kilic
description: argocd-kilic Operate ArgoCD interactively - roll over deployments, refresh external secrets, fetch logs, investigate sync and pending-prune state, browse resources. Use on "check argocd", "why hasn't this synced", "roll over deployments". Not for authoring workload configuration, triggering a sync or prune confirm (ArgoCD UI only), or MCP server setup.
disableModelInvocation: true
argumentHint: '[operation] [application] - e.g. ''roll over deployments for my-app'', ''logs for notifications'''
---

## ArgoCD Operator

## Context

This skill uses the `argocd-kilic` MCP server to operate on ArgoCD applications. The server connects to the ArgoCD instance and exposes tools for reading application state, fetching logs, and running resource actions.

**Transport:** hosted, `https://argocd.mcp.kilic.dev/mcp`, bearer auth.

Load `kubernetes-kilic` when a question needs the cluster itself rather than ArgoCD's view of it.

## Tools

| Tool | Auto-approved | Purpose |
|------|--------------|---------|
| `argocd-kilic__list_applications` | Yes | Find applications by name (supports partial search). |
| `argocd-kilic__get_application` | Yes | Get app details — sync status, health, source, destination. |
| `argocd-kilic__get_appproject` | Yes | Get an AppProject — allowed destinations, source repos, cluster/namespace resource whitelists for the group of applications scoped to it. |
| `argocd-kilic__list_clusters` | Yes | List clusters registered with ArgoCD — server URL, name, connection state, API versions. Resolves a `destination.server` on an app to the cluster name. |
| `argocd-kilic__get_application_resource_tree` | Yes | List all Kubernetes resources managed by an app. |
| `argocd-kilic__get_application_managed_resources` | Yes | Get managed resources with filtering (kind, namespace, name). |
| `argocd-kilic__get_application_workload_logs` | Yes | Fetch logs for a workload (Deployment, StatefulSet, Pod). |
| `argocd-kilic__get_application_events` | Yes | Get application-level events. |
| `argocd-kilic__get_resource_events` | Yes | Get events for a specific managed resource. |
| `argocd-kilic__get_resources` | Yes | Get full resource manifests. |
| `argocd-kilic__get_resource_actions` | Yes | List available actions on a resource — `restart`/`scale`/`pause`/`resume` on a Deployment, `refresh` on an ExternalSecret, `toggle-auto-sync` on an Application that is itself a managed resource of a parent app-of-apps. |
| `argocd-kilic__run_resource_action` | **No — requires user approval** | Execute one of those actions. |

**There is no `sync_application` tool, and no resource action triggers a sync or confirms a prune.** Verified directly: `get_resource_actions` against a child `Application` resource (one managed by a parent app-of-apps) registers only `toggle-auto-sync` — nothing named `sync`, `refresh-and-sync`, or `confirm-prune`. Syncing and prune confirmation happen in the ArgoCD UI, never through this server — see "Automated Sync, Prune=confirm, and Kargo" below.

### Resource Actions Are the Write Path for Day-2 Operations

`kubernetes-kilic` is read-only, so common operations on a running workload go through `run_resource_action` here rather than through `kubectl`. That means rolling a Deployment, refreshing an ExternalSecret, scaling, pausing a rollout, or triggering a CronJob. This works on any resource an Application manages, one action per call, with approval each time.

| Kind | Actions | Source |
|---|---|---|
| `Deployment` | `restart`, `scale`, `pause`, `resume` | verified live |
| `ExternalSecret` | `refresh` | verified live |
| child `Application` (app-of-apps) | `toggle-auto-sync` | verified live |
| `StatefulSet`, `DaemonSet` | `restart` (StatefulSet also `scale`) | ArgoCD built-in, unverified here |
| `CronJob` | `create-job` (run it now), `suspend`, `resume` | ArgoCD built-in, unverified here |
| Argo `Rollout` | `restart`, `promote-full`, `abort`, `retry`, `pause`, `resume` | ArgoCD built-in, unverified here |

The table is a guide, not a contract. The actions a resource actually offers are whatever `get_resource_actions` returns for it, so list them first and run only a name it returned. A change that must persist, such as a replica count or a suspended CronJob, still belongs in git. An action is live state that the next sync may revert. Anything with no action (delete, exec, edit) stays with `kubectl` under its own approval, per `kubernetes-kilic`.

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
- A `destination.server` URL rather than a cluster name — `list_clusters` maps it to the cluster's name and connection state.

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

**Any Other Resource Action** (scale, pause/resume, run a CronJob now, promote a Rollout)

1. `get_application_managed_resources` filtered by kind/name, or `get_application_resource_tree`, to get the resource ref (uid, group, version, kind, namespace, name).
2. `get_resource_actions` on it, and offer only the names it returns.
3. Summarize the action, the target, and whether the next sync will revert it. Run `run_resource_action` after confirmation.

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
5. **`OutOfSync` with a resource that no longer exists in git is usually a pending prune, not an error** — per "Automated Sync, Prune=confirm, and Kargo" below, that state is expected and waits on a human, not on a fix.
6. Summarize findings:
   - Overall sync status and health.
   - Which resources are failing and why.
   - Error messages from events.
   - Suggest next steps (fix source; if it is a pending prune, tell the user it needs confirming in the ArgoCD UI — this server has no tool for that).

---

**Investigate Pending Sync / Prune State**

This skill cannot trigger a sync or confirm a prune — see "Automated Sync, Prune=confirm, and Kargo" below. When the user asks to "sync the app" or "why hasn't this synced":

1. `get_application` — check `status.sync.status` and `status.operationState` for an in-progress or failed operation.
2. If `OutOfSync` with automated sync enabled, it is almost always one of:
   - **A pending prune** — a resource removed from git is staged for deletion and is waiting on a human to confirm it in the ArgoCD UI.
   - **A Kargo promotion that has not landed yet** — the chart-pin bump commit has not reached `main`, or the Stage has not promoted. Say so and point at Kargo rather than guessing at an ArgoCD-side cause.
   - **Self-heal fighting a manual change** — `selfHeal: true` reverts a manual edit on its own, usually within seconds; a repeat `OutOfSync` on the same field a moment later confirms this rather than a stuck sync.
3. Report the state and, for a pending prune, tell the user exactly what to confirm and where (ArgoCD UI, that application) — never attempt a workaround through `run_resource_action` or a K8s-level delete.

---

**List / Search Applications**

1. `list_applications` with optional `search` term.
2. Present results as a table: name, project, sync status, health, destination.

---

**Get Application Details**

1. `get_application` for full details.
2. Optionally `get_application_resource_tree` if the user wants to see managed resources.
3. Optionally `get_appproject` on `spec.project` for the project's allowed destinations, source repos, and resource whitelists — useful when a sync is blocked by an RBAC/scope mismatch rather than a resource error.
4. Present: source repo, target revision, destination cluster/namespace, sync status, health, conditions.

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

## Automated Sync, Prune=confirm, and Kargo

Applications generated by the `argocd-system` ApplicationSets run `automated: { enabled: true, prune: true, selfHeal: true }` — creating and updating resources already described in git happens on its own the moment a commit lands, with no agent or human action. **Deleting** one is the one thing that stays manual: every ApplicationSet and every generated Application carries `argocd.argoproj.io/sync-options: Prune=confirm`, so ArgoCD stages the deletion and waits for a human to confirm it in the ArgoCD UI rather than pruning automatically. `Prune=confirm` alone covers both the resource-level prune and the cascade-delete path (verified against the ArgoCD v3.5.0 source in `argocd-system`'s own `CLAUDE.md`) — there is no separate `Delete=confirm` to look for. **No tool on this server reaches that confirmation** — not `run_resource_action`, and not the `toggle-auto-sync` action available on a child `Application` (that only pauses/resumes automated sync, it does not sync or prune anything by itself).

**Retiring a whole component is a separate, higher gate.** The ApplicationSets set `applicationsSync: create-update`, so they never delete a generated `Application` object even when a cluster stops matching its selector — the `Application` (and, with `preserveResourcesOnDeletion: true`, its resources) is orphaned and keeps running. Actually destroying a component is a two-pass git change owned by `argocd-system`'s own `demote-application` / `remove-base-application` procedures (arm the deletion opt-in in one MR, confirm the prune, then remove the definition in a second) — point the user at that repository rather than improvising a `kubectl` or ArgoCD CLI delete.

**Kargo drives the promotion that produces the git commit ArgoCD then syncs — it does not call ArgoCD's sync API.** There is no Kargo MCP server; this is learned from the `cluster/kargo-root` and `cluster/charts/chart-kargo` repositories, not from a tool. Per component, a Kargo `Warehouse` subscribes to that component's chart repository's semver git tags; one `Stage` per environment (`development`, `platform`, `production`, `load-balancer`, chained through a `prevEnv` gate on the previous environment's report) promotes new Freight by running a shared `ClusterPromotionTask` that clones `cluster/argocd-system`, bumps `spec.template.spec.sources[0].targetRevision` in that environment's `<env>/<component>/patch-applicationset.yaml`, and commits it. Once that commit reaches `main`, the ApplicationSet's own automated sync — already enabled, no trigger needed — picks it up like any other change. So a "why hasn't the new version rolled out" question splits in two: whether Kargo has promoted yet (a Kargo/`kargo-root` question this skill cannot answer) and whether ArgoCD has synced the commit once it landed (an `argocd-kilic` question — check `get_application`'s revision and sync status). `kargo-root` currently holds a Project (`kargo-argocd-system-<component>`) for every one of `argocd-system`'s ~28 base components, not only the handful its own README names as examples.

## Key Principles

- **Ask, don't guess.** When the application or resource is ambiguous, use search tools to present options rather than assuming.
- **Confirm before mutating.** Always summarize what `run_resource_action` will do and get explicit user confirmation.
- **This skill investigates; it does not sync or prune.** A sync is either automatic (a git commit already landed) or waits on a human confirming a prune in the ArgoCD UI — never route around that by hand.
- **Use resource trees for discovery.** The resource tree is the map — use it to find what resources exist before operating on them.
- **Present structured output.** When listing apps or resources, use tables or formatted lists for readability.
- **Chain operations naturally.** If the user asks to "rollover and then check logs", execute both in sequence without re-asking for the application.
