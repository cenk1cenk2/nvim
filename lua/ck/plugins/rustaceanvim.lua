-- https://github.com/mrcjkb/rustaceanvim
local M = {}

M.name = "mrcjkb/rustaceanvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "mrcjkb/rustaceanvim",
        version = "^9",
        ft = { "rust" },
      }
    end,
    on_init = function()
      vim.g.rustaceanvim = vim.tbl_deep_extend("force", vim.g.rustaceanvim or {}, {
        server = {
          auto_attach = false,
        },
      })
    end,
  })
end

return M
