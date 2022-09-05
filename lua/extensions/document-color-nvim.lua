-- mrshmllow/document-color.nvim

local M = {}

local setup = require "utils.setup"

local extension_name = "document_color_nvim"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "mrshmllow/document-color.nvim",
        config = function()
          require("utils.setup").packer_config "document_color_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      mode = "background", -- "background" | "foreground" | "single"
    },
    on_setup = function(config)
      require("document-color").setup(config.setup)
    end,
  })
end

return M
