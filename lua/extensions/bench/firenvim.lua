--
local M = {}

local extension_name = "firenvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "glacambre/firenvim",
        lazy = false,
        build = function()
          require("lazy").load({ plugins = "firenvim", wait = true })
          vim.fn["firenvim#install"](0)
        end,
        cond = not not vim.g.started_by_firenvim,
      }
    end,
  })
end

return M
