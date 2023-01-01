-- https://github.com/mg979/vim-visual-multi
local M = {}

local extension_name = "vim_visual_multi"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "mg979/vim-visual-multi",
        event = "BufReadPost",
      }
    end,
    legacy_setup = {
      VM_theme_set_by_colorscheme = 1,
    },
  })
end

return M
