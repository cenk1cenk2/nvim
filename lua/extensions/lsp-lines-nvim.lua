-- https://git.sr.ht/~whynothugo/lsp_lines.nvim
local M = {}

local extension_name = "lsp_lines_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        config = function()
          require("utils.setup").packer_config "lsp_lines_nvim"
        end,
        disable = not config.active,
      }
    end,
    on_init = function(config)
      config.set_store("loaded", false)
    end,
    on_done = function()
      vim.diagnostic.config { virtual_lines = false, virtual_text = lvim.lsp.diagnostics.virtual_text }
    end,
    keymaps = {
      n = {
        ["gL"] = { M.toggle, { desc = "toggle lsp lines" } },
      },
    },
  })
end

function M.toggle()
  if not lvim.extensions[extension_name].store.loaded then
    local extension = require "lsp_lines"
    extension.setup()

    vim.diagnostic.config { virtual_lines = true, virtual_text = false }

    lvim.extensions[extension_name].set_store("loaded", true)

    return true
  end

  local value = vim.diagnostic.config().virtual_lines

  if not value then
    vim.diagnostic.config { virtual_lines = true, virtual_text = false }
  else
    vim.diagnostic.config { virtual_lines = false, virtual_text = lvim.lsp.diagnostics.virtual_text }
  end

  return not value
end

return M
