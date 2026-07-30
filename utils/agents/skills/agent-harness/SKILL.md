---
name: agent-harness
description: 'agent-harness Resolve how the ACTIVE agent runtime dispatches subagents - tier-to-model mapping, foreground vs background, permission inheritance, result collection, limits - for Claude Code, OpenCode, and Codex. Use on "what are my tiers", "which model is cheap/smart/max", "how do background agents work here", or when a delegation skill must resolve a tier or a dispatch mechanic. Do NOT use to dispatch an agent (/agents-delegate) or plan a DAG (/agents-plan).'
references:
  - ../references/harness-claude-agents-delegate.md
  - ../references/harness-opencode-agents-delegate.md
  - ../references/harness-codex-agents-delegate.md
  - ../references/harness-claude-agent-background.md
  - ../references/harness-opencode-agent-background.md
  - ../references/harness-codex-agent-background.md
disableModelInvocation: true
---

## Agent Harness

Delegation is written once and runs on whichever agent runtime is active. Two things vary per runtime and must never be assumed:

1. **Which model a tier resolves to** — `cheap`/`default`/`smart`/`max` are concepts here, concrete models in the references.
2. **How dispatch actually behaves** — whether background is the default, whether a finished agent wakes you, what permissions it runs with, what tools it keeps, what limits apply.

The second one is where runs get destroyed. A skill body describes intent ("dispatch a subagent", "run it detached"); this skill and its references own the mechanics.

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

## Per-Harness References

Harness references are named **`harness-<provider>-<skill-or-reference-name>`** — one file per (runtime × consuming skill), so a skill loads exactly the mechanics it needs and nothing else. Read the file for the **active runtime** before the first dispatch or the first wait.

| Consumer | Claude Code | OpenCode | Codex |
|----------|-------------|----------|-------|
| Dispatch (`agents-delegate` and every skill built on it) | `harness-claude-agents-delegate` | `harness-opencode-agents-delegate` | `harness-codex-agents-delegate` |
| Waiting and waking (`agent-background`) | `harness-claude-agent-background` | `harness-opencode-agent-background` | `harness-codex-agent-background` |

Tier → model tables live in the **`agents-delegate`** file for each runtime.

Headlines per runtime:

- **Claude Code** — built-in `Agent` tool; `haiku`/`sonnet`/`opus`/`fable`. Background by default, results arrive as a completion notification, permissions are **inherited from the session** (the dispatch `mode` parameter is deprecated and ignored), background agents run with a reduced built-in tool set, and concurrency/nesting/session caps apply.
- **OpenCode** — `task` tool; `kilic/*` models. Blocking dispatch, no timeout parameter, short shell timeout that bounds every wait.
- **Codex / OpenAI** — `gpt-*` role models. **Background work does not wake the caller** — poll or block, in dispatch and in waiting alike.
- **Other providers** (Google, mixed, custom) — the user declares the mapping; ask, then persist to memory if stable. Add a `harness-<provider>-<consumer>` file once the behavior is known.

## Rules

- **Read the active runtime's reference before dispatching, not after something breaks.** The failure modes differ per runtime and several of them are silent.
- **Never carry one runtime's behavior to another.** Background-by-default, wake-on-completion, and permission inheritance are all Claude Code specifics.
- **Explicit model names override tiers.** If the user names a model (`fable`, `kilic/glm-5.2:cloud`, `gpt-5.5`), use it verbatim — no remapping.
- **Ask on mismatch.** If the chosen tier/model looks wrong for the task (cheap for architecture, max for a rename), state the mismatch and propose an alternative before dispatching.
- **Ambiguous wording → confirm.** If the user's wording is vague ("better" relative to what?), present the inferred tier with reasoning and confirm before dispatching.
- **Version claims decay.** The references carry version markers and explicit "unverified" flags. When behavior contradicts a reference, verify against the running build's own tool schemas and docs, then fix the reference — do not special-case the runtime inside a skill body.
- **Keep in sync.** Model lists mirror `~/.config/hyprpilot/config.yaml` and `~/.config/opencode/opencode.jsonc`. When those profiles change, update the per-harness references.
