--
local M = {}

local extension_name = "ui"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
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
            require("lvim.core.log"):get_logger()
          end,
        },
        {
          "nvim-tree/nvim-web-devicons",
          event = "UIEnter",
          init = false,
          config = false,
        },
        -- {
        --   "nvim-lua/popup.nvim",
        --   event = "VeryLazy",
        -- init = false,
        -- config = false,
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
