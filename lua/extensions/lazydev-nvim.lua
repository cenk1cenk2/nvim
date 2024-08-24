-- https://github.com/folke/lazydev.nvim
local M = {}

M.name = "folke/lazydev.nvim"

function M.config()
  require("setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "folke/lazydev.nvim",
        ft = { "lua" },
        dependencies = {
          -- "Bilal2453/luvit-meta",
        },
        cmd = {
          "LazyDev",
        },
      }
    end,
    setup = function()
      return {
        library = {
          -- { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
      }
    end,
    on_setup = function(c)
      require("lazydev").setup(c)
    end,
  })
end

return M
