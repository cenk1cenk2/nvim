local M = {}

local lsp_stuff = {
  "formatters",
  "linters",
  "code-action-providers",
}

function M.setup()
  for _, lsp_item in ipairs(lsp_stuff) do
    require("modules.lsp.null-ls." .. lsp_item).setup()
  end
end

return M
