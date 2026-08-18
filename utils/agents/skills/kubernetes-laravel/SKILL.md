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

**Only route 1 arrives already named.** Route 2 produces a candidate, and a candidate goes into the offer for the captain to confirm — never straight into a call.

## Process

1. Resolve the cluster to a context.
2. **Offer.** Name that cluster and what you would look at. Wait for a word that names the cluster back.
3. Pass `context` on every call — the one the captain blessed, with no exceptions.
4. Route by direction per `kubernetes`.
5. Report the finding, not the transcript.
