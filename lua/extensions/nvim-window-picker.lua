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
    configure = function()
      nvim.fn.pick_window = M.pick_window
    end,
    setup = function()
      return {
        selection_chars = nvim.selection_chars:upper(),
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
            end, nvim.disabled_filetypes),
          },
        },
        highlights = {
          winbar = {
            focused = {
              fg = nvim.ui.colors.fg,
              bg = nvim.ui.colors.yellow[300],
              bold = true,
            },
            unfocused = {
              fg = nvim.ui.colors.fg,
              bg = nvim.ui.colors.orange[300],
              bold = true,
            },
          },
        },
      }
    end,
    on_setup = function(c)
      require("window-picker").setup(c)
    end,
  })
end

function M.pick_window()
  return require("window-picker").pick_window()
end

return M
