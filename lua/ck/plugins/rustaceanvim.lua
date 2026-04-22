-- https://github.com/mrcjkb/rustaceanvim
local M = {}

M.name = "mrcjkb/rustaceanvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "mrcjkb/rustaceanvim",
        version = "^9",
        ft = { "rust" },
      }
    end,
  })
end

return M
