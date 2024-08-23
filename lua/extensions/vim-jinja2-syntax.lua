-- https://github.com/Glench/Vim-Jinja2-Syntax
local M = {}

M.name = "Glench/Vim-Jinja2-Syntax"

function M.config()
  require("setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "glench/vim-jinja2-syntax",
        ft = { "jinja" },
      }
    end,
  })
end

return M
