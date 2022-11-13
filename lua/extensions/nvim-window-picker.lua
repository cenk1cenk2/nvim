-- https://github.com/s1n7ax/nvim-window-picker
local M = {}

local extension_name = "nvim_window_picker"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "s1n7ax/nvim-window-picker",
        config = function()
          require("utils.setup").packer_config "nvim_window_picker"
        end,
        disable = not config.active,
      }
    end,
    setup = function()
      local colors = require "onedarker.colors"

      return {
        selection_chars = "ASDFGQWERYXCVB",
        use_winbar = "always",
        filter_rules = {
          bo = {
            filetype = vim.tbl_filter(function(ft)
              local items = { "alpha" }
              if vim.tbl_contains(items, ft) then
                return false
              end

              return true
            end, lvim.disabled_filetypes),
          },
        },
        fg_color = colors.fg,
        current_win_hl_color = colors.green[600],
        other_win_hl_color = colors.bg[400],
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
