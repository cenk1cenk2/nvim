-- https://github.com/pwntester/octo.nvim
local M = {}

local extension_name = "octo"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "pwntester/octo.nvim",
        config = function()
          require("utils.setup").packer_config "octo"
        end,
        disable = not config.active,
      }
    end,
    setup = {},
    on_setup = function(config)
      require("octo").setup(config.setup)
    end,
  })
end

return M
