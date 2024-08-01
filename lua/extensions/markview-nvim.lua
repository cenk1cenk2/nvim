-- https://github.com/OXY2DEV/markview.nvim
local M = {}

local extension_name = "OXY2DEV/markview.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "OXY2DEV/markview.nvim",
        ft = { "markdown" },
      }
    end,
    setup = function()
      local defaults = require("markview").configuration
      return {
        headings = vim.tbl_deep_extend("force", vim.deepcopy(defaults.headings), {
          enable = true,
          shift_width = 0,
          shift_char = "",
          heading_1 = {
            hl = "@markup.heading.1.markdown",
          },
          heading_2 = {
            hl = "@markup.heading.2.markdown",
          },
          heading_3 = {
            hl = "@markup.heading.3.markdown",
          },
          heading_4 = {
            hl = "@markup.heading.4.markdown",
          },
          heading_5 = {
            hl = "@markup.heading.5.markdown",
          },
          heading_6 = {
            hl = "@markup.heading.6.markdown",
          },
        }),
      }
    end,
    on_setup = function(config)
      require("markview").setup(config.setup)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.TASKS, "m" }),
          function()
            require("markview").commands.toggle()
          end,
          desc = "toggle markdown preview",
        },
      }
    end,
  })
end

return M
