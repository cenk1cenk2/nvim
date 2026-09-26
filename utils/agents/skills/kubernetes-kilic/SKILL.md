---
name: kubernetes-kilic
description: kubernetes-kilic Manual for the kubernetes-kilic MCP server - the kilic clusters, its read-only tool surface, and how a cluster name resolves to a kubeconfig context. Load before the first call to that server. Not for the AWS EKS estate, and not for anything that writes to a cluster.
argumentHint: '[cluster] [what you want to look at]'
references:
  - ../references/kubernetes.md
  - ../references/kilic/kilic-workload-resolution.md
---

## The kubernetes-kilic Server

Read-only inspection of the kilic clusters: `moon`, `nailbed`, `neutrino`, `overseer`, `rancher`, `rubik`, `sun`. **Load this before the first call to it.**

- **Transport:** hosted, `https://kubernetes.mcp.kilic.dev/mcp`, bearer auth.
- **Estate:** its kubeconfig carries the kilic contexts and nothing else, so every context it lists is a valid target. Default context is `nailbed` — pass `context` anyway, on every call.

The gate, the `context` rule, and the read-here-write-with-`kubectl` split: `kubernetes`.

## Read-Only Is Enforced at the Server

**The gating is upstream, not local.** The server runs `--read-only`, so its surface is the `readOnlyHint=true` tools and nothing else. The catalog entry carries no tool filters and sets `autoAcceptTools: ["*"]`, so **no call through this server ever raises a permission prompt** — every registered tool is a read, and the permission lane has nothing to catch. No local change widens that surface.

That is what makes this server standing-blessed: nothing reachable through it changes state, so there is nothing to gate. `kubectl` is the gated lane — per `kubernetes`.

**Common writes go through ArgoCD first.** Operations on a resource that ArgoCD manages have a resource action. That covers restarting or scaling a Deployment, refreshing an ExternalSecret, and running a CronJob now. Load `argocd-kilic` and use its actions before reaching for `kubectl`. `kubectl` is for what has no action.

## Registered Surface — 15 Tools, All Reads

`configuration_contexts_list`, `events_list`, `helm_list`, `namespaces_list`, `nodes_log`, `nodes_stats_summary`, `nodes_top`, `pods_get`, `pods_list`, `pods_list_in_namespace`, `pods_log`, `pods_top`, `projects_list`, `resources_get`, `resources_list`.

Anything else is absent, and a step written against an absent tool cannot execute. Besides the mutations listed in `kubernetes`, that includes **`configuration_view` and `targets_list`** — the upstream project ships them, this server does not register them. `configuration_contexts_list` is the only kubeconfig tool here.

## Naming the Cluster

The seven cluster names above **are** the context names, verbatim — `rubik` the cluster is `rubik` the context. Resolving is only a question when the captain named a workload rather than a cluster:

1. **The repository says it.** Inside a cluster ArgoCD repo (`argocd-<cluster>`), the cluster is in the path.
2. **ArgoCD says it.** An Application's `spec.destination` names the cluster it deploys to, per `kilic-workload-resolution`.
3. **`configuration_contexts_list`.** A blessed read returning all seven with their server URLs — cheap, and the way to settle a spelling.

Naming and confirming the resolved context: `kubernetes`.

Load `argocd-kilic` when the question is about ArgoCD's view of a workload rather than the cluster's own state.

## Process

1. Resolve the cluster to a context.
2. Pass `context` on every call, with no exceptions.
3. Route by direction per `kubernetes` — server reads run unasked; a `kubectl` command waits for an approval naming that command.
4. Report the finding, not the transcript, and name the context it came from.
