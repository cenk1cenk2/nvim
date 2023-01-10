local M = {}

function M.setup()
  local code_action_providers = require("lvim.lsp.null-ls.code_actions")

  code_action_providers.setup({
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
