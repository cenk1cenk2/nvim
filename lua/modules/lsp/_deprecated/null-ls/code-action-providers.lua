local M = {}

function M.setup()
  local service = require("lvim.lsp.null-ls")
  local methods = require("null-ls").methods

  service.register(methods.CODE_ACTION, {
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
    },
  })
end

return M