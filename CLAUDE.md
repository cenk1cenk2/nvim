## Overview

This repository is a personal Neovim configuration forked from LunarVim. Startup flows through `init.lua`, then `ck.config` and `ck.loader`; most behavior is organized as Lua modules under `lua/ck/`. Plugin integrations live in `lua/ck/plugins/` and are registered through the repository's `ck.setup` wrapper.

## Stack & Structure

- **Language:** Lua for Neovim configuration, plus shell utilities under `utils/`.
- **Build/Lint:** `Taskfile.yml` provides `task format` and `task lint`; Lua uses `stylua --config-path .stylua.toml`, and linting also runs `selene`.
- **Key directories:** `lua/ck/config/` for defaults/settings, `lua/ck/keys/` for keybinding helpers, `lua/ck/plugins/` for plugin modules, `after/` for Neovim after-files, `utils/` for scripts and agent tooling.

## Conventions

- Startup is `init.lua` → `require("ck"):init()` → `require("ck.config"):load()` → `require("ck.loader").load()`.
- Lazy.nvim specs come from `require("ck.setup").into_plugin_spec()`; plugin modules should use `define_plugin` instead of hand-editing the lazy spec.
- Plugin modules should keep `M.config()` first after `M.name`; put plugin-specific constants/helpers on `M.*` after `M.config()` so the main registration stays easy to scan.
- Register plugins with `require("ck.setup").define_plugin(M.name, enabled, { plugin = ..., setup = ..., wk = ..., on_setup = ..., keymaps = ... })` and match the surrounding module shape.
- LSP defaults live under `lua/ck/config/lsp.lua`; runtime LSP behavior is split under `lua/ck/lsp/` and plugin integrations under `lua/ck/plugins/`.
- Which-key mappings should use `fn.wk_keystroke({ categories.<GROUP>, ... })` rather than hard-coded leader strings when a category exists.
- Format Lua changes with `stylua --config-path .stylua.toml` and validate with `stylua --config-path .stylua.toml --check` before reporting completion.
