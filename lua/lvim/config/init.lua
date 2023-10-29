local utils = require("lvim.utils")
local Log = require("lvim.core.log")

local M = {}

--- Initialize lvim default configuration and variables
function M:init()
  lvim = vim.deepcopy(require("lvim.config.defaults"))

  require("lvim.config.settings").load_defaults()

  require("lvim.keymappings").load_defaults()

  lvim.lsp = vim.deepcopy(require("lvim.config.lsp"))
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:load()
  Log:debug("Loading configuration...")

  require("config")

  require("extensions").config(self)

  require("modules").config(self)

  local autocmds = require("lvim.core.autocmds")
  autocmds.define_autocmds(lvim.autocommands)

  if lvim.ui.transparent_window then
    autocmds.enable_transparent_mode()
  end

  vim.g.mapleader = (lvim.leader == "space" and " ") or lvim.leader

  require("lvim.keymappings").load(lvim.keys)
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:reload()
  vim.schedule(function()
    require_clean("lvim.utils.hooks").run_pre_reload()

    M:load()

    require("lvim.core.autocmds").configure_format_on_save()

    local plugin_loader = require("lvim.plugin-loader")

    plugin_loader.reload({ lvim.plugins })

    require_clean("lvim.utils.hooks").run_post_reload()
  end)
end

return M
