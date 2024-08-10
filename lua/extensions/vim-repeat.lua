-- https://github.com/tpope/vim-repeat
local M = {}

M.name = "tpope/vim-repeat"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "tpope/vim-repeat",
        lazy = false,
      }
    end,
  })
end

return M
