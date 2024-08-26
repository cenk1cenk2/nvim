-- https://github.com/Tastyep/structlog.nvim
local M = {}

M.name = "Tastyep/structlog.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "Tastyep/structlog.nvim",
        lazy = false,
      }
    end,
    setup = function()
      require("ck.log"):get()
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.LOGS, "s" }),
          function()
            vim.ui.select(require("ck.log").levels, {
              prompt = "Log Level",
            }, function(level)
              require("ck.log"):set_level(level)
            end)
          end,
          desc = "set log level",
        },
      }
    end,
  })
end

return M
