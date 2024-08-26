-- https://github.com/MunifTanjim/nui.nvim
local M = {}

M.name = "MunifTanjim/nui.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "MunifTanjim/nui.nvim",
        event = "VeryLazy",
        init = false,
        config = false,
      }
    end,
  })
end

return M
