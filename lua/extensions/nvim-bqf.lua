-- https://github.com/kevinhwang91/nvim-bqf
local M = {}

local extension_name = "nvim_bqf"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "kevinhwang91/nvim-bqf",
        event = "VeryLazy",
      }
    end,
    setup = function()
      return {
        auto_enable = true,
        preview = {
          win_height = 12,
          win_vheight = 12,
          delay_syntax = 80,
          border_chars = lvim.ui.icons.borderchars,
        },
        func_map = { vsplit = "", ptogglemode = "z,", stoggleup = "" },
        filter = {
          fzf = {
            action_for = { ["ctrl-s"] = "split" },
            extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
          },
        },
      }
    end,
    on_setup = function(config)
      require("bqf").setup(config.setup)
    end,
  })
end

return M
