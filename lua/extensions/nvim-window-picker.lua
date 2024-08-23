-- https://github.com/s1n7ax/nvim-window-picker
local M = {}

M.name = "s1n7ax/nvim-window-picker"

function M.config()
  require("setup").define_extension(M.name, true, {
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
    on_setup = function(c)
      require("window-picker").setup(c)
    end,
    define_global_fn = function()
      return {
        pick_window = function()
          return require("window-picker").pick_window()
        end,
      }
    end,
  })
end

return M
