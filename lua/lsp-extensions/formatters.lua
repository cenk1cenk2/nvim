local formatters = require "lvim.lsp.null-ls.formatters"

local M = {}

function M.setup()
  formatters.setup {
    {
      exe = "prettierd",
      managed = true,
      filetypes = { "javascript", "typescript" },
    },
    {
      exe = "eslint_d",
      managed = true,
      filetypes = { "javascript", "typescript" },
    },
  }
end

return M
