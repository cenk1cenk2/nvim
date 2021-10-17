local M = {}

local modules = { "modules.telescope-rg-interactive" }

function M.config(config)
  for _, module_path in ipairs(modules) do
    local module = require(module_path)
    module.setup(config)
  end
end

return M
