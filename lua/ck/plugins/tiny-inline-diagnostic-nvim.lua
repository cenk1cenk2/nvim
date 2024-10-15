-- https://github.com/rachartier/tiny-inline-diagnostic.nvim
local M = {}

M.name = "rachartier/tiny-inline-diagnostic.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, false, {
    plugin = function()
      ---@type Plugin
      return {
        "rachartier/tiny-inline-diagnostic.nvim",
        -- event = { "LspAttach" },
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    configure = function()
      nvim.lsp.diagnostics.virtual_text = false
    end,
    setup = function()
      return {
        options = {
          -- Show the source of the diagnostic.
          show_source = false,
          format = function(diagnostic)
            return "[" .. diagnostic.source .. "] " .. diagnostic.message
          end,
          throttle = 0,
          multilines = true,
          multiple_diag_under_cursor = true,
        },
      }
    end,
    on_setup = function(c)
      require("tiny-inline-diagnostic").setup(c)
    end,
  })
end

return M
