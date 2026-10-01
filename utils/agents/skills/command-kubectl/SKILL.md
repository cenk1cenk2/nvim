---
name: command-kubectl
description: command-kubectl When to run kubectl rather than the estate's read-only cluster MCP server, and the approval each invocation needs. Load before running `kubectl` against a live cluster. Not for cluster reads the MCP server can answer, or for changes an ArgoCD resource action covers.
references:
  - ../references/kubernetes.md
---

## Route

- **Reads go through the estate's `kubernetes-*` server.** One read-only server per estate (`kubernetes-kilic` for the kilic clusters, `kubernetes-laravel` for AWS EKS), and only one is present per profile. Load the present one's same-named skill before its first call.
- **`kubectl` is for what that server cannot do**: writes (apply, patch, delete, scale, `exec`, `port-forward`), streaming and tailing (`logs -f`, `get -w`, watch loops), and reads the server has no tool for. Say in one line what the server was missing.
- **A write the estate routes elsewhere goes there first.** When the estate skill names a resource action for it (restart, scale, refresh, run a CronJob now), use that before `kubectl`.
- Job-by-job routing, and the tools the server does and does not register: `kubernetes`.

## Approval

- **Every `kubectl` invocation against a live cluster needs its own approval, even a read.** Name the context and the exact command, then wait. An approval covers that command on that context and nothing else.
- **`blessed for the session` is the one standing grant**, and only when the user's grant covers read-only `kubectl`: the reads it covers then run without a fresh ask for the rest of the session.
- **Writes always gate.** No session blessing, `go`, autopilot, or earlier approval reaches a write; each one is a new ask. A destructive one also needs its own blessing per `AGENTS.md` §V Gates.
- A context you resolved yourself (from the repository, ArgoCD, or a near-match name) goes into the ask as a candidate for the user to confirm.

## Flags That Matter

- **`--context <name>` on every invocation.** The local kubeconfig spans every estate, and an omitted context silently answers about the current default.
- **Pass `-n <namespace>` explicitly** rather than relying on the context's default namespace.
- **Bound reads**: `--tail`, `--since`, `-l` selectors, `-o jsonpath` or `-o yaml` for one resource. Report the finding and the context, not the transcript.

## Failure Modes

- **Unknown context** — list contexts through the MCP server rather than trying spellings.
- **Auth or connection failure** — report it with the context named; do not switch to another context to get an answer.
- **Forbidden** — the credential lacks the verb; report it, never retry under a different identity.
- **`kubectl` not on `PATH`** — resolve it per `AGENTS.md` §IV mise; the MCP server still covers reads.
