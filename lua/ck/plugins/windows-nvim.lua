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
        -- Pause windows.nvim autowidth while diffview tabs are active. The
        -- autowidth resize fires on BufWinEnter/WinEnter during diffview's
        -- layout construction and can invalidate the throwaway `curwin`
        -- before diffview closes it, causing "Invalid window id" errors
        -- (notably via gitlab.nvim's reviewer).
        {
          event = "User",
          group = "_windows_nvim_diffview_pause",
          pattern = { "DiffviewViewOpened", "DiffviewViewEnter" },
          callback = function()
            pcall(function()
              require("windows.autowidth").disable()
            end)
          end,
        },
        {
          event = "User",
          group = "_windows_nvim_diffview_pause",
          pattern = { "DiffviewViewClosed", "DiffviewViewLeave" },
          callback = function()
            pcall(function()
              require("windows.autowidth").enable()
            end)
          end,
        },
      }
    end,
  })
end

return M
