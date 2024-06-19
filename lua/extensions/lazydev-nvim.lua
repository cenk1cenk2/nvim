-- https://github.com/folke/lazydev.nvim
local M = {}

local extension_name = "folke/lazydev.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "folke/lazydev.nvim",
        ft = { "lua" },
        cmd = {
          "LazyDev",
        },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(config)
      require("lazydev").setup(config.setup)
    end,
  })
end

return M
