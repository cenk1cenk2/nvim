-- https://github.com/TrevorS/uuid-nvim
local M = {}
local Log = require("lvim.core.log")

local extension_name = "TrevorS/uuid-nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "TrevorS/uuid-nvim",
      }
    end,
    setup = function()
      return {
        case = "lower",
        quotes = "none",
      }
    end,
    on_setup = function(config)
      require("uuid-nvim").setup(config.setup)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.TASKS, "u" }),
          function()
            local uuid = require("uuid-nvim").get_v4({ quotes = "none" })

            vim.fn.setreg(vim.v.register or lvim.system_register, uuid)
            Log:info(("Copied generated uuid to clipboard: %s"):format(uuid))
          end,
          desc = "generate uuid",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "U" }),
          function()
            require("uuid-nvim").insert_v4()
          end,
          desc = "insert uuid",
        },
      }
    end,
  })
end

return M
