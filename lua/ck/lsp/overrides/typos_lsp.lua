return {
  handlers = {
    ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
      result.diagnostics = vim.tbl_map(function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity.HINT

        return diagnostic
      end, result.diagnostics)

      return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
    end,
  },
  filetypes = {
    "markdown",
    "plaintext",
    "text",
    "gitcommit",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "svelte",
    "go",
  },
}
