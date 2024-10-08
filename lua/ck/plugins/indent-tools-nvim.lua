-- https://github.com/arsham/indent-tools.nvim
local M = {}

M.name = "arsham/indent-tools.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "arsham/indent-tools.nvim",
        dependencies = {
          "arsham/arshlib.nvim",
          "nvim-treesitter/nvim-treesitter-textobjects",
        },
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(c)
      require("indent-tools").config(c)
    end,
  })
end

return M
