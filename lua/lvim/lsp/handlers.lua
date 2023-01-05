local M = {}

function M.setup()
  vim.diagnostic.config({
    virtual_text = lvim.lsp.diagnostics.virtual_text,
    signs = lvim.lsp.diagnostics.signs,
    underline = lvim.lsp.diagnostics.underline,
    update_in_insert = lvim.lsp.diagnostics.update_in_insert,
    severity_sort = lvim.lsp.diagnostics.severity_sort,
    float = lvim.lsp.diagnostics.float,
  })

  -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, lvim.lsp.float)
  -- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, lvim.lsp.float)
end

return M
