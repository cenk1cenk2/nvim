---@type vim.lsp.ClientConfig
return {
  on_attach = function(client, bufnr)
    require("ck.lsp.handlers").on_attach(client, bufnr)
    require("ck.lsp.handlers").overwrite_capabilities_with_no_formatting(client, bufnr)
  end,

  settings = {
    Lua = {
      telemetry = { enable = false },
      runtime = {
        version = "LuaJIT",
        special = {},
      },
      workspace = {
        maxPreload = 5000,
        preloadFileSize = 10000,
        library = {},
      },
    },
  },
}
