-- https://github.com/folke/lazydev.nvim
local M = {}

M.name = "folke/lazydev.nvim"

function M.config()
  require("setup").define_extension(M.name, true, {
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
      return {
        library = {},
      }
    end,
    on_setup = function(c)
      require("lazydev").setup(c)
    end,
  })
end

return M
