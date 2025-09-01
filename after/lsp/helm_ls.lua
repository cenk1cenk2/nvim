-- https://github.com/someone-stole-my-name/schema-companion.nvim/issues/12#issuecomment-1367850121
---@type vim.lsp.ClientConfig
return {
  override = function(config)
    return require("schema-companion").setup_client(config, require("schema-companion.adapters").helmls_adapter())
  end,
  settings = {
    flags = {
      debounce_text_changes = 50,
    },
    ["helm-ls"] = {
      yamlls = {
        enabled = true,
        diagnosticsLimit = 50,
        showDiagnosticsDirectly = false,
        path = "yaml-language-server",
        config = {
          validate = true,
          format = { enable = true },
          completion = true,
          hover = true,
          schemaDownload = { enable = true },
          schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
          -- any other config: https://github.com/redhat-developer/yaml-language-server#language-server-settings
        },
      },
    },
  },
}
