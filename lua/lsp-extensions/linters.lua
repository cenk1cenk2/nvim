local linters = require "lvim.lsp.null-ls.linters"

local M = {}

function M.setup()
  linters.setup { {
    exe = "eslint_d",
    managed = true,
    filetypes = { "javascript", "typescript" },
  } }
end

return M
