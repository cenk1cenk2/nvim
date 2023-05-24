local M = {}

function M.setup()
  local service = require("lvim.lsp.null-ls")
  local methods = require("null-ls").methods

  service.register(methods.DIAGNOSTICS, {
    {
      name = "eslint_d",
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    },

    {
      name = "markdownlint",
      filetypes = { "markdown" },
      extra_args = { "-s", "-c", vim.fn.expand("~/.config/nvim/utils/linter-config/.markdownlintrc.json") },
    },

    {
      name = "hadolint",
      filetypes = { "dockerfile" },
    },

    {
      name = "flake8",
      filetypes = { "python" },
      extra_args = { "--max-line-length", "179" },
    },

    -- {
    --   name = "djlint",
    --   filetypes = { "jinja" },
    --   extra_args = { "--profile", "jinja" },
    -- },

    {
      name = "shellcheck",
      filetypes = { "sh", "bash", "zsh" },
    },

    {
      name = "cspell",
      config = {
        find_json = function(cwd)
          local file = vim.fn.expand(cwd .. "/cspell.json")
          if require("lvim.utils").is_file(file) then
            return file
          end

          return vim.fn.expand("~/.config/nvim/utils/linter-config/.cspell.json")
        end,
      },
      filetypes = { "markdown", "text", "gitcommit", "" },
      diagnostics_postprocess = function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity.HINT
      end,
    },
  })
end

return M
