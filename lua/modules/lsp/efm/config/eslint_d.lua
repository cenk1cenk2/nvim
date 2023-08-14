local formatter = require("efmls-configs.formatters.eslint_d")
local linter = require("efmls-configs.linters.eslint_d")
local METHOD = require("lvim.lsp.efm").METHOD

return {
  vim.tbl_deep_extend("force", formatter, { name = "eslint_d", method = METHOD.FORMATTER }),
  vim.tbl_deep_extend("force", linter, { name = "eslint_d", method = METHOD.LINTER }),
}
