local METHOD = require("lvim.lsp.efm").METHOD
local formatter = require("efmls-configs.formatters.terraform_fmt")

return {
  vim.tbl_deep_extend("force", formatter, {
    name = "terraform_fmt",
    method = METHOD.FORMATTER,
  }),
}
