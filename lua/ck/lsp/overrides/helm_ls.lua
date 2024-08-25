-- https://github.com/someone-stole-my-name/schema-companion.nvim/issues/12#issuecomment-1367850121
return {
  override = function(config)
    return require("schema-companion").setup_client(config.settings["helm-ls"].yamlls.config)
  end,
  -- override = function(config)
  --   local companion = require("schema-companion").setup(vim.tbl_extend("force", require("ck.modules.lsp.overrides.yamlls"), {
  --     -- log_level = "debug",
  --     formatting = false,
  --     lspconfig = {
  --       settings = { yaml = config.settings["helm-ls"].yamlls.config },
  --     },
  --   }))
  --
  --   config = vim.tbl_extend("force", config, {
  --     on_attach = function(client, bufnr)
  --       require("ck.lsp.handlers").common_on_attach(client, bufnr)
  --       companion.on_attach(client, bufnr)
  --       companion.handlers["yaml/schema/store/initialized"](nil, nil, { client_id = client.id })
  --     end,
  --     on_init = function(client, bufnr)
  --       require("ck.lsp.handlers").common_on_init(client, bufnr)
  --       companion.on_init(client, bufnr)
  --     end,
  --     handlers = {
  --       ["yaml/schema/store/initialized"] = companion.handlers["yaml/schema/store/initialized"],
  --       ["yaml/get/all/jsonSchemas"] = function()
  --         return {}
  --       end,
  --       ["yaml/get/jsonSchema"] = function()
  --         return {}
  --       end,
  --     },
  --   })
  --
  --   return config
  -- end,
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
