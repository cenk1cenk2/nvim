local M = {}

function M.setup()
  vim.diagnostic.config(nvim.lsp.diagnostics)

  -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, nvim.lsp.float)
  -- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, nvim.lsp.float)
end

return M
