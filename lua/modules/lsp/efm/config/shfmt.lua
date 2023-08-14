local METHOD = require("lvim.lsp.efm").METHOD
local formatter = require("efmls-configs.formatters.shfmt")

return {
  vim.tbl_deep_extend("force", formatter, {
    name = "shfmt",
    method = METHOD.FORMATTER,
  }),
}
