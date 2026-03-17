# Output Chunks

Standardized chat output conventions for presenting multi-part analysis, decisions, or proposals in conversation. Use this when the model needs to walk the user through several items that each require understanding or a decision.

## Core Principle

Break output into **numbered chunks**. Each chunk is self-contained — the user can respond to it individually. Start each response with a brief acknowledgment of the previous decision, then present the next chunk.

## Chunk Structure

Each chunk has:

1. **Heading** — `### Chunk N: <Topic>` — names what this chunk covers.
2. **Context** (1-3 sentences) — what is being discussed and why it matters.
3. **Details** — code blocks, tables, comparisons, or examples as needed.
4. **Decision prompt** — what the user needs to decide or confirm. Can be a question, options, or "Thoughts?".

## Flow

1. Present chunks sequentially — one or a small batch per message depending on complexity.
2. Start each follow-up with a brief acknowledgment of the user's previous response.
3. Apply the decision and move to the next chunk.
4. When all chunks are presented, summarize what was decided.

## Grouping

- **Independent items** (e.g., plugin audit) — present 3-5 per message, grouped by category or severity. Each gets a chunk heading.
- **Sequential decisions** (e.g., migration steps) — present 1-2 per message. Each depends on the previous answer.
- **Quick confirmations** — batch into a single chunk with a checklist.

## Format Example

```
### Chunk 1: Client Traffic Timeout

The current nginx config uses `proxy-read-timeout: 300s`. Envoy's equivalent
is `idleTimeout` on the ClientTrafficPolicy.

\```yaml
# ClientTrafficPolicy
timeout:
  http:
    idleTimeout: "120s"
    streamIdleTimeout: "5m"
\```

Setting `idleTimeout` lower than nginx's 300s because envoy's idle timeout
actually resets on data (same behavior), and 120s is the platform standard.

Thoughts?
```

## When a Chunk Includes Comparison

Use a table to show before/after or option comparison:

```
| | current | proposed | why |
|---|---|---|---|
| idle timeout | 300s (nginx) | 120s (envoy) | platform standard, resets on data |
| request timeout | not set | not set | per-route HTTPRoute timeouts handle this |
```

## Scope

This reference applies to conversational output where the user needs to review and decide on multiple items. It does NOT apply to:

- MCP write operations (use `output-diff.md` instead).
- Simple answers or single-item responses.
- Plan files (these have their own structure).
