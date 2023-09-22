local linter = require("efmls-configs.linters.shellcheck")
local METHOD = require("lvim.lsp.efm").METHOD

return {
  vim.tbl_deep_extend("force", linter, { name = "shellcheck", method = METHOD.LINTER }),
}
