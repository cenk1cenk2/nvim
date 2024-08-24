--
local M = {}

M.name = "lsp"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
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
            require("ck.lsp").setup()
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
