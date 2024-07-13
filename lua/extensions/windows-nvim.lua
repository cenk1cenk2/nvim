-- https://github.com/anuvyklack/windows.nvim
local M = {}

local extension_name = "windows_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "anuvyklack/windows.nvim",
        dependencies = {
          "anuvyklack/middleclass",
          "anuvyklack/animation.nvim",
        },
        event = "BufReadPost",
        cmd = { "WindowsEqualize" },
      }
    end,
    setup = function()
      return {
        autowidth = { --		     |windows.autowidth|
          enable = true,
          winwidth = 10, --		      |windows.winwidth|
          filetype = { --	    |windows.autowidth.filetype|
            help = 2,
          },
        },
        ignore = { --			|windows.ignore|
          buftype = { "quickfix", "nofile" },
          filetype = lvim.disabled_filetypes,
        },
        animation = {
          enable = false,
          duration = 100,
          fps = 60,
          easing = "in_out_sine",
        },
      }
    end,
    on_setup = function(config)
      require("windows").setup(config.setup)
    end,
    nvim_opts = {
      winwidth = 10,
      winminwidth = 0,
      equalalways = false,
    },
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.ACTIONS, "w" }),
          function()
            vim.cmd([[WindowsEqualize]])
          end,
          desc = "balance open windows",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "m" }),
          function()
            vim.cmd([[WindowsMaximize]])
          end,
          desc = "maximize current window",
        },
      }
    end,
    autocmds = {
      {
        "VimResized",
        {
          group = "_auto_resize",
          pattern = "*",
          command = ":WindowsEqualize",
        },
      },
    },
  })
end

return M
