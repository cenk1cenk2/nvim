# Kubernetes Cluster Inspection

Conventions shared by both cluster MCP servers — `kubernetes-kilic` and `kubernetes-laravel`. Only one is present in any profile; its own skill carries the estate, the transport, and the registered tool surface.

## The Gate — Offer, Never Take

**Reaching into a live cluster is the captain's call, even for a read.** Name the cluster and what you would look at, then wait. This holds for the MCP tools and for a read-only `kubectl` alike, and it is the one carve-out from the rule that reads do not gate (`AGENTS.md` §V).

**The blessing names the cluster.** An approval that does not say which cluster is not an approval for any of them. Where you resolved a candidate yourself — from the repository, from ArgoCD, from a name that looked close enough — it goes into the offer as a candidate for the captain to confirm. Inference produces something to ask about, never something to act on.

**The blessing covers the cluster it named and no other.** A follow-up that moves to a different cluster is a new offer. A question spanning the fleet names every cluster it would touch, or it is not blessed.

**Nothing enforces any of this.** Every registered tool is a read, so the permission lane has nothing to catch and no prompt ever fires. The gate holds only as long as the offer is actually made.

## Every Call Carries `context`

Both servers are multi-cluster, so every tool takes a `context` argument naming the kubeconfig context — **always**, not "when the cluster is known". A call without it answers about whichever context the kubeconfig currently points at, and that answer looks exactly like a correct one: same shape, same fields, wrong cluster. Nothing errors.

**Say the context back in the offer.** The name the captain approves must be the context you then pass — approving one cluster and querying whatever was current is exactly what the gate exists to stop.

**A name that resolves to nothing is a question, not a guess.** Cluster and context names coincide often enough that a near-miss reads as plausible; confirm against the kubeconfig rather than trying a spelling.

## Read With the MCP, Write With `kubectl`

| Job | Route |
|---|---|
| Workloads, resource YAML, cluster inventory | the server's `pods_*` and `resources_*` reads |
| Logs and events | `pods_log`, `nodes_log`, `events_list` |
| Usage and node state | `pods_top`, `nodes_top`, `nodes_stats_summary` |
| Helm releases | `helm_list` |
| Anything that changes state — apply, patch, delete, scale, `exec`, `port-forward` | `kubectl` via `Bash` |
| Streaming — `logs -f`, `get -w`, watch loops | `kubectl` via `Bash` |

Both servers run read-only, so **no mutating tool is registered on either** — `pods_exec`, `pods_run`, `pods_delete`, `resources_create_or_update`, `resources_delete`, `resources_scale`, `helm_install` and `helm_uninstall` are all absent, and a step written against one cannot execute. `kubectl` reads the whole kubeconfig and so spans both estates; the gate above governs it just the same.

## Report the Finding, Not the Transcript

A resource list or log fetch returns far more than the question needs. Answer the question and quote the lines that carry it.
