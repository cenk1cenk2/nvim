---
name: output-chunks
description: output-chunks Walk through multi-part analysis one decision at a time - numbered self-contained chunks, each ending in a prompt - instead of one wall of findings. Use on "chunk this", "one at a time", "walk me through it". Not for presenting a write for approval, and not for a single-item answer.
disableModelInvocation: true
argumentHint: '[optional: what to walk through]'
references:
  - ../references/mode-toggle.md
---

## Output Chunks — Decision-at-a-Time Presentation

A presentation posture, not a workflow. It changes **how** multi-part analysis reaches the user: as numbered self-contained chunks the user answers one at a time, instead of a single block they must hold in their head.

Use it when the output is several items that each need understanding or a decision — an audit shortlist, a migration walkthrough, a config comparison, a set of findings with different fixes. A wall of ten findings gets skimmed and two get answered; ten chunks get ten answers.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** `/output-chunks`, "chunk this", "one at a time", "walk me through it", "go chunk by chunk", "don't dump it all at once".
- **Off:** "stop chunking", "just give me all of it", "dump it", "normal mode", or the chunk set completing.
- **Survives disengage:** nothing — this mode is presentation only, spawns nothing, and writes nothing.
- Layers under every other mode. It never turns another mode on or off. Under `caveman`, keep the chunk structure and stay terse inside it.

## Chunk Structure

Each chunk has four parts, in order:

1. **Heading** — `### Chunk N: <Topic>` — names what this chunk covers.
2. **Context** (1-3 sentences) — what is being discussed and why it matters.
3. **Details** — code blocks, tables, comparisons, or examples as needed.
4. **Decision prompt** — what the user needs to decide or confirm. A question, a set of options, or "Thoughts?".

A chunk is self-contained: the user can answer it without having read the others.

## Process

1. **Split the work into chunks** before presenting anything. Each chunk is one decision or one coherent group.
2. **Present sequentially** — one chunk, or a small batch, per message depending on complexity.
3. **Open each follow-up with a brief acknowledgment** of the user's previous answer, then move to the next chunk.
4. **Apply each decision as it lands.** Do not batch them to the end — a decision the user already made should be reflected in the chunks that follow it.
5. **Summarize at the end** — what was decided across the whole set.

## Grouping

- **Independent items** (e.g. an audit shortlist) — 3-5 per message, grouped by category or severity. Each gets its own chunk heading.
- **Sequential decisions** (e.g. migration steps) — 1-2 per message. Each depends on the previous answer.
- **Quick confirmations** — batch into a single chunk with a checklist.

Never silently drop items to hit a smaller number. If the set is long, say how many chunks there are up front and keep going.

## Format Example

```
### Chunk 1: Client Traffic Timeout

The current nginx config uses `proxy-read-timeout: 300s`. Envoy's equivalent
is `idleTimeout` on the ClientTrafficPolicy.

    # ClientTrafficPolicy
    timeout:
      http:
        idleTimeout: "120s"
        streamIdleTimeout: "5m"

Setting `idleTimeout` lower than nginx's 300s because envoy's idle timeout
actually resets on data (same behavior), and 120s is the platform standard.

Thoughts?
```

When a chunk compares options, use a table:

```
| | current | proposed | why |
|---|---|---|---|
| idle timeout | 300s (nginx) | 120s (envoy) | platform standard, resets on data |
| request timeout | not set | not set | per-route HTTPRoute timeouts handle this |
```

## Boundaries

- **External writes are `output-diff`, not this.** Any create/update to Linear, GitHub, GitLab, Obsidian, Slack, or Notion follows the `output-diff` conventions — reasoning plus content block, all chunks presented before approval is requested. This skill covers conversational analysis where the user decides item by item.
- **Not for single-item answers.** One finding is one answer, not `### Chunk 1`.
- **Not for plan files.** Plans have their own structure.

## Examples

**User says:** "chunk this" on a 12-item dependency audit

1. Group the 12 into 4 categories by risk.
2. Present chunks 1-2 (high risk) in the first message, each with a decision prompt.
3. User picks fixes for both; acknowledge, apply, present chunks 3-4.
4. Continue until all 12 are covered, then summarize the decisions.

**Result:** every item got an explicit answer instead of the tail being skimmed.

---

**User says:** "walk me through the envoy migration one at a time"

1. Split the migration into sequential chunks — timeouts, routing, TLS, rate limits.
2. Present chunk 1 only, since chunk 2's shape depends on the timeout answer.
3. Apply the answer, then present chunk 2 built on it.

**Result:** later chunks reflect earlier decisions rather than being drafted against assumptions.
