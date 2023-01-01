-- https://github.com/nvim-telescope/telescope-github.nvim
local M = {}

local extension_name = "telescope_github"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "nvim-telescope/telescope-github.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = { "Telescope gh" },
      }
    end,
    inject_to_configure = function()
      return {
        telescope = require("telescope"),
      }
    end,
    on_setup = function(config)
      config.inject.telescope.load_extension("gh")
    end,
  })
end

return M
