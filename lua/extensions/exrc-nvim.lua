-- https://github.com/MunifTanjim/exrc.nvim
local M = {}

local extension_name = "exrc_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "MunifTanjim/exrc.nvim",
        lazy = false,
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
