-- https://github.com/phaazon/hop.nvim
local M = {}

local extension_name = "hop"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "phaazon/hop.nvim",
        config = function()
          require("utils.setup").packer_config "hop"
        end,
        disable = not config.active,
      }
    end,
    setup = {},
    on_setup = function(config)
      require("hop").setup(config.setup)
    end,
    keymaps = {
      n = {
        ["s"] = { ":HopChar2<cr>" },
        ["ss"] = { ":HopChar1<cr>" },
        ["sw"] = { ":HopPattern<cr>" },
        ["sf"] = { ":HopChar1CurrentLine<cr>" },
        ["S"] = { ":HopWord<cr>" },
        ["SS"] = { ":HopLine<cr>" },
      },
    },
  })
end

return M
