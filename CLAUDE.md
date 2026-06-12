## Overview

This repository is a personal Neovim configuration forked from LunarVim. Startup flows through `init.lua`, then `ck.config` and `ck.loader`; most behavior is organized as Lua modules under `lua/ck/`. Plugin integrations live in `lua/ck/plugins/` and are registered through the repository's `ck.setup` wrapper.

## Stack & Structure

- **Language:** Lua for Neovim configuration, plus shell utilities under `utils/`.
- **Build/Lint:** `Taskfile.yml` provides `task format` and `task lint`; Lua uses `stylua --config-path .stylua.toml`, and linting also runs `selene`.
- **Key directories:** `lua/ck/config/` for defaults/settings, `lua/ck/keys/` for keybinding helpers, `lua/ck/plugins/` for plugin modules, `after/` for Neovim after-files, `utils/` for scripts and agent tooling.

## Conventions

- Plugin modules should keep `M.config()` first after `M.name`; put plugin-specific constants/helpers on `M.*` after `M.config()` so the main registration is the first thing future agents read.
- Register plugins with `require("ck.setup").define_plugin(M.name, enabled, { plugin = ..., setup = ..., wk = ..., on_setup = ..., keymaps = ... })` and match the surrounding module shape.
- Which-key mappings should use `fn.wk_keystroke({ categories.<GROUP>, ... })` rather than hard-coded leader strings when a category exists.
- Format Lua changes with `stylua --config-path .stylua.toml` and validate with `stylua --config-path .stylua.toml --check` before reporting completion.

## Decision Log

- **Sidekick CLI terminals use central Hyprpilot spawn**
  - Chose: configure `folke/sidekick.nvim` with one Sidekick tool, `hyprpilot`; `<Leader>ctt` launches `hyprpilot spawn`, while `<Leader>ctr` uses the same tool with alternate startup args `hyprpilot spawn --restore`. Both commands append a dynamic `--with-config @<json>` profile patch that injects the current Neovim instance's `hyprpilot-nvim` MCP server via `vim.v.servername`.
  - Why: Hyprpilot owns provider/profile selection for Claude, Codex, and opencode, and restore is just an alternate launch mode of that same tool rather than a distinct Sidekick tool. The Sidekick-spawned provider should still get the same live-editor MCP bridge as normal `hyprpilot.nvim` daemon instances.
  - Rejected: direct `claude`/`claudectx` Sidekick commands and a separate `hyprrestore` tool — they either bypass the central provider picker or duplicate one tool under a second Sidekick name.
