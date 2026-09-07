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
- **Estate:** the AWS EKS clusters only. A kilic context is not reachable from this server — that is the point of the split, not a fault to work around.

The gate, the `context` rule, and the read-here-write-with-`kubectl` split: `kubernetes`.

## Read-Only

The server runs `--read-only`, so its surface is the `readOnlyHint=true` tools and nothing else, and no mutating tool is registered. **The exact registered list is not recorded here** — this server is absent from the profile where it could be verified. Check the live tool list before writing a step against a specific tool name; do not assume the kilic surface, which differs.

## Catalog Entry — Keep the Target Filter Off

**`experimental_enable_target_compatibility_tool_filters` must stay off.** It runs GVK discovery against every kubeconfig context at startup, 10s per unreachable one, which on a many-context kubeconfig outruns the client's startup handshake. Edits to the entry go through `config-mcp`.

## Naming the Cluster

Resolve a name to a context in this order, stopping at the first that answers:

1. **The captain named it.** Cloud clusters carry a descriptive context name over an ARN; the context is that name, never the ARN.
2. **Ask the kubeconfig.** `kubectl config get-contexts` via `Bash`, or the server's context-listing tool. Both return every context, far more than any task needs — the last route, never the opening move.

**Only route 1 arrives already named.** Route 2 produces a candidate — query it through the server and name it in the answer, so a wrong resolution shows. A candidate never goes into a `kubectl` command without the captain confirming it.

## Process

1. Resolve the cluster to a context.
2. Pass `context` on every call, with no exceptions.
3. Route by direction per `kubernetes` — server reads run unasked; a `kubectl` command waits for an approval naming that command.
4. Report the finding, not the transcript, and name the context it came from.
