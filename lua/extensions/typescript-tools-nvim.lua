-- https://github.com/pmizio/typescript-tools.nvim
local M = {}

M.name = "pmizio/typescript-tools.nvim"

function M.config()
  require("setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "pmizio/typescript-tools.nvim",
      }
    end,
  })
end

return M
