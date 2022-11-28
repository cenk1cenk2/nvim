-- https://github.com/Vonr/align.nvim
local M = {}

local extension_name = "align_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "Vonr/align.nvim",
        config = function()
          require("utils.setup").packer_config "align_nvim"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        align = require "align",
      }
    end,
    keymaps = function(config)
      local align = config.inject.align

      return {
        v = {
          ["gas"] = {
            function()
              align.align_to_string(false, true, true)
            end,
            { desc = "align to string" },
          },
          ["gar"] = {
            function()
              align.align_to_string(true, true, true)
            end,
            { desc = "align to regex" },
          },
          ["gac"] = {
            function()
              align.align_to_char(1, true)
            end,
            { desc = "align to char" },
          },
        },
      }
    end,
  })
end

return M
