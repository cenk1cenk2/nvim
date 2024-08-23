-- https://github.com/antosha417/nvim-lsp-file-operations
local M = {}

M.name = "antosha417/nvim-lsp-file-operations"

function M.config()
  require("utils.setup").define_extension(M.name, false, {
    plugin = function()
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
