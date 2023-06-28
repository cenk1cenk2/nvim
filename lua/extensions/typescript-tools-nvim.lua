-- https://github.com/pmizio/typescript-tools.nvim
local M = {}

local extension_name = "typescript_tools_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "pmizio/typescript-tools.nvim",
      }
    end,
  })
end

return M
