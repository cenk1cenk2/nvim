local schemas = {
  {
    description = "TypeScript compiler configuration file",
    fileMatch = { "tsconfig.json", "tsconfig.*.json" },
    url = "https://json.schemastore.org/tsconfig.json",
  },
}
print(require("schemastore").json.schemas())
local opts = {
  settings = {
    json = {
      schemas = vim.tbl_deep_extend(
        "force",
        schemas,
        require("schemastore").json.schemas(),
        require("nlspsettings.jsonls").get_default_schemas()
      ),
    },
  },
  setup = {
    commands = {
      Format = {
        function()
          vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 })
        end,
      },
    },
  },
}

return opts
