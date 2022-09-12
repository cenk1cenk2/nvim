-- https://github.com/AckslD/nvim-trevJ.lua

local M = {}

local extension_name = "nvim_treevj"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "AckslD/nvim-trevJ.lua",
        config = function()
          require("utils.setup").packer_config "nvim_treevj"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        trevj = require "trevj",
      }
    end,
    setup = {},
    on_setup = function(config)
      require("trevj").setup(config.setup)
    end,
    keymaps = function(config)
      return {
        n = {
          ["gJ"] = {
            config.inject.trevj.format_at_cursor,
            { desc = "split lines" },
          },
        },
      }
    end,
  })
end

return M
