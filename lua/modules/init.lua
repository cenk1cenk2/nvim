local M = {}

local modules = {
  "nvim",
  "lsp",
  "executables",
  "augroups",
  "telescope",
  "fugitive",
}

function M.config(config)
  for _, module_path in ipairs(modules) do
    local module = require("modules." .. module_path)
    if module.setup ~= nil then
      module.setup(config)
    end
  end
end

return M
