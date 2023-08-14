local METHOD = require("lvim.lsp.efm").METHOD
local formatter = require("efmls-configs.formatters.prettier_d")

return {
  vim.tbl_deep_extend("force", formatter, {
    name = "prettierd",
    method = METHOD.FORMATTER,
    env = {
      "PRETTIERD_DEFAULT_CONFIG=" .. vim.fn.expand("~/.config/nvim/utils/linter-config/.prettierrc.json"),
    },
  }),
}
