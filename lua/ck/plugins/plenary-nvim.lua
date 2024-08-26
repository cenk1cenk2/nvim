-- https://github.com/nvim-lua/plenary.nvim
local M = {}

M.name = "nvim-lua/plenary.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "nvim-lua/plenary.nvim",
        init = false,
        config = false,
      }
    end,
  })
end

return M
