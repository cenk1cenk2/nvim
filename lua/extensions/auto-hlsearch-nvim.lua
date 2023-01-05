-- https://github.com/asiryk/auto-hlsearch.nvim
local M = {}

local extension_name = "auto_hlsearch_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
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
