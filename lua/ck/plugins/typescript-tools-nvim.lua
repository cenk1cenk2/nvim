-- https://github.com/pmizio/typescript-tools.nvim
local M = {}

M.name = "pmizio/typescript-tools.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "pmizio/typescript-tools.nvim",
      }
    end,
  })
end

return M
