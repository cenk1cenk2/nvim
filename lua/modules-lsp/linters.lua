local linters = require "lvim.lsp.null-ls.linters"

local M = {}

function M.setup()
  linters.setup {
    {
      name = "eslint_d",
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    },

    {
      name = "misspell",
    },

    {
      name = "markdownlint",
      filetypes = { "markdown" },
      extra_args = { "-s", "-c", vim.fn.expand "~/.config/nvim/utils/linter-config/.markdownlintrc.json" },
    },

    {
      name = "hadolint",
      filetypes = { "dockerfile" },
    },

    {
      name = "flake8",
      filetypes = { "python" },
    },

    -- {
    --   name = "codespell",
    -- },

    -- {
    --   name = "cspell",
    --   args = { "-c", vim.fn.expand "~/.config/nvim/utils/linter-config/.cspell.json" },
    -- },
    -- {
    --   name = "ansiblelint",
    --   filetypes = { "yaml.ansible" },
    -- },

    -- {
    --   name = "djlint",
    --   filetypes = { "jinja" },
    --   extra_args = { "--profile", "jinja" },
    -- },

    {
      name = "shellcheck",
      filetypes = { "sh", "bash", "zsh" },
    },

    -- {
    --   name = "protolint",
    --   filetypes = { "proto" },
    -- },

    -- {
    --   name = "mypy",
    --   managed = true,
    --   filetypes = { "python" },
    -- },

    -- {
    --   name = "proselint",
    --   managed = true,
    --   filetypes = { "markdown", "tex" },
    -- },
  }
end

return M
