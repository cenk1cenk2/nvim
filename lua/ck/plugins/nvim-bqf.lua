-- https://github.com/kevinhwang91/nvim-bqf
local M = {}

M.name = "kevinhwang91/nvim-bqf"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "kevinhwang91/nvim-bqf",
        ft = { "qf" },
      }
    end,
    setup = function()
      return {
        auto_enable = true,
        preview = {
          win_height = 12,
          win_vheight = 12,
          delay_syntax = 80,
          border_chars = nvim.ui.icons.borderchars,
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
    on_setup = function(c)
      require("bqf").setup(c)
    end,
  })
end

return M
