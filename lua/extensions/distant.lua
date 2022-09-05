-- https://github.com/chipsenkbeil/distant.nvim
local M = {}

local setup = require "utils.setup"

local extension_name = "distant"

function M.config()
  setup.define_extension(extension_name, false, {
    packer = function(config)
      return {
        "chipsenkbeil/distant.nvim",
        config = function()
          require("utils.setup").packer_config "distant"
        end,
        disable = not config.active,
      }
    end,
    condition = function(config)
      local status_ok, distant_settings = pcall(require, "distant.settings")

      if not status_ok then
        return false
      end

      config.set_injected("chip_default", distant_settings.chip_default)
    end,
    setup = function(config)
      return {
        ["*"] = config.inject.chip_default,
      }
    end,
    on_setup = function(config)
      require("distant").setup(config.setup)
    end,
  })
end

return M
