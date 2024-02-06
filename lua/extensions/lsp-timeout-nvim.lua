-- https://github.com/hinell/lsp-timeout.nvim
local M = {}

local extension_name = "hinell/lsp-timeout.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "hinell/lsp-timeout.nvim",
        event = "LspAttach",
      }
    end,
    legacy_setup = {
      stopTimeout = 1000 * 60 * 5, -- ms, timeout before stopping all LSPs
      startTimeout = 1000 * 10, -- ms, timeout before restart
      silent = false, -- true to suppress notifications
      filetypes = {
        ignore = { -- filetypes to ignore; empty by default
          -- lsp-timeout is disabled completely
        }, -- for these filetypes
      },
    },
  })
end

return M
