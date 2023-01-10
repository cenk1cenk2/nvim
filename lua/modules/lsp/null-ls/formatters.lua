local M = {}

function M.setup()
  local formatters = require("lvim.lsp.null-ls.formatters")

  formatters.setup({
    {
      name = "prettierd",
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
        PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/utils/linter-config/.prettierrc.json"),
      },
    },

    {
      name = "eslint_d",
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    },

    {
      name = "rustywind",
      filetypes = { "javascriptreact", "typescriptreact", "vue", "svelte", "html" },
    },

    { name = "stylua", filetypes = { "lua" } },

    {
      name = "black",
      filetypes = { "python" },
    },
    {
      name = "isort",
      filetypes = { "python" },
    },

    -- {
    --   name = "rustfmt",
    --   filetypes = { "rust" },
    -- },

    {
      name = "goimports",
      filetypes = { "go" },
    },
    -- {
    --   name = "gofmt",
    --   filetypes = { "go" },
    -- },
    {
      name = "golines",
      extra_args = { "-m", "180", "-t", "2" },
      filetypes = { "go" },
    },

    {
      name = "shfmt",
      filetypes = { "sh", "bash", "zsh" },
    },

    -- {
    --   name = "shellharden",
    -- },

    {
      name = "beautysh",
      extra_args = { "--indent-size", "2", "-t" },
    },

    -- {
    --   name = "djlint",
    --   filetypes = { "jinja" },
    --   extra_args = { "--profile", "jinja" },
    -- },
  })
end

return M
