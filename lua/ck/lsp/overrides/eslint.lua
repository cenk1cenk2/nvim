return {
  on_attach = function(client, bufnr)
    require("ck.lsp").common_on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true
  end,
  settings = {
    eslint = {
      autoFixOnSave = true,
      codeActionsOnSave = {
        mode = "all",
        rules = { "!debugger", "!no-only-tests/*" },
      },
      lintTask = {
        enable = true,
      },
    },
  },
}
