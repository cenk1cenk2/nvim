local M = {}

local installers = {
  "lsp-extensions.installers.prettier-d",
  "lsp-extensions.installers.eslint-d",
  "lsp-extensions.installers.stylua",
  "lsp-extensions.installers.misspell",
  "lsp-extensions.installers.markdownlint",
  "lsp-extensions.installers.markdown-toc",
  "lsp-extensions.installers.shfmt",
  "lsp-extensions.installers.black",
  "lsp-extensions.installers.isort",
  "lsp-extensions.installers.flake8",
  "lsp-extensions.installers.mypy",
  "lsp-extensions.installers.rustfmt",
  "lsp-extensions.installers.golines",
  "lsp-extensions.installers.goimports",
  "lsp-extensions.installers.rustywind",
  "lsp-extensions.installers.hadolint",
  "lsp-extensions.installers.proselint",
  "lsp-extensions.installers.djlint",
}

function M.setup()
  for _, lsp_installer_path in ipairs(installers) do
    require(lsp_installer_path)
  end
end

return M
