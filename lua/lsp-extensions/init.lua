local M = {}

local lsp_stuff = {
  "lsp-extensions.installers",
  "lsp-extensions.formatters",
  "lsp-extensions.linters",
  "lsp-extensions.code-action-providers",
  "lsp-extensions.wrapper",
  "lsp-extensions.lsp-installer-wrapper",
}

function M.setup()
  for _, lsp_item in ipairs(lsp_stuff) do
    require(lsp_item).setup()
  end
end

return M
