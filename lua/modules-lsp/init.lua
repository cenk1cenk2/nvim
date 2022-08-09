local M = {}

local lsp_stuff = {
  "modules-lsp.mason",
  "modules-lsp.formatters",
  "modules-lsp.linters",
  "modules-lsp.code-action-providers",
  "modules-lsp.wrapper",
}

function M.setup()
  for _, lsp_item in ipairs(lsp_stuff) do
    require(lsp_item).setup()
  end
end

return M
