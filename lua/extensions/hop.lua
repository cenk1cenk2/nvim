-- https://github.com/phaazon/hop.nvim

local setup = require "utils.setup"

local M = {}

local extension_name = "hop"

function M.config()
  setup.define_extension(extension_name, true, {
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
      ["s"] = { { "n" }, ":HopChar2<cr>" },
      ["ss"] = { { "n" }, ":HopChar1<cr>" },
      ["sw"] = { { "n" }, ":HopPattern<cr>" },
      ["S"] = { { "n" }, ":HopWord<cr>" },
      ["SS"] = { { "n" }, ":HopLine<cr>" },
    },
  })
end

return M
