local METHOD = require("lvim.lsp.efm").METHOD

return {
  {
    name = "beautysh",
    method = METHOD.FORMATTER,
    formatCommand = "beautysh",
  },
}
