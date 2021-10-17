local formatters = require "lvim.lsp.null-ls.formatters"

local M = {}

function M.setup()
  formatters.setup {
    {
      exe = "prettierd",
      environment = { PRETTIERD_DEFAULT_CONFIG = "~/.config/nvim/utils/linter-config/.prettierrc.json" },
      managed = true,
      filetypes = {
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "svelte",
        "yaml",
        "json",
        "jsonc",
        "html",
        "scss",
        "css",
        "markdown",
        "graphql",
      },
    },

    {
      exe = "eslint_d",
      managed = true,
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    },

    { exe = "stylua", managed = true, filetypes = { "lua" } },

    {
      exe = "shfmt",
      managed = true,
      filetypes = { "sh", "bash", "dockerfile" },
    },

    {
      exe = "black",
      managed = true,
      filetypes = { "python" },
    },
    {
      exe = "isort",
      managed = true,
      filetypes = { "python" },
    },
    {
      exe = "flake8",
      managed = true,
      filetypes = { "python" },
    },
    {
      exe = "mypy",
      managed = true,
      filetypes = { "python" },
    },
  }
end

return M
