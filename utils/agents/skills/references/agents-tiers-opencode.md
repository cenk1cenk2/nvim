# Agent Tiers — OpenCode

Tier → model mapping for delegation running on OpenCode. Mirrors `~/.config/opencode/opencode.jsonc` (`model`, `small_model`) and the `personal/kilic/*` profiles in `~/.config/hyprpilot/config.yaml`. Keep in sync when those change.

**Dispatch:** the OpenCode `task` tool (subagent dispatch, allowed in `opencode.jsonc`). Set the subagent's model to the resolved `kilic/*` slug.

| Tier | Model |
|------|-------|
| cheap | `kilic/gemma4:31b-cloud` (opencode `small_model`) |
| default | `kilic/glm-5.2:cloud` (opencode `model`, reasoningEffort `max`) |
| smart | `kilic/deepseek-v4-pro:cloud` |
| max | `kilic/deepseek-v4-pro:cloud` (no distinct ceiling above smart) |

Off-ladder alternates in the `kilic` provider: `kilic/deepseek-v4-flash:cloud` (faster), `kilic/kimi-k2.7-code:cloud` (coding), `kilic/minimax-m3:cloud`.
