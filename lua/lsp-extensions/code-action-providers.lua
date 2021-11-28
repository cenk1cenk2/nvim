local code_action_providers = require "lvim.lsp.null-ls.code-action-providers"

local M = {}

function M.setup()
  code_action_providers.setup {
    {
      exe = "eslint_d",
      managed = true,
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    },

    {
      exe = "proselint",
      managed = true,
      filetypes = { "markdown", "tex" },
    },
  }
end

return M
