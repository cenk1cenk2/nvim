# Agent Tiers — Claude / Anthropic

Tier → model mapping for delegation running on Claude. Mirrors the `*/claude/*` profiles in `~/.config/hyprpilot/config.yaml`. Keep in sync when those change.

**Dispatch:** the built-in `Agent` tool. Its `model` parameter accepts `haiku`, `sonnet`, `opus`, `fable`.

| Tier | Model |
|------|-------|
| cheap | `haiku` |
| default | `sonnet` |
| smart | `opus` |
| max | `fable` (`claude-fable-5`) |

`max`/`fable` is the ceiling — reserve it for the single hardest problems; `smart`/`opus` covers most heavy work.
