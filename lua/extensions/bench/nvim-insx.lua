-- https://github.com/hrsh7th/nvim-insx
local M = {}

local extension_name = "nvim_insx"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "hrsh7th/nvim-insx",
        event = { "InsertEnter", "CmdlineEnter" },
      }
    end,
    on_setup = function()
      require("insx.preset.standard").setup()
    end,
  })
end

return M
