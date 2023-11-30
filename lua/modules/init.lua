local M = {}

local modules = {
  "nvim",
  "commands",
  "autocmds",
  "filetype",
  "executables",
  "quit",
  -- rest
  "lsp-setup",
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
