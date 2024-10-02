-- https://github.com/mikesmithgh/kitty-scrollback.nvim
local M = {}

M.name = "mikesmithgh/kitty-scrollback.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "mikesmithgh/kitty-scrollback.nvim",
        cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
        event = { "User KittyScrollbackLaunch" },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(c)
      require("kitty-scrollback").setup(c)
    end,
  })
end

return M
