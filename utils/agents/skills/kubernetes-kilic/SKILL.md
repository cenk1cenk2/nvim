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
- **Estate:** the kilic clusters only. A context belonging to the AWS EKS estate is not reachable from this server — that is the point of the split, not a fault to work around.

The gate, the `context` rule, and the read-here-write-with-`kubectl` split: `kubernetes`.

## Read-Only Is Enforced at the Server

**The gating is upstream, not local.** The server runs `--read-only`, so its surface is the `readOnlyHint=true` tools and nothing else. The catalog entry carries no tool filters and sets `autoAcceptTools: ["*"]`, so **no call through this server ever raises a permission prompt** — every registered tool is a read, and the permission lane has nothing to catch. No local change widens that surface.

That is precisely why the offer-first gate matters: nothing mechanical stands between you and a cluster read.

## Registered Surface — 15 Tools, All Reads

`configuration_contexts_list`, `events_list`, `helm_list`, `namespaces_list`, `nodes_log`, `nodes_stats_summary`, `nodes_top`, `pods_get`, `pods_list`, `pods_list_in_namespace`, `pods_log`, `pods_top`, `projects_list`, `resources_get`, `resources_list`.

Anything else is absent, and a step written against an absent tool cannot execute. Besides the mutations listed in `kubernetes`, that includes **`configuration_view` and `targets_list`** — the upstream project ships them, this server does not register them. `configuration_contexts_list` is the only kubeconfig tool here.

## Naming the Cluster

Resolve a name to a context in this order, stopping at the first that answers:

1. **The captain named it.** kilic clusters are their own context name verbatim — `rubik` the cluster is `rubik` the context.
2. **The repository says it.** Inside a cluster ArgoCD repo (`argocd-<cluster>`), the cluster is in the path.
3. **ArgoCD says it.** An Application's `spec.destination` names the cluster it deploys to, per `kilic-workload-resolution`.
4. **Ask the kubeconfig.** `kubectl config get-contexts` via `Bash`, or `configuration_contexts_list`. Both return every context, far more than any task needs — the last route, never the opening move.

**Only route 1 arrives already named.** Routes 2 to 4 produce a candidate, and a candidate goes into the offer for the captain to confirm — never straight into a call.

Load `argocd-kilic` when the question is about ArgoCD's view of a workload rather than the cluster's own state.

## Process

1. Resolve the cluster to a context.
2. **Offer.** Name that cluster and what you would look at. Wait for a word that names the cluster back.
3. Pass `context` on every call — the one the captain blessed, with no exceptions.
4. Route by direction per `kubernetes`.
5. Report the finding, not the transcript.
