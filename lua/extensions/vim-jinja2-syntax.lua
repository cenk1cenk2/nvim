-- https://github.com/Glench/Vim-Jinja2-Syntax
local M = {}

local extension_name = "vim_jinja2_syntax"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "glench/vim-jinja2-syntax",
        config = function()
          require("utils.setup").plugin_init "vim_jinja2_syntax"
        end,
        enabled = config.active,
      }
    end,
  })
end

return M
