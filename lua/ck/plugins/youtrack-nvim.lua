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
    setup = function()
      ---@type youtrack.Config
      return {
        url = vim.env["YOUTRACK_URL"],
        token = vim.env["YOUTRACK_TOKEN"],
      }
    end,
    on_setup = function(c)
      require("youtrack").setup(c)
    end,
  })
end

return M
