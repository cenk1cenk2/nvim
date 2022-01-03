local linters = require "lvim.lsp.null-ls.linters"

local M = {}

function M.setup()
  linters.setup {
    {
      exe = "eslint_d",
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    },

    {
      exe = "misspell",
    },

    {
      exe = "markdownlint",
      filetypes = { "markdown" },
    },

    {
      exe = "hadolint",
      filetypes = { "dockerfile" },
    },

    {
      exe = "flake8",
      filetypes = { "python" },
    },
    -- {
    --   exe = "mypy",
    --   managed = true,
    --   filetypes = { "python" },
    -- },

    -- {
    --   exe = "proselint",
    --   managed = true,
    --   filetypes = { "markdown", "tex" },
    -- },
  }
end

return M
