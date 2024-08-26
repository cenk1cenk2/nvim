-- https://github.com/neovim/nvim-lspconfig
local M = {}

M.name = "neovim/nvim-lspconfig"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "neovim/nvim-lspconfig",
        event = "BufReadPre",
        init = false,
        config = function()
          require("ck.lsp").setup()
        end,
      }
    end,
  })
end

return M
