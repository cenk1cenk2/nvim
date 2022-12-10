-- https://github.com/shortcuts/no-neck-pain.nvim
local M = {}

local extension_name = "no_neck_pain_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "shortcuts/no-neck-pain.nvim",
        config = function()
          require("utils.setup").packer_config "no_neck_pain_nvim"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        no_neck_pain = require "no-neck-pain",
      }
    end,
    setup = {
      -- the width of the current buffer. If the available screen size is less than `width`,
      -- the buffer will take the whole screen.
      width = 180,
      -- prints useful logs about what event are triggered, and reasons actions are executed.
      debug = false,
      -- only add a left buffer as "padding", which leave all the current buffer expand
      -- to the right of the screen.
      leftPaddingOnly = false,
    },
    on_setup = function(config)
      require("no-neck-pain").setup(config.setup)
    end,
    wk = function(config, categories)
      local no_neck_pain = config.inject.no_neck_pain

      return {
        [categories.ACTIONS] = {
          ["z"] = function()
            no_neck_pain.start()
          end,
        },
      }
    end,
  })
end

return M
