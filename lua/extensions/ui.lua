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
          lazy = false,
        },
        {
          "nvim-lua/popup.nvim",
          event = "VeryLazy",
        },
        { "Tastyep/structlog.nvim", lazy = false },
        {
          "kyazdani42/nvim-web-devicons",
          lazy = false,
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
