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
      extra_args = { "-s", "-c", vim.fn.expand "~/.config/nvim/utils/linter-config/.markdownlintrc.json" },
    },

    {
      exe = "hadolint",
      filetypes = { "dockerfile" },
    },

    {
      exe = "flake8",
      filetypes = { "python" },
    },

    {
      exe = "ansiblelint",
      filetypes = { "yaml.ansible" },
    },

    {
      exe = "djlint",
      filetypes = { "jinja" },
      extra_args = { "--profile", "jinja" },
    },

    {
      exe = "shellcheck",
      filetypes = { "sh", "bash", "zsh" },
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
