local M = {}

local installers = {
  "modules-lsp.installers.prettier-d",
  "modules-lsp.installers.eslint-d",
  "modules-lsp.installers.stylua",
  "modules-lsp.installers.misspell",
  "modules-lsp.installers.markdownlint",
  "modules-lsp.installers.markdown-toc",
  "modules-lsp.installers.shfmt",
  "modules-lsp.installers.black",
  "modules-lsp.installers.isort",
  "modules-lsp.installers.flake8",
  "modules-lsp.installers.mypy",
  "modules-lsp.installers.rustfmt",
  "modules-lsp.installers.golines",
  "modules-lsp.installers.goimports",
  "modules-lsp.installers.rustywind",
  "modules-lsp.installers.hadolint",
  "modules-lsp.installers.proselint",
  "modules-lsp.installers.djlint",
}

function M.setup()
  for _, lsp_installer_path in ipairs(installers) do
    require(lsp_installer_path).setup()
  end
end

return M
