-- https://github.com/danymat/neogen
local M = {}

local extension_name = "neogen"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "danymat/neogen",
        requires = { "nvim-treesitter/nvim-treesitter" },
        config = function()
          require("utils.setup").packer_config "neogen"
        end,
        disable = not config.active,
      }
    end,
    setup = {},
    on_setup = function(config)
      require("neogen").setup(config.setup)
    end,
    wk = {
      ["l"] = {
        ["j"] = {
          function()
            require("neogen").generate()
          end,
          "generate documentation",
        },
      },
    },
  })
end

return M
