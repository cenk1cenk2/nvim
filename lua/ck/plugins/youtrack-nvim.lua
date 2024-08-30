-- https://github.com/ruslan-korneev/youtrack.nvim
local M = {}

M.name = "cenk1cenk2/youtrack.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        dir = "~/development/youtrack.nvim",
        lazy = false,
      }
    end,
    on_setup = function()
      require("youtrack").setup({})
    end,
  })
end

return M
