-- https://github.com/pwntester/octo.nvim
local M = {}

local extension_name = "octo"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "pwntester/octo.nvim",
        config = function()
          require("utils.setup").plugin_init "octo"
        end,
        enabled = config.active,
      }
    end,
    setup = {},
    on_setup = function(config)
      require("octo").setup(config.setup)
    end,
  })
end

return M
