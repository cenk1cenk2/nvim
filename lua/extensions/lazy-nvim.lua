-- https://github.com/folke/lazy.nvim
local M = {}

local extension_name = "folke/lazy.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "folke/lazy.nvim",
      }
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.PLUGINS, "i" }),
          ":Lazy install<CR>",
          desc = "install",
        },
        {
          fn.wk_keystroke({ categories.PLUGINS, "x" }),
          ":Lazy clean<CR>",
          desc = "clean",
        },
        {
          fn.wk_keystroke({ categories.PLUGINS, "l" }),
          ":Lazy log<CR>",
          desc = "log",
        },
        {
          fn.wk_keystroke({ categories.PLUGINS, "s" }),
          ":Lazy sync<CR>",
          desc = "sync",
        },
        {
          fn.wk_keystroke({ categories.PLUGINS, "S" }),
          ":Lazy<CR>",
          desc = "status",
        },
        {
          fn.wk_keystroke({ categories.PLUGINS, "r" }),
          ":Lazy restore<CR>",
          desc = "restore",
        },
        {
          fn.wk_keystroke({ categories.PLUGINS, "p" }),
          ":Lazy profile<CR>",
          desc = "profile",
        },
        {
          fn.wk_keystroke({ categories.PLUGINS, "u" }),
          ":Lazy update<CR>",
          desc = "update",
        },
        {
          fn.wk_keystroke({ categories.LOGS, "p" }),
          function()
            lvim.fn.toggle_log_view("lazy.nvim")
          end,
          desc = "view plugin manager log",
        },
      }
    end,
  })
end

return M