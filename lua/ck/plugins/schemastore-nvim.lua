-- https://github.com/b0o/schemastore.nvim
local M = {}

M.name = "b0o/schemastore.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "b0o/schemastore.nvim",
        init = false,
        config = false,
      }
    end,
  })
end

return M
