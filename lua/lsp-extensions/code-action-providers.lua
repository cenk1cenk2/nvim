local code_action_providers = require "lvim.lsp.null-ls.code_actions"

local M = {}

function M.setup()
  code_action_providers.setup {
    {
      exe = "eslint_d",
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    },

    -- {
    --   exe = "proselint",
    --   filetypes = { "markdown", "tex" },
    -- },
  }
end

return M
