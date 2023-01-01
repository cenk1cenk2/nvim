-- https://github.com/Darazaki/indent-o-matic
local M = {}

local extension_name = "indent_o_matic"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "Darazaki/indent-o-matic",
        config = function()
          require("utils.setup").packer_config("indent_o_matic")
        end,
        disable = not config.active,
      }
    end,
    setup = {
      max_lines = 256,
      standard_widths = { 2, 4 },
    },
    on_setup = function(config)
      require("indent-o-matic").setup(config.setup)
    end,
  })
end

return M
