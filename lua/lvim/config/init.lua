local utils = require("lvim.utils")
local Log = require("lvim.core.log")

local M = {}
local user_config_dir = get_config_dir()
local user_config_file = join_paths(user_config_dir, "config.lua")

---Get the full path to the user configuration file
---@return string
function M:get_user_config_path()
  return user_config_file
end

--- Initialize lvim default configuration and variables
function M:init()
  lvim = vim.deepcopy(require("lvim.config.defaults"))

  require("lvim.config.settings").load_defaults()

  require("lvim.keymappings").load_defaults()

  require("lvim.core.autocmds").load_defaults()

  lvim.lsp = vim.deepcopy(require("lvim.lsp.config"))
end

-- local function handle_deprecated_settings()
--   local function deprecation_notice(setting, new_setting)
--     local in_headless = #vim.api.nvim_list_uis() == 0
--     if in_headless then
--       return
--     end
--
--     local msg = string.format("Deprecation notice: [%s] setting is no longer supported. %s", setting, new_setting or "")
--     vim.schedule(function()
--       vim.notify_once(msg, vim.log.levels.WARN)
--     end)
--   end
-- end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:load(config_path)
  Log:debug("Loading configuration...")
  local autocmds = require("lvim.core.autocmds")

  config_path = config_path or self:get_user_config_path()
  local ok, err = pcall(dofile, config_path)
  if not ok then
    if utils.is_file(user_config_file) then
      Log:warn(("Invalid configuration: %s"):format(err))
    else
      vim.notify_once(string.format("Unable to find configuration file [%s]", config_path), vim.log.levels.WARN)
    end
  end

  Log:debug(("Loaded user configuration at: %s"):format(config_path))

  require("extensions").config(self)

  require("modules").config(self)

  autocmds.define_autocmds(lvim.autocommands)

  vim.g.mapleader = (lvim.leader == "space" and " ") or lvim.leader

  require("lvim.keymappings").load(lvim.keys)

  if lvim.ui.transparent_window then
    autocmds.enable_transparent_mode()
  end
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
