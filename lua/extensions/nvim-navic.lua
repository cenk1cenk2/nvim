-- https://github.com/SmiteshP/nvim-navic
local M = {}

local extension_name = "nvim_navic"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "SmiteshP/nvim-navic",
        config = function()
          require("utils.setup").packer_config "nvim_navic"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        navic = require "nvim-navic",
      }
    end,
    setup = {
      highlight = true,
      separator = " > ",
      depth_limit = 0,
      depth_limit_indicator = "..",
      safe_output = true,
    },
    on_setup = function(config)
      require("nvim-navic").setup(config.setup)
    end,
    on_done = function(config)
      local navic = config.inject.navic

      table.insert(lvim.lsp.on_attach_callbacks, function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end)
    end,
  })
end

return M
