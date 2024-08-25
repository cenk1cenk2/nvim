--
local M = {}

M.name = "ui"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    opts = {
      multiple_packages = true,
    },
    plugin = function()
      return {
        {
          "nvim-lua/plenary.nvim",
          init = false,
          config = false,
        },
        {
          "Tastyep/structlog.nvim",
          lazy = false,
          config = function()
            require("ck.log"):get()
          end,
        },
        -- {
        --   "nvim-tree/nvim-web-devicons",
        --   event = "UIEnter",
        --   init = false,
        --   config = false,
        -- },
        {
          "MunifTanjim/nui.nvim",
          event = "VeryLazy",
          init = false,
          config = false,
        },
      }
    end,
  })
end

return M
