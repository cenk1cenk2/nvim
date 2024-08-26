-- https://github.com/folke/lazydev.nvim
local M = {}

M.name = "folke/lazydev.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "folke/lazydev.nvim",
        ft = { "lua" },
        dependencies = {
          "Bilal2453/luvit-meta",
        },
        cmd = {
          "LazyDev",
        },
      }
    end,
    setup = function()
      ---@type lazydev.Config
      return {
        library = {
          { path = "luvit-meta/library", words = { "vim%.uv" } },
          { path = "lazy.nvim" },
          { path = "plenary.nvim" },
          { path = "which-key.nvim" },
        },
      }
    end,
    on_setup = function(c)
      require("lazydev").setup(c)
    end,
  })
end

return M
