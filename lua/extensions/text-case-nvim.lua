-- https://github.com/johmsalas/text-case.nvim
local M = {}

local extension_name = "text_case_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "johmsalas/text-case.nvim",
        event = "BufReadPost",
        config = function()
          require("utils.setup").plugin_init "text_case_nvim"
        end,
        enabled = config.active,
      }
    end,
    setup = {
      prefix = "gs",
    },
    on_setup = function(config)
      -- subs command comes from here!
      require("textcase").setup(config.setup)
    end,
  })
end

return M
