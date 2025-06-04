-- https://github.com/rachartier/tiny-inline-diagnostic.nvim
local M = {}

M.name = "rachartier/tiny-inline-diagnostic.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        -- TODO: https://github.com/rachartier/tiny-inline-diagnostic.nvim/pull/121
        -- "rachartier/tiny-inline-diagnostic.nvim",
        "moar-orchid/tiny-inline-diagnostic.nvim",
        branch = "patch-1",
        -- event = { "LspAttach" },
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    configure = function()
      nvim.lsp.diagnostics.virtual_text = false
    end,
    setup = function()
      return {
        preset = "powerline",
        signs = {
          diag = nvim.ui.icons.ui.SquareCentered,
        },
        options = {
          -- Show the source of the diagnostic.
          show_source = {
            enabled = false,
          },
          format = function(diagnostic)
            if not diagnostic.source then
              return diagnostic.message
            end

            return "[" .. diagnostic.source .. "] " .. diagnostic.message
          end,
          throttle = 0,
          multilines = {
            enabled = true,
            always_show = true,
          },
          show_all_diags_on_cursorline = true,
          use_icons_from_diagnostic = true,
          set_arrow_to_diag_color = true,
        },
      }
    end,
    on_setup = function(c)
      require("tiny-inline-diagnostic").setup(c)
    end,
  })
end

return M
