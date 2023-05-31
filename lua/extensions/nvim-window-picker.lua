-- https://github.com/s1n7ax/nvim-window-picker
local M = {}

local extension_name = "nvim_window_picker"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "s1n7ax/nvim-window-picker",
        -- TODO: fix this and update after
        commit = "65bbc52c27b0cd4b29976fe03be73cc943357528",
      }
    end,
    setup = function()
      return {
        selection_chars = lvim.selection_chars:upper(),
        use_winbar = "always",
        filter_rules = {
          bo = {
            filetype = vim.tbl_filter(function(ft)
              if vim.tbl_contains({ "alpha" }, ft) then
                return false
              end

              return true
            end, lvim.disabled_filetypes),
          },
        },
        fg_color = lvim.ui.colors.fg,
        current_win_hl_color = lvim.ui.colors.green[300],
        other_win_hl_color = lvim.ui.colors.orange[300],
      }
    end,
    on_setup = function(config)
      require("window-picker").setup(config.setup)
    end,
    on_done = function()
      lvim.fn.pick_window = require("window-picker").pick_window()
    end,
  })
end

return M
