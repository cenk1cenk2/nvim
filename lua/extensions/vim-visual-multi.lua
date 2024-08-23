-- https://github.com/mg979/vim-visual-multi
local M = {}

M.name = "mg979/vim-visual-multi"

function M.config()
  require("setup").define_extension(M.name, false, {
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
