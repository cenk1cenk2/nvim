-- https://github.com/mg979/vim-visual-multi
local M = {}

M.name = "mg979/vim-visual-multi"

function M.config()
  require("ck.setup").define_plugin(M.name, false, {
    plugin = function()
      ---@type Plugin
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
