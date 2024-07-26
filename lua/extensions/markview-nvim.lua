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
      return {}
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
