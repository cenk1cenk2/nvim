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
        },
        {
          "Tastyep/structlog.nvim",
          lazy = false,
          init = function()
            require("lvim.core.log"):init()
          end,
          config = false,
        },
        {
          "kyazdani42/nvim-web-devicons",
          event = "VeryLazy",
        },
        {
          "nvim-lua/popup.nvim",
          event = "VeryLazy",
        },
        {
          "MunifTanjim/nui.nvim",
          event = "VeryLazy",
        },
      }
    end,
  })
end

return M
