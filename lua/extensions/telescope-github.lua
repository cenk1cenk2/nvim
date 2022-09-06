-- https://github.com/nvim-telescope/telescope-github.nvim
local M = {}

local extension_name = "telescope_github"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "nvim-telescope/telescope-github.nvim",
        requires = { "nvim-telescope/telescope.nvim" },
        config = function()
          require("utils.setup").packer_config "telescope_github"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        telescope = require "telescope",
      }
    end,
    on_setup = function(config)
      config.inject.telescope.load_extension "gh"
    end,
  })
end

return M
