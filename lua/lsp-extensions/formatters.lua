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
    },

    {
      exe = "eslint_d",
      managed = true,
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    },

    {
      exe = "rustywind",
      managed = true,
      filetypes = { "javascriptreact", "typescriptreact", "vue", "svelte", "html" },
    },

    { exe = "stylua", managed = true, filetypes = { "lua" } },

    {
      exe = "shfmt",
      managed = true,
      filetypes = { "sh", "bash" },
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
      exe = "rustfmt",
      managed = true,
      filetypes = { "rust" },
    },

    {
      exe = "goimports",
      managed = true,
      filetypes = { "go" },
    },
    {
      exe = "gofmt",
      filetypes = { "go" },
    },
    {
      exe = "golines",
      managed = true,
      filetypes = { "go" },
    },
  }
end

return M
