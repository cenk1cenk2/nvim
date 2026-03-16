-- https://github.com/folke/ts-comments.nvim
local M = {}

M.name = "folke/ts-comments.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "folke/ts-comments.nvim",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {
        lang = {
          gomod = "// %s",
          helm = "# %s",
          hurl = "# %s",
        },
      }
    end,
    on_setup = function(c)
      require("ts-comments").setup(c)
    end,
  })
end

return M
