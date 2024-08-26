---@module "lspconfig"
---@type lspconfig.options.taplo
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
