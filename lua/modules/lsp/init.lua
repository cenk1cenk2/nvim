local M = {}

local lsp_stuff = {
  "mason",
  "formatters",
  "linters",
  "code-action-providers",
  "wrapper",
}

function M.setup()
  for _, lsp_item in ipairs(lsp_stuff) do
    require("modules.lsp." .. lsp_item).setup()
  end
end

return M
