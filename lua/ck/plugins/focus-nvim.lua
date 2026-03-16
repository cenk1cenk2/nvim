-- https://github.com/nvim-focus/focus.nvim
local M = {}

M.name = "nvim-focus/focus.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "nvim-focus/focus.nvim",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
        cmd = { "FocusEqualise", "FocusMaximise", "FocusMaxOrEqual", "FocusToggle" },
      }
    end,
    setup = function()
      return {
        commands = false,
        autoresize = {
          enable = true,
          minwidth = 5,
        },
        ui = {
          signcolumn = false,
          cursorline = false,
        },
      }
    end,
    configure = function()
      vim.opt.winminwidth = 0
      vim.opt.equalalways = false
    end,
    on_setup = function(c)
      require("focus").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.ACTIONS, "w" }),
          function()
            require("focus").focus_equalise()
          end,
          desc = "balance open windows",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "m" }),
          function()
            require("focus").focus_max_or_equal()
          end,
          desc = "maximize current window",
        },
      }
    end,
    autocmds = function()
      ---@type Autocmds
      return {
        {
          event = "VimResized",
          group = "_auto_resize",
          pattern = "*",
          callback = function()
            require("focus").focus_equalise()
          end,
        },
        {
          event = "WinEnter",
          group = "_focus_disable",
          clear = true,
          callback = function()
            local ignore_buftypes = { "quickfix", "nofile", "prompt", "popup" }
            vim.w.focus_disable = vim.tbl_contains(ignore_buftypes, vim.bo.buftype)
          end,
        },
        {
          event = "FileType",
          group = "_focus_disable_ft",
          clear = true,
          callback = function()
            vim.b.focus_disable = vim.tbl_contains(nvim.disabled_filetypes, vim.bo.filetype)
          end,
        },
      }
    end,
  })
end

return M
