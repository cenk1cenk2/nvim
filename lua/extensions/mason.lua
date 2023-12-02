-- https://github.com/williamboman/mason.nvim
local M = {}

local extension_name = "mason"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "williamboman/mason.nvim",
        build = ":MasonUpdate", -- :MasonUpdate updates registry contents
        cmd = { "Mason", "MasonUpdate", "MasonUpdateAll", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
        dependencies = {
          { "williamboman/mason-lspconfig.nvim" },
          { "WhoIsSethDaniel/mason-tool-installer.nvim" },
          { "RubixDev/mason-update-all" },
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "mason",
      })
    end,
    setup = function()
      return {
        ui = {
          border = lvim.ui.border,
        },
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 10,
      }
    end,
    on_setup = function(config)
      require("mason").setup(config.setup)
      require("mason-update-all").setup()
    end,
  })
end

return M
