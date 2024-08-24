-- https://github.com/asiryk/auto-hlsearch.nvim
local M = {}

M.name = "asiryk/auto-hlsearch.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "asiryk/auto-hlsearch.nvim",
        keys = { "/", "?", "*", "#", "n", "N" },
      }
    end,
    setup = function()
      return {
        remap_keys = { "/", "?", "*", "#", "n", "N" },
      }
    end,
    on_setup = function(c)
      require("auto-hlsearch").setup(c)
    end,
  })
end

return M
