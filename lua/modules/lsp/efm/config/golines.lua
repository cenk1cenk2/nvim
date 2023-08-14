local METHOD = require("lvim.lsp.efm").METHOD
local formatter = require("efmls-configs.formatters.golines")

return {
  vim.tbl_deep_extend("force", formatter, {
    name = "golines",
    method = METHOD.FORMATTER,
    formatCommand = ("%s %s"):format(formatter.formatCommand, table.concat({ "-m", "180", "-t", "2" }, " ")),
  }),
}
