---
name: decision
description: decision Manual for the decision MCP server - ask a small decision model typed questions (choice, noul, score) about a piece of state and get probabilities back. Use for routing, triage, and advisory yes/no checks. Load before the first call to that server. Not for open-ended reasoning, generation, or anything whose answer must be exact.
disableModelInvocation: true
argumentHint: '[what you want decided] - e.g. ''is this alert actionable'', ''which model should take this prompt'''
---

## The decision Server

## Context

A thin front for the in-cluster ollama decision API. One tool, `decide`: you pass a `state` object and a `questions` object, and a small decision model answers each question with probabilities. **Load this before the first call to it.**

- **Transport:** hosted, `https://decision.mcp.kilic.dev/mcp`, Streamable HTTP, bearer auth via `${AI_KILIC_DEV_API_KEY}`. A call without a key gets 401 `api key authentication failure`.
- **Implementation:** hyprpilot itself, `hyprpilot mcp passthrough --transport http` (server name `hyprpilot-passthrough`, v3.23.1 verified live). It runs as a Deployment in the `ollama` namespace on `neutrino`, behind the agentgateway Gateway.
- **Forwarding:** the call arguments are merged over a static body pinned in the ConfigMap `.deploy/neutrino/agentgateway/mcps/decision/configmap.yaml` in `cluster/workloads/ollama`, which adds `model: tev1:4b-q4_K_M`. The result is POSTed to `http://ollama.ollama.svc.cluster.local:11434/v1/systemone` (ollama's jev-style decision models, https://ollama.com/blog/ollama-now-supports-jev-style-decision-models) and the ollama JSON comes back verbatim as text. A non-2xx or unreachable upstream comes back as an error naming the url.
- **Authorization** - agentgateway API-key scope `mcp/decision`. The keys carry the bare `mcp` scope, which satisfies it as a parent prefix.
- **Monitoring:** the blackbox probe (`probe.yaml`) targets the route and expects 401. A 401 there means the route matches, not that something is broken.

Adding, removing, or re-keying the server itself belongs to `config-mcp` and the catalog entry in `utils/agents/mcp/servers.json`.

## Tools

| Tool | Auto-approved | Purpose |
|------|--------------|---------|
| `decision__decide` | Yes | Answer typed questions about a state object with the decision model. Read-only on the estate - it changes nothing, it only returns an answer. |

Arguments, both required objects:

- **`state`** - the context the questions are about, as named fields (`{"alert": "KubePodCrashLooping", "namespace": "ollama", "restarts": 14}`).
- **`questions`** - question name to `{type, instructions, criteria}`. Three types:

| Type | `criteria` | Answer |
|---|---|---|
| `choice` | object, option key to description | `choice` (the picked key), `probabilities` per key, `confidence` |
| `noul` | none | `noul`, the probability that `instructions` holds |
| `score` | array of ordered levels, lowest first | `score` (expected level index, a float), `legend` index to level, `probabilities` per index, `confidence` |

Response shape, verified with a live call:

```json
{
  "model": "tev1:4b-q4_K_M",
  "answers": {
    "severity": { "type": "choice", "choice": "page", "probabilities": { "page": 0.71, "ticket": 0.24, "ignore": 0.05 }, "confidence": 0.34 },
    "actionable": { "type": "noul", "noul": 0.91 },
    "impact": { "type": "score", "score": 1.68, "legend": { "0": "none", "1": "low", "2": "medium", "3": "high" }, "probabilities": { "0": 0.06, "1": 0.38, "2": 0.38, "3": 0.18 }, "confidence": 0.12 }
  },
  "usage": { "input_tokens": 766, "output_tokens": 4 }
}
```

## Process

1. **Frame the state.** Put only the fields the questions need into `state`, named plainly. The model is 4B parameters, so noise in the state costs accuracy.
2. **Pick the type per question.** One of N routes is `choice`, a yes/no check is `noul`, a graded rating is `score`. Batch related questions into one call - every question sees the same `state`.
3. **Write criteria as descriptions, not labels.** For `choice`, each key's value says what that option means (`"page": "needs a human now"`). For `score`, order the levels lowest first, because `score` is the expected index over that order.
4. **Read the probabilities, not just the pick.** Report the winning option with its probability and `confidence`, and treat a flat distribution as "undecided" rather than as an answer.

## Pitfalls

- **Advisory only.** A 4B decision model triages and routes; it does not authorize. Never let a `decide` answer stand in for a gate the guidelines put on a human (destructive actions, external writes, `kubectl`).
- **Low confidence is common.** The live sample returned `confidence` 0.12 on a `score` and 0.34 on a `choice`. There is no documented threshold - pick one for the use case and say which you used.
- **`score` is a float.** 1.68 on a four-level scale sits between `low` and `medium`; round only if you say so.
- **Pass only `state` and `questions`.** The model is pinned in the ConfigMap body, and call arguments merge over that body, so an extra `model` key would override the pin (per the merge order; not exercised live). The tool schema declares only the two fields. Change the model in the ConfigMap, not per call.
- **No state across calls.** Each `decide` is independent; resend the full `state` every time.
