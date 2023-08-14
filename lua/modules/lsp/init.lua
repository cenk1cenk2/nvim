local M = {}

local modules = {
  "wrapper",
}

function M.setup()
  for _, module in ipairs(modules) do
    require("modules.lsp." .. module).setup()
  end
end

return M
