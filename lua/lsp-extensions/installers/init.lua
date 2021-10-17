local M = {}

local installers = {
  "lsp-extensions.installers.prettier-d",
  "lsp-extensions.installers.eslint-d",
  "lsp-extensions.installers.stylua",
  "lsp-extensions.installers.misspell",
  "lsp-extensions.installers.markdownlint",
}

function M.setup()
  for _, lsp_installer_path in ipairs(installers) do
    require(lsp_installer_path)
  end
end

return M
