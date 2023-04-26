local M = {}

local lsp_stuff = {
  "wrapper",
}

function M.setup()
  for _, lsp_item in ipairs(lsp_stuff) do
    require("modules.lsp." .. lsp_item).setup()
  end
end

return M
