---@module "lspconfig"
---@type lspconfig.options.eslint
return {
  on_attach = function(client, bufnr)
    require("ck.lsp.handlers").on_attach(client, bufnr)
    require("ck.lsp.handlers").overwrite_capabilities_with_formatting(client, bufnr)
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
