-- https://github.com/folke/lazy.nvim
local M = {}

M.name = "folke/lazy.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "folke/lazy.nvim",
      }
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
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
      }
    end,
  })
end

return M
