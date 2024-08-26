-- https://git.sr.ht/~whynothugo/lsp_lines.nvim
local M = {}

M.name = "~whynothugo/lsp_lines.nvim"

M.loaded = false

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
      }
    end,
    on_done = function()
      vim.diagnostic.config({ virtual_lines = false, virtual_text = nvim.lsp.diagnostics.virtual_text })
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
    require("lsp_lines").setup()

    vim.diagnostic.config({ virtual_lines = true, virtual_text = false })

    M.loaded = true

    return true
  end

  local value = vim.diagnostic.config()

  if not value.virtual_lines then
    vim.diagnostic.config({ virtual_lines = true, virtual_text = false })
  else
    vim.diagnostic.config({ virtual_lines = false, virtual_text = nvim.lsp.diagnostics.virtual_text })
  end

  return not value
end

return M
