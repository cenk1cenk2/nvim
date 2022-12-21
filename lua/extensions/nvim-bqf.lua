-- https://github.com/kevinhwang91/nvim-bqf
local M = {}

local extension_name = "nvim_bqf"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "kevinhwang91/nvim-bqf",
        enabled = config.active,
      }
    end,
    setup = {
      auto_enable = true,
      preview = {
        win_height = 12,
        win_vheight = 12,
        delay_syntax = 80,
        border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
      },
      func_map = { vsplit = "", ptogglemode = "z,", stoggleup = "" },
      filter = {
        fzf = {
          action_for = { ["ctrl-s"] = "split" },
          extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
        },
      },
    },
    on_setup = function(config)
      require("bqf").setup(config.setup)
    end,
  })
end

return M
