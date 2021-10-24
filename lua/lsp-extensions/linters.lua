local linters = require "lvim.lsp.null-ls.linters"

local M = {}

function M.setup()
  linters.setup {
    {
      exe = "eslint_d",
      managed = true,
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    },

    {
      exe = "misspell",
      managed = true,
    },

    {
      exe = "markdownlint",
      managed = true,
      filetypes = { "markdown" },
    },

    {
      exe = "hadolint",
      managed = true,
      filetypes = { "dockerfile" },
    },

    {
      exe = "flake8",
      managed = true,
      filetypes = { "python" },
    },
    -- {
    --   exe = "mypy",
    --   managed = true,
    --   filetypes = { "python" },
    -- },
  }
end

return M
