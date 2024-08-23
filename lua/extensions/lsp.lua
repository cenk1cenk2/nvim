--
local M = {}

M.name = "lsp"

function M.config()
  require("setup").define_extension(M.name, true, {
    opts = {
      multiple_packages = true,
    },
    plugin = function()
      return {
        {
          "folke/neoconf.nvim",
          init = false,
          config = false,
        },
        {
          "neovim/nvim-lspconfig",
          event = "BufReadPre",
          init = false,
          config = function()
            require("core.lsp").setup()
          end,
        },
        {
          "b0o/schemastore.nvim",
          init = false,
          config = false,
        },
      }
    end,
  })
end

return M
