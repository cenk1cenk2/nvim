-- https://github.com/tpope/vim-repeat
local M = {}

local extension_name = "vim_repeat"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "tpope/vim-repeat",
        config = function()
          require("utils.setup").packer_config "vim_repeat"
        end,
        disable = not config.active,
      }
    end,
  })
end

return M
