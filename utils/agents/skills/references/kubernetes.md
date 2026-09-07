# Kubernetes Cluster Inspection

Conventions shared by both cluster MCP servers — `kubernetes-kilic` and `kubernetes-laravel`. Only one is present in any profile; its own skill carries the estate, the transport, and the registered tool surface.

## The Gate — MCP Reads Are Blessed, `kubectl` Is Not

**The MCP servers carry a standing blessing. Call them as the work needs.** Both run read-only, every registered tool is a read, and reads do not gate (`AGENTS.md` §V) — so a cluster read through the server needs no offer and no wait.

**`kubectl` needs explicit approval, every invocation.** It is the lane that can write, and it runs against the local kubeconfig, which is scoped to nothing — every estate, every cluster. No general go reaches it — not `g` / `go` / `yolo`, not autopilot, not approval of an earlier command. Name the cluster and the exact command, then wait. The permission lane may or may not prompt: the gate holds because you ask, not because a prompt fires.

**A read-only `kubectl` is gated too.** The lane decides, not the verb — `kubectl get` waits the same as `kubectl delete`. Where the server can answer it, use the server and skip the ask entirely.

**An approval covers the command it named and no other.** A different cluster, or a different command against the same cluster, is a new ask. A candidate context you resolved yourself — from the repository, from ArgoCD, from a name that looked close — goes into that ask as a candidate for the captain to confirm.

## Every Call Carries `context`

Each server runs against its own estate's kubeconfig, so every context it lists is reachable and every one is a valid target — there is no cross-estate mix-up to guard against. What remains is the one that bites: **a kubeconfig has a default context, and a call omitting `context` silently answers about that one.** The answer looks exactly like a correct one — same shape, same fields, wrong cluster — and nothing errors. So pass `context` on every call, always, not "when the cluster is known".

**Name the context in the answer.** A finding that does not say which cluster it came from cannot be checked. For `kubectl`, the context named in the ask is the one the command carries — `--context <name>`, never whatever the local kubeconfig currently points at.

**Unsure of a name? List the contexts.** The server's context-listing tool is a blessed read over an estate-scoped kubeconfig, so the set comes back small and complete. Read it rather than trying a spelling.

## Read With the MCP, Write With `kubectl`

| Job | Route |
|---|---|
| Workloads, resource YAML, cluster inventory | the server's `pods_*` and `resources_*` reads |
| Logs and events | `pods_log`, `nodes_log`, `events_list` |
| Usage and node state | `pods_top`, `nodes_top`, `nodes_stats_summary` |
| Helm releases | `helm_list` |
| Anything that changes state — apply, patch, delete, scale, `exec`, `port-forward` | `kubectl` via `Bash`, approval each time |
| Streaming — `logs -f`, `get -w`, watch loops | `kubectl` via `Bash`, approval each time |

Both servers run read-only, so **no mutating tool is registered on either** — `pods_exec`, `pods_run`, `pods_delete`, `resources_create_or_update`, `resources_delete`, `resources_scale`, `helm_install` and `helm_uninstall` are all absent, and a step written against one cannot execute. `kubectl` reads the local kubeconfig, so unlike the servers it is scoped to nothing — every invocation needs its own approval per the gate above.

## Report the Finding, Not the Transcript

A resource list or log fetch returns far more than the question needs. Answer the question and quote the lines that carry it.
