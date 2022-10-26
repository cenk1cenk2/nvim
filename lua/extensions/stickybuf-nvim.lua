-- https://github.com/stevearc/stickybuf.nvim
local M = {}

local extension_name = "stickybuf_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "stevearc/stickybuf.nvim",
        config = function()
          require("utils.setup").packer_config "stickybuf_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      filetype = {
        aerial = "filetype",
        nerdtree = "filetype",
        ["neo-tree"] = "filetype",
        ["neotest-summary"] = "filetype",
      },
    },
    on_setup = function(config)
      require("stickybuf").setup(config.setup)
    end,
  })
end

return M
