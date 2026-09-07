# Kubernetes Cluster Inspection

Conventions shared by both cluster MCP servers — `kubernetes-kilic` and `kubernetes-laravel`. Only one is present in any profile; its own skill carries the estate, the transport, and the registered tool surface.

## The Gate — MCP Reads Are Blessed, `kubectl` Is Not

**The MCP servers carry a standing blessing. Call them as the work needs.** Both run read-only, every registered tool is a read, and reads do not gate (`AGENTS.md` §V) — so a cluster read through the server needs no offer and no wait.

**`kubectl` needs explicit approval, every invocation.** It is the lane that can write, and it spans both estates through the whole kubeconfig. No general go reaches it — not `g` / `go` / `yolo`, not autopilot, not approval of an earlier command. Name the cluster and the exact command, then wait. The permission lane may or may not prompt: the gate holds because you ask, not because a prompt fires.

**A read-only `kubectl` is gated too.** The lane decides, not the verb — `kubectl get` waits the same as `kubectl delete`. Where the server can answer it, use the server and skip the ask entirely.

**An approval covers the command it named and no other.** A different cluster, or a different command against the same cluster, is a new ask. A candidate context you resolved yourself — from the repository, from ArgoCD, from a name that looked close — goes into that ask as a candidate for the captain to confirm.

## Every Call Carries `context`

Both servers are multi-cluster, so every tool takes a `context` argument naming the kubeconfig context — **always**, not "when the cluster is known". A call without it answers about whichever context the kubeconfig currently points at, and that answer looks exactly like a correct one: same shape, same fields, wrong cluster. Nothing errors.

**Name the context in the answer.** A finding that does not say which cluster it came from cannot be checked, and a wrong resolution is invisible without it. For `kubectl`, the context named in the ask is the one the command carries — `--context <name>`, never whatever the kubeconfig currently points at.

**A name that resolves to nothing is a question, not a guess.** Cluster and context names coincide often enough that a near-miss reads as plausible; confirm against the kubeconfig rather than trying a spelling.

## Read With the MCP, Write With `kubectl`

| Job | Route |
|---|---|
| Workloads, resource YAML, cluster inventory | the server's `pods_*` and `resources_*` reads |
| Logs and events | `pods_log`, `nodes_log`, `events_list` |
| Usage and node state | `pods_top`, `nodes_top`, `nodes_stats_summary` |
| Helm releases | `helm_list` |
| Anything that changes state — apply, patch, delete, scale, `exec`, `port-forward` | `kubectl` via `Bash`, approval each time |
| Streaming — `logs -f`, `get -w`, watch loops | `kubectl` via `Bash`, approval each time |

Both servers run read-only, so **no mutating tool is registered on either** — `pods_exec`, `pods_run`, `pods_delete`, `resources_create_or_update`, `resources_delete`, `resources_scale`, `helm_install` and `helm_uninstall` are all absent, and a step written against one cannot execute. `kubectl` reads the whole kubeconfig and so spans both estates — every invocation needs its own approval per the gate above.

## Report the Finding, Not the Transcript

A resource list or log fetch returns far more than the question needs. Answer the question and quote the lines that carry it.
