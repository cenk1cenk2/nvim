-- https://github.com/folke/neoconf.nvim
local M = {}

M.name = "folke/neoconf.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "folke/neoconf.nvim",
        init = false,
        config = false,
      }
    end,
  })
end

return M
