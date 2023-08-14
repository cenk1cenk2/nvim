local M = {}

local modules = {
  "linters",
  "code-action-providers",
}

function M.setup()
  for _, module in ipairs(modules) do
    require("modules.lsp.null-ls." .. module).setup()
  end
end

return M
