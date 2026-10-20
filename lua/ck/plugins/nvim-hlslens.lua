-- https://github.com/kevinhwang91/nvim-hlslens
local M = {}

M.name = "kevinhwang91/nvim-hlslens"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "kevinhwang91/nvim-hlslens",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(c)
      require("hlslens").setup(c)
    end,
  })
end

return M
