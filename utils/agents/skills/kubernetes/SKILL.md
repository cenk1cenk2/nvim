---
name: kubernetes
description: kubernetes Manual for the read-only Kubernetes MCP server - what it exposes, where kubectl takes over, resolving a cluster to a context, and the offer-first gate the captain names the cluster in. Load before the first call to that server, or on "check the cluster", "what is running on X". Not for authoring manifests, ArgoCD operations, or metrics and logs.
references:
  - ../references/kilic/kilic-workload-resolution.md
---

## Context

Read-only inspection of live clusters, split across two servers — one per estate, and only one of them is present in any given profile:

| Server | Estate | Transport |
|---|---|---|
| `kubernetes-kilic` | the kilic clusters — `moon`, `nailbed`, `neutrino`, `overseer`, `rancher`, `rubik`, `sun` | hosted, `kubernetes.mcp.kilic.dev` |
| `kubernetes-laravel` | the AWS EKS clusters | local stdio |

Both run `--read-only`, so the surface is the `readOnlyHint=true` tools and nothing else, and both are multi-cluster, so every tool takes a `context` argument naming the kubeconfig context. The tables below write `kubernetes__*` for tool names; read it as whichever of the two the profile loaded.

The estate follows from the cluster, so resolving the cluster (below) also picks the server. A context that belongs to the other estate is not reachable from the server you have — that is the point of the split, not a fault to work around.

`kubectl` via `Bash` is the other half: everything that changes state, and everything that streams. `kubectl` reads the whole kubeconfig and so spans both estates; the gate below governs it just the same.

**Editing the `kubernetes-laravel` catalog entry:** keep `experimental_enable_target_compatibility_tool_filters` off. It runs GVK discovery against every kubeconfig context at startup, 10s per unreachable one, which on a many-context kubeconfig outruns the client's startup handshake.

## The Gate — Offer, Never Take

**Reaching into a live cluster is the captain's call, even for a read.** Name the cluster and what you would look at, then wait. This holds for `kubernetes__*` and for a read-only `kubectl` alike, and it is the one carve-out from the rule that reads do not gate (`AGENTS.md` §V).

**The blessing names the cluster.** An approval that does not say which cluster is not an approval for any of them. Where you resolved a candidate yourself — from the repository, from ArgoCD, from a name that looked close enough — it goes into the offer as a candidate for the captain to confirm. Inference produces something to ask about, never something to act on.

**The blessing covers the cluster it named and no other.** A follow-up that moves to a different cluster is a new offer. A question spanning the fleet names every cluster it would touch, or it is not blessed.

**Nothing enforces any of this.** Every tool on the server auto-accepts, because every registered tool is a read — the permission lane has nothing to catch. The gate holds only as long as the offer is actually made.

## Process

1. **Resolve the cluster to a context** — see Naming the Cluster below.
2. **Offer.** Name that cluster and what you would look at. Wait for a word that names the cluster back.
3. **Pass `context` on every call.** The context the captain blessed, on every call, with no exceptions.
4. **Route by direction** — the table below.
5. **Report the finding, not the transcript.** A resource list or log fetch returns far more than the question needs; answer the question and quote the lines that carry it.

## Read With `kubernetes__*`, Write With `kubectl`

| Job | Route |
|---|---|
| Workloads, resource YAML, cluster inventory | `kubernetes__pods_list`, `pods_get`, `resources_list`, `resources_get`, `namespaces_list` |
| Logs and events | `kubernetes__pods_log`, `nodes_log`, `events_list` |
| Usage and node state | `kubernetes__pods_top`, `nodes_top`, `nodes_stats_summary` |
| Helm releases | `kubernetes__helm_list` |
| Kubeconfig and reachable clusters | `kubernetes__configuration_view`, `configuration_contexts_list`, `targets_list` |
| Anything that changes state — apply, patch, delete, scale, `exec`, `port-forward` | `kubectl` via `Bash` |
| Streaming — `logs -f`, `get -w`, watch loops | `kubectl` via `Bash` |

`pods_exec`, `pods_run`, `pods_delete`, `resources_create_or_update`, `resources_delete`, `resources_scale`, `helm_install` and `helm_uninstall` are absent from this server. A step written against one cannot execute.

## Naming the Cluster

**Every call carries `context`.** Not "when the cluster is known" — always. A call without it answers about whichever context the kubeconfig currently points at, and that answer looks exactly like a correct one: same shape, same fields, wrong cluster. Nothing errors.

Resolve a name to a context in this order, stopping at the first that answers:

1. **The captain named it.** Personal clusters are their own context name verbatim — `rubik` the cluster is `rubik` the context. Cloud clusters carry a descriptive context name over an ARN; the context is that name, never the ARN.
2. **The repository says it.** Inside a cluster ArgoCD repo (`argocd-<cluster>`), the cluster is in the path.
3. **ArgoCD says it.** An Application's `spec.destination` names the cluster it deploys to, per `kilic-workload-resolution`.
4. **Ask the kubeconfig.** `kubectl config get-contexts` via `Bash`, or `configuration_contexts_list`. Both return every context, far more than any task needs — the last route, never the opening move.

**Only route 1 arrives already named.** Routes 2 to 4 produce a candidate, and a candidate goes into the offer for the captain to confirm — never straight into a call.

**A name that resolves to nothing is a question, not a guess.** Cluster and context names coincide often enough that a near-miss reads as plausible; confirm through route 4 rather than trying a spelling.

**Say the context back in the offer.** The name the captain approves must be the context you then pass — approving `rubik` and querying whatever was current is exactly what the gate exists to stop.

## Key Principles

- **Offer before reaching in, and let the captain name the cluster.** Nothing else stops a cluster read, and nothing else decides which cluster it reads.
- **Every call carries `context`.** An unqualified call answers about whichever context happens to be current, and looks right doing it.
- **One blessing, one cluster.** Moving to another cluster is another offer.
- **Read here, write with `kubectl`.** A write step routed through this server cannot execute.
