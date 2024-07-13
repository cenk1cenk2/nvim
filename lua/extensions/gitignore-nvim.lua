-- https://github.com/wintermute-cell/gitignore.nvim
local M = {}

local extension_name = "gitignore_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
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
