-- https://github.com/axieax/urlview.nvim
local M = {}

M.name = "axieax/urlview.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "axieax/urlview.nvim",
        cmd = {
          "UrlView",
        },
      }
    end,
    setup = function()
      return {
        -- default_picker = "telescope",
        default_action = "system",
        jump = {
          prev = "[u",
          next = "]u",
        },
      }
    end,
    on_setup = function(c)
      require("urlview").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.FIND, "u" }),
          function()
            vim.cmd([[UrlView buffer]])
          end,
          desc = "hyperlinks in buffer",
        },
      }
    end,
  })
end

return M
