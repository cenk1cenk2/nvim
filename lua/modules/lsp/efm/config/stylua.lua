local METHOD = require("lvim.lsp.efm").METHOD
local formatter = require("efmls-configs.formatters.stylua")

return {
  vim.tbl_deep_extend("force", formatter, {
    name = "stylua",
    method = METHOD.FORMATTER,
  }),
}
