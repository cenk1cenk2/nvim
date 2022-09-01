local formatters = require "lvim.lsp.null-ls.formatters"

local M = {}

function M.setup()
  formatters.setup {
    {
      exe = "prettierd",
      filetypes = {
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "svelte",
        "yaml",
        "yaml.ansible",
        "yaml.docker-compose",
        "json",
        "jsonc",
        "html",
        "scss",
        "css",
        "markdown",
        "graphql",
      },
      env = {
        PRETTIERD_DEFAULT_CONFIG = vim.fn.expand "~/.config/nvim/utils/linter-config/.prettierrc.json",
      },
    },

    {
      exe = "eslint_d",
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    },

    {
      exe = "rustywind",
      filetypes = { "javascriptreact", "typescriptreact", "vue", "svelte", "html" },
    },

    { exe = "stylua", filetypes = { "lua" } },

    {
      exe = "black",
      filetypes = { "python" },
    },
    {
      exe = "isort",
      filetypes = { "python" },
    },

    -- {
    --   exe = "rustfmt",
    --   filetypes = { "rust" },
    -- },

    {
      exe = "goimports",
      filetypes = { "go" },
    },
    -- {
    --   exe = "gofmt",
    --   filetypes = { "go" },
    -- },
    {
      exe = "golines",
      extra_args = { "-m", "180", "-t", "2" },
      filetypes = { "go" },
    },

    {
      exe = "shfmt",
      filetypes = { "sh", "bash", "zsh" },
    },

    -- {
    --   exe = "shellharden",
    -- },

    {
      exe = "beautysh",
      extra_args = { "--indent-size", "2", "-t" },
    },

    -- {
    --   exe = "djlint",
    --   filetypes = { "jinja" },
    --   extra_args = { "--profile", "jinja" },
    -- },
  }
end

return M
