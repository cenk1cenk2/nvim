-- https://github.com/tpope/vim-repeat
local M = {}

M.name = "tpope/vim-repeat"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "tpope/vim-repeat",
        lazy = false,
      }
    end,
  })
end

return M
