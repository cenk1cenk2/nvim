-- https://github.com/axieax/urlview.nvim
local M = {}

local extension_name = "axieax/urlview.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
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
    on_setup = function(config)
      require("urlview").setup(config.setup)
    end,
    wk = function(_, categories, fn)
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
