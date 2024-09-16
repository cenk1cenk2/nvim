-- https://github.com/mikavilpas/yazi.nvim
local M = {}

M.name = "mikavilpas/yazi.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "mikavilpas/yazi.nvim",
        cmd = { "Yazi" },
      }
    end,
    setup = function()
      ---@type YaziConfig
      return {
        yazi_floating_window_border = nvim.ui.border,
        highlight_hovered_buffers_in_same_directory = false,
        keymaps = {
          show_help = "<f1>",
          open_file_in_vertical_split = "<c-v>",
          open_file_in_horizontal_split = "<c-x>",
          open_file_in_tab = "<c-t>",
          grep_in_directory = false,
          replace_in_directory = false,
          cycle_open_buffers = "<c-n>",
          copy_relative_path_to_selected_files = false,
          send_to_quickfix_list = "<c-q>",
        },
      }
    end,
    on_setup = function(c)
      require("yazi").setup(c)
    end,
    keymaps = function()
      return {
        {
          "<F5>",
          function()
            require("yazi").toggle()
          end,
          mode = { "n", "t" },
        },
      }
    end,
  })
end

return M
