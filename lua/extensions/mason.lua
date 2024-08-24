-- https://github.com/williamboman/mason.nvim
local M = {}

M.name = "williamboman/mason.nvim"

function M.config()
  require("setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "williamboman/mason.nvim",
        build = ":MasonUpdate", -- :MasonUpdate updates registry contents
        cmd = { "Mason", "MasonUpdate", "MasonUpdateAll", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
        dependencies = {
          { "williamboman/mason-lspconfig.nvim" },
          { "WhoIsSethDaniel/mason-tool-installer.nvim" },
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
          border = nvim.ui.border,
        },
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 10,
      }
    end,
    on_setup = function(c)
      require("mason").setup(c)
    end,
  })
end

return M
