local M = {}

local installers = { "lsp.installers.eslint-d", "lsp.installers.stylua" }

function M.setup()
  for _, lsp_installer_path in ipairs(installers) do
    require(lsp_installer_path)
  end
end

return M
