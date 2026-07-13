# Agent Tiers — Codex / OpenAI

Model roles for delegation running on Codex. Mirrors the `personal/codex/*` profiles in `~/.config/hyprpilot/config.yaml` and the `openai` provider in `~/.config/opencode/opencode.jsonc`. Keep in sync when those change.

**Dispatch:** Codex's own task/subagent spawning. Set the resolved `gpt-*` model.

No cheap→max ladder is configured — two role models, both `reasoningEffort: high`:

| Role | Model |
|------|-------|
| general (default) | `gpt-5.5` |
| coding-specialized | `gpt-5.3-codex-spark` |

If a cheap/default/smart/max ladder is needed later, add it here and to the `personal/codex/*` hyprpilot profiles.
