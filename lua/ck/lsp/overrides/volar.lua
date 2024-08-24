return {
  on_attach = function(client, bufnr)
    require("ck.lsp").common_on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}
