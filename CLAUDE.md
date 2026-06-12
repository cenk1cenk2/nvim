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
  - Chose: configure `folke/sidekick.nvim` with one Sidekick tool, `hyprpilot`; `<Leader>ctt` launches `hyprpilot spawn` with a dynamic `--with-config @<json>` profile patch that injects the current Neovim instance's `hyprpilot-nvim` MCP server via `vim.v.servername`.
  - Sidekick should run `hyprpilot spawn` directly in its Neovim terminal, without `cli.mux` and without an `is_proc` regex that matches provider CLIs. `hyprpilot spawn` `exec`s the selected provider into the same pty, so Sidekick keeps one terminal/session and context sends stay simple.
  - Keep the Sidekick `hyprpilot spawn` command shape inline in the tool config and pass simple Sidekick target opts directly in mappings. Do not add one-use constants/helpers for the `hyprpilot-nvim` MCP server name, package name, config patch, or static session opts.
  - Keep the right-side split at a stable 40% of the editor via `cli.win.split.width = 0.4`. Do not recompute from the current window on every terminal creation; that creeps smaller when focus starts from an already-split window.
  - `windows.nvim` must ignore `sidekick_terminal`; otherwise its WinEnter autowidth logic fights Sidekick's fixed terminal split and the width creeps while moving with `<C-h>` / `<C-l>`.
  - Why: Hyprpilot owns provider/profile selection for Claude, Codex, and opencode. Avoid Sidekick tmux/process discovery here; it can create duplicate/mirrored panes when the provider process replaces `hyprpilot`.
  - Rejected: direct `claude`/`claudectx` Sidekick commands, Sidekick `cli.mux` for this tool, provider-process `is_proc` matching, restore-specific Sidekick mappings, and a separate `hyprrestore` tool.
