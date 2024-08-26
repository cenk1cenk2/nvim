-- https://github.com/pwntester/octo.nvim
local M = {}

M.name = "pwntester/octo.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "pwntester/octo.nvim",
        cmd = { "Octo" },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(c)
      require("octo").setup(c)
    end,
  })
end

return M
