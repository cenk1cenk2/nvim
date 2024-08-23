local options = {
  on_attach = function(client, bufnr)
    require("core.lsp").common_on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
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

if OS_UNAME == "darwin" then
  table.insert(options.settings.Lua.workspace.library, vim.fn.expand("~/.hammerspoon/Spoons/EmmyLua.spoon/annotations"))
end

return options
