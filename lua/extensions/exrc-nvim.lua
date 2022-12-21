-- https://github.com/MunifTanjim/exrc.nvim
local M = {}

local extension_name = "exrc_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "MunifTanjim/exrc.nvim",
        init = function()
          require("utils.setup").plugin_init "exrc_nvim"
        end,
        enabled = config.active,
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
