-- https://github.com/asiryk/auto-hlsearch.nvim
local M = {}

M.name = "asiryk/auto-hlsearch.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
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
    on_setup = function(config)
      require("auto-hlsearch").setup(config.setup)
    end,
  })
end

return M
