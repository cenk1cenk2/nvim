---@type vim.lsp.ClientConfig
return {
  settings = {
    settings = {
      evenBetterToml = {
        schema = {
          catalogs = { "https://taplo.tamasfe.dev/schema_index.json" },
        },
      },
    },
  },
}
