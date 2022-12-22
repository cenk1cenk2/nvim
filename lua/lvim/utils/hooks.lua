local M = {}

local Log = require("lvim.core.log")
local in_headless = #vim.api.nvim_list_uis() == 0
local plugin_loader = require("lvim.plugins")

function M.run_pre_update()
  Log:debug("Starting pre-update hook")
end

function M.run_pre_reload()
  Log:debug("Starting pre-reload hook")
end

function M.run_post_reload()
  Log:debug("Starting post-reload hook")
  M._reload_triggered = true
end

function M.on_plugin_manager_complete()
  Log:debug("Plugin manager operation complete.")

  vim.api.nvim_exec_autocmds("User", { pattern = "PluginManagerComplete" })

  vim.g.colors_name = lvim.colorscheme
  pcall(vim.cmd, "colorscheme " .. lvim.colorscheme)

  if M._reload_triggered then
    Log:debug("Reloaded configuration")
    M._reload_triggered = nil
  end
end

function M.run_post_update()
  Log:debug("Starting post-update hook")

  Log:debug("Syncing core plugins")
  plugin_loader.sync_core_plugins()

  if not in_headless then
    vim.notify("Update complete", vim.log.levels.INFO)
  end
end

return M
