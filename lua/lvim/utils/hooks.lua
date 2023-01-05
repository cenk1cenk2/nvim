local M = {}

local Log = require("lvim.core.log")
local in_headless = #vim.api.nvim_list_uis() == 0

function M.run_pre_reload()
  Log:debug("Starting pre-reload hook")
end

function M.run_post_reload()
  Log:debug("Starting post-reload hook")
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
    vim.schedule(function()
      vim.notify("Update complete", vim.log.levels.INFO)
    end)
  end
end

function M.reset_cache()
  require("lvim.plugin-loader").reset_cache()
end

return M
