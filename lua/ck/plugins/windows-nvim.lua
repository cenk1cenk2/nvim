-- https://github.com/anuvyklack/windows.nvim
local M = {}

M.name = "anuvyklack/windows.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "anuvyklack/windows.nvim",
        dependencies = {
          "anuvyklack/middleclass",
        },
        event = { "BufReadPost", "BufNewFile", "BufNew" },
        cmd = { "WindowsEqualize" },
      }
    end,
    setup = function()
      return {
        autowidth = { --		     |windows.autowidth|
          enable = true,
          winwidth = 0.25, --		      |windows.winwidth|
          filetype = { --	    |windows.autowidth.filetype|
            help = 2,
          },
        },
        ignore = { --			|windows.ignore|
          buftype = { "quickfix", "nofile" },
          filetype = nvim.disabled_filetypes,
        },
        animation = {
          enable = false,
          duration = 100,
          fps = 60,
          easing = "in_out_sine",
        },
      }
    end,
    on_setup = function(c)
      vim.opt.winwidth = 5
      vim.opt.winminwidth = 0
      vim.opt.equalalways = false
      require("windows").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
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
    autocmds = function()
      return {
        {
          event = "VimResized",
          group = "_auto_resize",
          pattern = "*",
          command = ":WindowsEqualize",
        },
      }
    end,
  })
end

return M
