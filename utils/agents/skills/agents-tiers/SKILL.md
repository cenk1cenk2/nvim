---
name: agents-tiers
description: 'agents-tiers Explain and resolve the delegation tier-to-model mapping per provider (Claude, OpenCode, Codex). Use on "what are my tiers", "which model is cheap/smart/max", or when a delegation skill must resolve a tier to a concrete model. Do NOT use to dispatch an agent (/agents-delegate) or plan a DAG (/agents-plan).'
references:
  - ../references/agents-tiers-claude.md
  - ../references/agents-tiers-opencode.md
  - ../references/agents-tiers-codex.md
disable-model-invocation: true
---

## Agent Tiers

Delegation picks a **tier** from task complexity, then resolves the tier to a **concrete model** based on the **provider** the session runs on. This skill holds the tier concept and wording; the concrete per-provider model lists live in the references.

## Tiers

| Tier | Intended for | Signals |
|------|--------------|---------|
| cheap | Mechanical implementation | 1-2 files, clear spec, isolated function, template/boilerplate. |
| default | Integration work | Multi-file, pattern matching, moderate judgment. |
| smart | Architecture/design/review | Design decisions, broad codebase understanding, complex reasoning. |
| max | Absolute ceiling | The single hardest problems — deep architecture, subtle correctness, adversarial review. Use sparingly. |

Cost and capability vary by an order of magnitude across tiers — pick the cheapest tier that will succeed.

## User Wording → Tier

| User says | Tier |
|-----------|------|
| "cheap", "fast", "lesser", "quick", "small", "lightweight" | cheap |
| "default", "balanced", "normal", "mid", "medium" | default |
| "smart", "higher", "best", "hard", "heavy", "powerful" | smart |
| "max", "absolute max", "top", "ultra", "strongest", "most capable" | max |

## Per-Provider Model Lists

Resolve the tier to a concrete model using the reference for the **active provider**:

- **Claude / Anthropic** → read the `agents-tiers-claude` reference (built-in `Agent` tool; `haiku`/`sonnet`/`opus`/`fable`).
- **OpenCode** → read the `agents-tiers-opencode` reference (`task` tool; `kilic/*` models).
- **Codex / OpenAI** → read the `agents-tiers-codex` reference (`gpt-*` role models).
- **Other providers** (Google, mixed, custom) → the user declares the mapping; ask, then persist to memory if stable.

## Rules

- **Explicit model names override tiers.** If the user names a model (`fable`, `kilic/glm-5.2:cloud`, `gpt-5.5`), use it verbatim — no remapping.
- **Ask on mismatch.** If the chosen tier/model looks wrong for the task (cheap for architecture, max for a rename), state the mismatch and propose an alternative before dispatching.
- **Ambiguous wording → confirm.** If the user's wording is vague ("better" relative to what?), present the inferred tier with reasoning and confirm before dispatching.
- **Keep in sync.** These lists mirror `~/.config/hyprpilot/config.yaml` and `~/.config/opencode/opencode.jsonc`. When those profiles change, update the per-provider references.
