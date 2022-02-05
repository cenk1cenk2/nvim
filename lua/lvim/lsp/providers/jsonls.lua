local schemas = {
  {
    description = "TypeScript compiler configuration file",
    fileMatch = { "tsconfig.json", "tsconfig.*.json" },
    url = "https://json.schemastore.org/tsconfig.json",
  },
  { description = "Lerna config", fileMatch = { "lerna.json" }, url = "https://json.schemastore.org/lerna.json" },
  {
    description = "Babel configuration",
    fileMatch = { ".babelrc.json", ".babelrc", "babel.config.json" },
    url = "https://json.schemastore.org/babelrc.json",
  },
  {
    description = "ESLint config",
    fileMatch = { ".eslintrc.json", ".eslintrc" },
    url = "https://json.schemastore.org/eslintrc.json",
  },
  {
    description = "Prettier config",
    fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
    url = "https://json.schemastore.org/prettierrc",
  },
  { description = "Vercel Now config", fileMatch = { "now.json" }, url = "https://json.schemastore.org/now" },
  {
    description = "Stylelint config",
    fileMatch = { ".stylelintrc", ".stylelintrc.json", "stylelint.config.json" },
    url = "https://json.schemastore.org/stylelintrc",
  },
  {
    description = "Json schema for properties json file for a GitHub Workflow template",
    fileMatch = { ".github/workflow-templates/**.properties.json" },
    url = "https://json.schemastore.org/github-workflow-template-properties.json",
  },
  {
    description = "golangci-lint configuration file",
    fileMatch = { ".golangci.toml", ".golangci.json" },
    url = "https://json.schemastore.org/golangci-lint.json",
  },
  {
    description = "JSON schema for the JSON Feed format",
    fileMatch = { "feed.json" },
    url = "https://json.schemastore.org/feed.json",
    versions = {
      ["1"] = "https://json.schemastore.org/feed-1.json",
      ["1.1"] = "https://json.schemastore.org/feed.json",
    },
  },
  {
    description = "Packer template JSON configuration",
    fileMatch = { "packer.json" },
    url = "https://json.schemastore.org/packer.json",
  },
  {
    description = "NPM configuration file",
    fileMatch = { "package.json" },
    url = "https://json.schemastore.org/package.json",
  },
  {
    description = "JSON schema for Visual Studio component configuration files",
    fileMatch = { "*.vsconfig" },
    url = "https://json.schemastore.org/vsconfig.json",
  },
}

return {
local full_schemas = vim.tbl_deep_extend(
  "force",
  require("schemastore").json.schemas(),
  require("nlspsettings.jsonls").get_default_schemas()
)
local opts = {
  settings = {
    json = {
      schemas = full_schemas,
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
