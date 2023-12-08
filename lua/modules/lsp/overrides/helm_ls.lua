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
            kubernetes = "**",
          },
          completion = true,
          hover = true,
          -- any other config: https://github.com/redhat-developer/yaml-language-server#language-server-settings
        },
      },
    },
  },
}
