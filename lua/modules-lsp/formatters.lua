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
      exe = "shfmt",
      filetypes = { "sh", "bash" },
    },

    {
      exe = "black",
      filetypes = { "python" },
    },
    {
      exe = "isort",
      filetypes = { "python" },
    },

    {
      exe = "rustfmt",
      filetypes = { "rust" },
    },

    {
      exe = "goimports",
      filetypes = { "go" },
    },
    {
      exe = "gofmt",
      filetypes = { "go" },
    },
    {
      exe = "golines",
      filetypes = { "go" },
    },

    {
      exe = "djlint",
      filetypes = { "jinja", "django", "jinja.html", "htmldjango" },
    },
  }
end

return M