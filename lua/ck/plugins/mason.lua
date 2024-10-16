-- https://github.com/williamboman/mason.nvim
-- https://github.com/williamboman/mason-lspconfig.nvim
-- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
local M = {}

M.name = "williamboman/mason.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
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
      ---@type MasonSettings
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
    autocmds = function()
      return {
        require("ck.modules.autocmds").on_lspattach(function(bufnr)
          return {
            wk = function(_, categories, fn)
              ---@type WKMappings
              return {
                {
                  fn.wk_keystroke({ categories.LSP, "I" }),
                  function()
                    vim.cmd([[Mason]])
                  end,
                  desc = "lsp installer [mason]",
                  buffer = bufnr,
                },
              }
            end,
          }
        end),
      }
    end,
  })
end

return M
