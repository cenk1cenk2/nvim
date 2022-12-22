local M = {}

local Log = require("lvim.core.log")
local in_headless = #vim.api.nvim_list_uis() == 0
local plugin_loader = require("lvim.plugins")

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

  vim.cmd("colorscheme " .. lvim.colorscheme)
end

function M.run_pre_update()
  Log:debug("Starting pre-update hook")
end

function M.run_post_update()
  Log:debug("Starting post-update hook")

  if not in_headless then
    vim.notify("Update complete", vim.log.levels.INFO)
  end
end

return M
