local M = {}

local modules = {
  "modules.augroups",
  "modules.telescope",
  "modules.fugitive-compare-branch",
  "modules.lightbulb",
}

function M.config(config)
  for _, module_path in ipairs(modules) do
    local module = require(module_path)
    module.setup(config)
  end
end

return M
