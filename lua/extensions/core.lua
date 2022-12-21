--
local M = {}

local extension_name = "core"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    opts = {
      multiple_packages = true,
    },
    plugin = function()
      return {
        { "nvim-lua/plenary.nvim" },
        {
          "rcarriga/nvim-notify",
          init = function()
            require("lvim.core.notify").setup()
          end,
          lazy = false,
          enabled = lvim.builtin.notify.active,
        },
        { "nvim-lua/popup.nvim", lazy = false },
        { "Tastyep/structlog.nvim", lazy = false },
        {
          "kyazdani42/nvim-web-devicons",
          lazy = false,
          enabled = lvim.use_icons,
        },
        { "MunifTanjim/nui.nvim", event = "VeryLazy" },
      }
    end,
  })
end

return M
