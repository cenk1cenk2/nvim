-- https://github.com/mg979/vim-visual-multi
local M = {}

local extension_name = "vim_visual_multi"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "mg979/vim-visual-multi",
        config = function()
          require("utils.setup").packer_config "vim_visual_multi"
        end,
        disable = not config.active,
      }
    end,
    legacy_setup = {
      VM_theme_set_by_colorscheme = 1,
    },
  })
end

return M
