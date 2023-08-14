local linter = require("efmls-configs.linters.hadolint")
local METHOD = require("lvim.lsp.efm").METHOD

return {
  vim.tbl_deep_extend("force", linter, { name = "hadolint", method = METHOD.LINTER }),
}
