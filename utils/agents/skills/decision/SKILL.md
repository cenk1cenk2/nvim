---
name: decision
description: decision Auto-invoked when a triage, routing, or classification call can be answered from facts already in hand - a small deterministic model answers typed questions (choice, noul, score) with probabilities. Load before the first call to that server. Not for quality judgements, gates, or any answer that must be exact.
argumentHint: '[what you want decided] - e.g. ''is this alert actionable'', ''which area does this message belong to'''
---

## Context

A thin front for the in-cluster ollama decision API. One tool, `decide`: you pass a `state` object and a `questions` object, and a small decision model answers each question with probabilities.

- **Transport:** hosted, `https://decision.mcp.kilic.dev/mcp`, Streamable HTTP, bearer auth via `${AI_KILIC_DEV_API_KEY}`. A call without a key gets 401 `api key authentication failure`.
- **Implementation:** hyprpilot itself, `hyprpilot mcp passthrough --transport http` (server name `hyprpilot-passthrough`). It runs as a Deployment in the `ollama` namespace on `neutrino`, behind the agentgateway Gateway.
- **Forwarding:** the call arguments are merged over a static body pinned in the ConfigMap `.deploy/neutrino/agentgateway/mcps/decision/configmap.yaml` in `cluster/workloads/ollama`, which pins the `model`. Each response's `model` field names the model that answered. The result is POSTed to `http://ollama.ollama.svc.cluster.local:11434/v1/systemone` (ollama's jev-style decision models, https://ollama.com/blog/ollama-now-supports-jev-style-decision-models) and the ollama JSON comes back verbatim as text. A non-2xx or unreachable upstream comes back as an error naming the url. That hostname resolves only inside the cluster, so the MCP route is the only way in from a workstation.
- **Authorization:** agentgateway API-key scope `mcp/decision`. The keys carry the bare `mcp` scope, which satisfies it as a parent prefix.
- **Monitoring:** the blackbox probe (`probe.yaml`) targets the route and expects 401. A 401 there means the route matches, not that something is broken.

Adding, removing, or re-keying the server itself belongs to `config-mcp` and the catalog entry in `utils/agents/mcp/servers.json`.

## Tools

| Tool | Auto-approved | Purpose |
|------|--------------|---------|
| `decision__decide` | Yes | Answer typed questions about a state object with the decision model. Read-only on the estate - it changes nothing, it only returns an answer. |

Arguments, both required objects:

- **`state`** - the context the questions are about, as named fields (`{"alert": "KubePodCrashLooping", "namespace": "<namespace>", "restarts": 14}`).
- **`questions`** - question name to `{type, instructions, criteria}`. Three types:

| Type | `criteria` | Answer |
|---|---|---|
| `choice` | object, option key to description (or `null`) | `choice` (the picked key), `probabilities` per key, `confidence` |
| `noul` | none | `noul`, the probability that `instructions` holds; no `confidence` |
| `score` | array of ordered levels, lowest first | `score` (expected level index, a float), `legend` index to level, `probabilities` per index, `confidence` |

`confidence` is `1 - entropy / ln(N)` over the returned probabilities: 1 is one option taking everything, 0 is a uniform spread. It measures how peaked the distribution is, nothing more.

Response shape:

```json
{
  "model": "<pinned model>",
  "answers": {
    "severity": { "type": "choice", "choice": "page", "probabilities": { "page": 0.71, "ticket": 0.24, "ignore": 0.05 }, "confidence": 0.34 },
    "actionable": { "type": "noul", "noul": 0.91 },
    "impact": { "type": "score", "score": 1.68, "legend": { "0": "none", "1": "low", "2": "medium", "3": "high" }, "probabilities": { "0": 0.06, "1": 0.38, "2": 0.38, "3": 0.18 }, "confidence": 0.12 }
  },
  "usage": { "input_tokens": 766, "output_tokens": 0 }
}
```

Validation errors come back as a 400 naming the question: an unknown `type` gets `type must be choice, noul, or score`, a `choice` with no criteria gets `choice criteria must map option keys to descriptions or null`, and `score` criteria given as objects (`{"description": ..., "score": ...}`) get `score criteria must be an array of descriptions` - pass plain strings.

## What It Is Good At

- **Deterministic.** The same `state` and `questions` return identical probabilities, so an answer can be cached and a regression test can pin one.
- **Order-blind.** Reordering `choice` options leaves the probabilities unchanged.
- **Classification with described options.** Sorting a message into an area, an alert into page / ticket / ignore, a diff into feature / fix / refactor. A clear case lands well above the 0.85 bar with high `confidence`.
- **Reading a structured agent write-up.** Against a promotion review, narrow `choice` questions about what the text states outright - does a stateful workload restart, what changes in the repository - clear the bar with high `confidence`. Narrow, factual questions about a text are its strongest use.
- **Cheap and quick.** A few hundred to a couple of thousand input tokens and no output tokens; every option of every question is scored in one forward pass. The first call after an idle spell also pays the model load, a few seconds.

## Where It Falls Down

- **Capability follows the pinned model.** A weaker model can be confidently wrong on plain facts - reading a changed value backwards, missing an explicit ask, labelling every diff the same kind - with the winner above the bar. When the response's `model` differs from the last one you checked, run a few questions with known answers first and trust it only once they come back right.
- **Quality judgements.** Rating a vague commit message against a large rewrite splits between the top rubric levels, even with every level described. It cannot grade.
- **Judgement calls stay undecided.** "Can this diff merge without tests" as a two-option `choice` stays well under the bar with low `confidence`. The `choice` form shows the indecision that `noul` hides.
- **Holistic verdicts over mixed evidence.** A healthy report that mentions an unrelated earlier crash comes back near a coin flip on its overall verdict, while the narrow "did the deploy cause a crash" on the same text answers clearly. A label word such as `HEALTHY` anywhere in `state` swings the verdict towards it - the model latches on to label words.
- **The requested action echoes back.** A `state` carrying the record of what was already asked for - a Kargo promotion request whose `action` field says `promote` - pulls the `promote` choice up, and signal cannot be told from echo. Strip the requested-action field from `state` when asking whether to take that action.
- **Context drift.** The same `noul` moves noticeably when unrelated fields are added to or removed from `state`.
- **Literal checks.** "the message contains the word `stuff`" swings with naming and batching. String matching belongs in code.
- **`null` criteria change the answer.** Dropping descriptions can flip a pick; the descriptions carry real weight.

## Process

1. **Check the question fits.** Classification, routing, and triage over clear options fit. Grading, gating, and anything code can compute exactly do not - do those another way.
2. **Frame the state.** Put only the fields the questions need into `state`, named plainly. Every extra field moves the answers, and any word matching an option key leaks the answer - strip the labels of what the question itself asks (a review's own verdict tag when you ask for its verdict), and keep every other word, because masking evidence ("the earlier stage was HEALTHY") removes what a question needs. Pass the text whole; a truncated write-up loses its closing sections, where the asks usually sit. Name every question neutrally for what it asks (`contains_stuff`, `q1`), never for the answer you expect.
3. **Decompose a verdict into narrow questions.** Ask the factual parts (did the deploy cause a crash, does a stateful workload restart, what changes in the repository) and combine them in your own logic, rather than asking for the overall verdict in one question.
4. **Prefer `choice` over `noul` for anything that needs judgement.** A two-option `choice` with described options (`"yes": "needs tests before merge"`, `"no": "safe to merge as is"`) exposes indecision through `confidence`, where `noul` hides it behind a single number. Keep `noul` for plainly factual, positively phrased claims.
5. **Write every criterion as a description.** Each `choice` key's value says what the option means (`"page": "needs a human now"`). Order `score` levels lowest first, because `score` is the expected index over that order.
6. **Batch related questions into one call.** Every question sees the same `state`, and the cost barely moves.
7. **Read the distribution, then decide.** Act on a `choice` when the winner is at or above 0.85; treat a `noul` as yes at or above 0.85 and no at or below 0.15; anything between is undecided. Report the winner with its probability and `confidence`, and say which threshold you used when it differs.

## Pitfalls

- **Advisory only.** It triages and routes; it does not authorize. Never let a `decide` answer stand in for a gate the guidelines put on a human (destructive actions, external writes, `kubectl`).
- **`score` is a float.** 1.68 on a four-level scale sits between `low` and `medium`; round only if you say so. Over a rich `state` a multi-level `score` often comes back near-uniform with `confidence` near 0 where `choice` and `noul` on the same state hold, so treat flat probabilities as undecided, not the float as a verdict.
- **Pass only `state` and `questions`.** Call arguments merge over the ConfigMap body, so an extra `model` key replaces the pinned model - an unknown one comes back as a 404 `model "<name>" not found`. Change the model in the ConfigMap, not per call.
- **No state across calls.** Each `decide` is independent; resend the full `state` every time.

## Examples

**Triage an incoming message.**

1. `state`: `{"message": "<message text>"}`.
2. `questions`: `area` as a `choice` over described areas, `urgency` as a `score` over `["low", "medium", "high", "critical"]`.
3. `area` clears the bar for one key, so route there; `urgency` returns a float between `high` and `critical`, reported as such.

**Triage a promotion review.**

1. `state`: the review body with its verdict tag and `Verdict:` line removed, plus the "waiting on you" text.
2. `questions`: `repo_change` and `stateful_restart` as described `choice`s, `verdict` as a `choice` over described SAFE / CAUTION / BLOCK.
3. Route on the narrow answers; take `verdict` only when it clears 0.85 and agrees with them.

**Decide whether a diff needs tests.**

1. `state`: `{"diff_summary": "<summary>"}`.
2. `questions`: `needs_tests` as a two-option `choice`, both options described.
3. It stays below the bar with low `confidence`, so report it undecided and make the call yourself.
