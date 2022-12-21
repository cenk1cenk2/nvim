-- https://github.com/nvim-telescope/telescope-github.nvim
local M = {}

local extension_name = "telescope_github"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "nvim-telescope/telescope-github.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        enabled = config.active,
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
