---
name: kubernetes
description: kubernetes Manual for the read-only Kubernetes MCP server - what it exposes, where kubectl takes over, naming the cluster, and the offer-first gate on touching one. Load before the first call to that server, or on "check the cluster", "what is running on X". Not for authoring manifests, ArgoCD operations, or metrics and logs.
---

## Context

The `kubernetes` server is read-only inspection of live clusters. It runs `--read-only`, so its surface is the `readOnlyHint=true` tools and nothing else. Multi-cluster is on, so every tool takes a `context` argument naming the kubeconfig context.

`kubectl` via `Bash` is the other half: everything that changes state, and everything that streams.

**Editing the catalog entry:** keep `experimental_enable_target_compatibility_tool_filters` off. It runs GVK discovery against every kubeconfig context at startup, 10s per unreachable one, which on a many-context kubeconfig outruns the client's startup handshake.

## The Gate — Offer, Never Take

**Reaching into a live cluster is the captain's call, even for a read.** Name the cluster and what you would look at, then wait. This holds for `kubernetes__*` and for a read-only `kubectl` alike, and it is the one carve-out from the rule that reads do not gate (`AGENTS.md` §V).

**Nothing enforces it.** Every tool on the server auto-accepts, because every registered tool is a read — the permission lane has nothing to catch. The gate holds only as long as the offer is actually made.

## Process

1. **Offer.** Name the cluster and what you would look at. Wait for the word.
2. **Name the cluster on every call.** Pass `context` explicitly whenever the cluster is known. Omitted, it falls to the current context, which is rarely the one meant.
3. **Route by direction** — the table below.
4. **Report the finding, not the transcript.** A resource list or log fetch returns far more than the question needs; answer the question and quote the lines that carry it.

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

## Key Principles

- **Offer before reaching in.** Nothing else stops a cluster read.
- **Name the cluster.** An unqualified call answers about whichever context happens to be current.
- **The kubeconfig carries far more contexts than any one task needs.** `configuration_contexts_list` and `targets_list` return all of them — reach for those only when the context name is genuinely unknown, never as an opening move.
- **Read here, write with `kubectl`.** A write step routed through this server cannot execute.
