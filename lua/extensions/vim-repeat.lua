-- https://github.com/tpope/vim-repeat
local M = {}

local extension_name = "vim_repeat"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "tpope/vim-repeat",
        lazy = false,
      }
    end,
  })
end

return M
