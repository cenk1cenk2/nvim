-- https://github.com/wintermute-cell/gitignore.nvim
local M = {}

M.name = "wintermute-cell/gitignore.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "wintermute-cell/gitignore.nvim",
      }
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.GIT, "i" }),
          function()
            require("gitignore").generate()
          end,
          desc = "generate git ignore",
        },
      }
    end,
  })
end

return M
