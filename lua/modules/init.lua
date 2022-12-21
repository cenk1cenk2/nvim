local M = {}

local modules = {
  "nvim",
  "commands",
  "lsp",
  "augroups",
  "filetype",
  "executables",
  "telescope",
  "unimpaired",
  "scratch",
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
