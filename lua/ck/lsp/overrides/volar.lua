---@module 'lspconfig'
---@type lspconfig.options.volar
return {
  on_attach = function(client, bufnr)
    require("ck.lsp.handlers").on_attach(client, bufnr)
    require("ck.lsp.handlers").overwrite_capabilities_with_no_formatting(client, bufnr)
  end,
}
