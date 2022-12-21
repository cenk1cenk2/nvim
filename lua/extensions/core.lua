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
          config = function()
            require("lvim.core.notify").setup()
          end,
          enabled = lvim.builtin.notify.active,
        },
        { "nvim-lua/popup.nvim" },
        { "Tastyep/structlog.nvim" },
        {
          "kyazdani42/nvim-web-devicons",
          enabled = lvim.use_icons,
        },
        { "MunifTanjim/nui.nvim" },
      }
    end,
  })
end

return M
