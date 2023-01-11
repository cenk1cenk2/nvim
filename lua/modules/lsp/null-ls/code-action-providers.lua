local M = {}

function M.setup()
  local service = require("lvim.lsp.null-ls")
  local methods = require("null-ls").methods

  service.register(methods.CODE_ACTION, {
    {
      name = "eslint_d",
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    },

    {
      name = "shellcheck",
      filetypes = { "sh", "bash", "zsh" },
    },

    {
      name = "cspell",
      extra_args = { "-c", vim.fn.expand("~/.config/nvim/utils/linter-config/.cspell.json") },
    },
    -- {
    --   name = "refactoring",
    -- },

    -- {
    --   exe = "proselint",
    --   filetypes = { "markdown", "tex" },
    -- },
  })
end

return M
