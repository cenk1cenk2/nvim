-- https://github.com/antosha417/nvim-lsp-file-operations
local M = {}

M.name = "antosha417/nvim-lsp-file-operations"

function M.config()
  require("ck.setup").define_plugin(M.name, false, {
    plugin = function()
      ---@type Plugin
      return {
        "antosha417/nvim-lsp-file-operations",
        requires = {
          "nvim-lua/plenary.nvim",
          "nvim-neo-tree/neo-tree.nvim",
        },
        event = "LspAttach",
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(c)
      require("lsp-file-operations").setup(c)
    end,
  })
end

return M
