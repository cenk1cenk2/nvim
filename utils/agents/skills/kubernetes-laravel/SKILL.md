---
name: kubernetes-laravel
description: kubernetes-laravel Manual for the kubernetes-laravel MCP server - the AWS EKS clusters, its read-only surface, and the catalog setting that must stay off. Load before the first call to that server. Not for the kilic estate, and not for anything that writes to a cluster.
argumentHint: '[cluster] [what you want to look at]'
references:
  - ../references/kubernetes.md
---

## The kubernetes-laravel Server

Read-only inspection of the AWS EKS clusters. **Load this before the first call to it.**

- **Transport:** local stdio.
- **Estate:** its kubeconfig carries the AWS EKS contexts and nothing else, so every context it lists is a valid target. It still has a default context — pass `context` on every call.

The gate, the `context` rule, and the read-here-write-with-`kubectl` split: `kubernetes`.

## Read-Only

The server runs `--read-only`, so its surface is the `readOnlyHint=true` tools and nothing else, and no mutating tool is registered. **The exact registered list is not recorded here** — this server is absent from the profile where it could be verified. Check the live tool list before writing a step against a specific tool name; do not assume the kilic surface, which differs.

## Catalog Entry — Keep the Target Filter Off

**`experimental_enable_target_compatibility_tool_filters` must stay off.** It runs GVK discovery against every kubeconfig context at startup, 10s per unreachable one, which on a many-context kubeconfig outruns the client's startup handshake. Edits to the entry go through `config-mcp`.

## Naming the Cluster

Cloud clusters carry a descriptive context name over an ARN; the context is that name, never the ARN. When the captain named a workload rather than a cluster, or a spelling needs settling, read the server's context-listing tool — a blessed read over an estate-scoped kubeconfig, so the set comes back small and every entry is reachable.

Query the resolved context through the server and name it in the answer, so a wrong resolution shows. A `kubectl` command against a context you resolved rather than were given waits for the captain to confirm it.

## Process

1. Resolve the cluster to a context.
2. Pass `context` on every call, with no exceptions.
3. Route by direction per `kubernetes` — server reads run unasked; a `kubectl` command waits for an approval naming that command.
4. Report the finding, not the transcript, and name the context it came from.
