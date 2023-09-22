local M = {}

function M.setup()
  local service = require("lvim.lsp.null-ls")
  local methods = require("null-ls").methods

  service.register(methods.DIAGNOSTICS, {
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
      method = methods.DIAGNOSTICS_ON_SAVE,
      filetypes = { "markdown", "text", "gitcommit", "" },
      diagnostics_postprocess = function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity.HINT
      end,
    },
  })
end

return M
