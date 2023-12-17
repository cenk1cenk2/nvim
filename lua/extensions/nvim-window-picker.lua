-- https://github.com/s1n7ax/nvim-window-picker
local M = {}

local extension_name = "nvim_window_picker"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "s1n7ax/nvim-window-picker",
      }
    end,
    setup = function()
      return {
        selection_chars = lvim.selection_chars:upper(),
        picker_config = {
          statusline_winbar_picker = {
            use_winbar = "always",
          },
        },
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
        highlights = {
          winbar = {
            focused = {
              fg = lvim.ui.colors.fg,
              bg = lvim.ui.colors.yellow[300],
              bold = true,
            },
            unfocused = {
              fg = lvim.ui.colors.fg,
              bg = lvim.ui.colors.orange[300],
              bold = true,
            },
          },
        },
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
