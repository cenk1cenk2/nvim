-- https://github.com/creativenull/efmls-configs-nvim
local M = {}

local extension_name = "efmls_configs_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    plugin = function()
      return {
        "creativenull/efmls-configs-nvim",
      }
    end,
  })
end

return M
