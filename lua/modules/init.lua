local M = {}

local modules = {
  "nvim",
  "lsp",
  "lsp-commands",
  "augroups",
  "telescope",
  "fugitive-compare-branch",
}

function M.config(config)
  for _, module_path in ipairs(modules) do
    local module = require("modules." .. module_path)
    module.setup(config)
  end
end

return M
