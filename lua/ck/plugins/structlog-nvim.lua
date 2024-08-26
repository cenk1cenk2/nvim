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
  })
end

return M
