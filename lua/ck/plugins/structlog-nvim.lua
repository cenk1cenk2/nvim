-- https://github.com/Tastyep/structlog.nvim
local M = {}

M.name = "Tastyep/structlog.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "Tastyep/structlog.nvim",
        lazy = false,
      }
    end,
    setup = function()
      require("ck.log"):setup()
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.NEOVIM, categories.LOGS, "l" }),
          function()
            vim.ui.select(require("ck.log").levels, {
              prompt = "Log Level",
            }, function(level)
              if not level then
                return
              end

              require("ck.log"):set_log_level(level)
            end)
          end,
          desc = "set log level",
        },
      }
    end,
  })
end

return M
