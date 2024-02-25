-- https://github.com/someone-stole-my-name/yaml-companion.nvim/issues/12#issuecomment-1367850121
return {
  settings = {
    ["helm-ls"] = {
      logLevel = "debug",
      yamlls = {
        enabled = true,
        diagnosticsLimit = 50,
        showDiagnosticsDirectly = false,
        path = "yaml-language-server",
        config = {
          schemas = {
            -- ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.27.11-standalone-strict/all.json"] = { "**.yaml", "**.yml" },
            kubernetes = { "**.yaml", "**.yml" },
          },
          schemaStore = { enable = false, url = "https://www.schemastore.org/api/json/catalog.json" },
          completion = true,
          hover = true,
          -- any other config: https://github.com/redhat-developer/yaml-language-server#language-server-settings
        },
      },
    },
  },
}
