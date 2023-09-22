local METHOD = require("lvim.lsp.efm").METHOD
local formatter = require("efmls-configs.formatters.goimports")

return {
  vim.tbl_deep_extend("force", formatter, {
    name = "goimports",
    method = METHOD.FORMATTER,
  }),
}
