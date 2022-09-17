local schemas = {
  {
    description = "TypeScript compiler configuration file",
    fileMatch = { "tsconfig.json", "tsconfig.*.json" },
    url = "https://json.schemastore.org/tsconfig.json",
  },
}

local opts = {
  settings = {
    json = {
      schemas = vim.tbl_deep_extend("force", require("schemastore").json.schemas(), schemas),
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
          vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 })
        end,
      },
    },
  },
}

return opts
