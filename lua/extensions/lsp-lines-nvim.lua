-- https://git.sr.ht/~whynothugo/lsp_lines.nvim
local M = {}

M.name = "~whynothugo/lsp_lines.nvim"

M.loaded = false

function M.config()
  require("setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
      }
    end,
    on_done = function()
      vim.diagnostic.config({ virtual_lines = false, virtual_text = lvim.lsp.diagnostics.virtual_text })
    end,
    keymaps = function()
      return {
        {
          "gL",
          function()
            M.toggle()
          end,
          desc = "toggle lsp lines",
          mode = { "n" },
        },
      }
    end,
  })
end

function M.toggle()
  if not M.loaded then
    local extension = require("lsp_lines")
    extension.setup()

    vim.diagnostic.config({ virtual_lines = true, virtual_text = false })

    M.loaded = true

    return true
  end

  local value = vim.diagnostic.config()

  if not value.virtual_lines then
    vim.diagnostic.config({ virtual_lines = true, virtual_text = false })
  else
    vim.diagnostic.config({ virtual_lines = false, virtual_text = lvim.lsp.diagnostics.virtual_text })
  end

  return not value
end

return M
