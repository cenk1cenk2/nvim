---@type vim.lsp.ClientConfig
return {
  override = function(config)
    return require("schema-companion").setup_client(
      require("schema-companion").adapters.jsonls.setup({
        sources = {
          require("schema-companion").sources.lsp.setup(),
          require("schema-companion").sources.none.setup(),
        },
      }),
      config
    )
  end,
  on_attach = function(client, bufnr)
    require("ck.lsp.handlers").on_attach(client, bufnr)
    require("ck.lsp.handlers").overwrite_capabilities_with_no_formatting(client, bufnr)
  end,
  settings = {
    json = {
      schemas = vim.tbl_deep_extend("force", require("schemastore").json.schemas(), {
        {
          description = "TypeScript compiler configuration file",
          fileMatch = { "tsconfig.json", "tsconfig.*.json" },
          url = "https://json.schemastore.org/tsconfig.json",
        },
        {
          description = "JSON Schema.",
          fileMatch = { "*.schema.json" },
          url = "http://json-schema.org/draft-07/schema#",
        },
      }),
      schemaDownload = {
        enable = true,
      },
      validate = {
        enable = true,
      },
    },
  },
  setup = {
    commands = {
      Format = {
        function()
          vim.lsp.buf.format({ range = { start = { 0, 0 }, ["end"] = { vim.fn.line("$"), 0 } } })
        end,
      },
    },
  },
}
