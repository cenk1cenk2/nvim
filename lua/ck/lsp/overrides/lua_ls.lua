---@module 'lspconfig'
---@type lspconfig.options.lua_ls
local options = {
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

if OS_UNAME == "darwin" then
  table.insert(options.settings.Lua.workspace.library, vim.fn.expand("~/.hammerspoon/Spoons/EmmyLua.spoon/annotations"))
end

return options
