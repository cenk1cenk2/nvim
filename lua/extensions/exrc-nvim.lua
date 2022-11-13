-- https://github.com/MunifTanjim/exrc.nvim
local M = {}

local extension_name = "exrc_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "MunifTanjim/exrc.nvim",
        config = function()
          require("utils.setup").packer_config "exrc_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = function()
      return {
        files = {
          ".nvimrc.lua",
          ".nvimrc",
          ".exrc.lua",
          ".exrc",
        },
      }
    end,
    on_setup = function(config)
      vim.o.exrc = false

      require("exrc").setup(config.setup)
    end,
  })
end

return M
