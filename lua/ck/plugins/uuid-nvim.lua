-- https://github.com/TrevorS/uuid-nvim
local M = {}
local log = require("ck.log")

M.name = "TrevorS/uuid-nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "TrevorS/uuid-nvim",
      }
    end,
    setup = function()
      ---@type UuidNvimSetup
      return {
        case = "lower",
        quotes = "none",
      }
    end,
    on_setup = function(c)
      require("uuid-nvim").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.TASKS, "u" }),
          function()
            local uuid = require("uuid-nvim").get_v4({ quotes = "none" })

            vim.fn.setreg(vim.v.register or nvim.system_register, uuid)
            log:info(("Copied generated uuid to clipboard: %s"):format(uuid))
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
