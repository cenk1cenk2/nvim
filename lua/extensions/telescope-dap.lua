-- https://github.com/nvim-telescope/telescope-dap.nvim
local M = {}

local extension_name = "telescope_dap"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "nvim-telescope/telescope-dap.nvim",
        requires = { "nvim-telescope/telescope.nvim" },
        after = { "nvim-dap" },
        config = function()
          require("utils.setup").packer_config "telescope_dap"
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
      config.inject.telescope.load_extension "dap"
    end,
    wk = function(_, categories)
      return {
        [categories.DEBUG] = {
          ["l"] = { ":Telescope dap configurations<CR>", "configurations" },
        },
      }
    end,
  })
end

return M
