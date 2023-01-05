-- https://github.com/shortcuts/no-neck-pain.nvim
local M = {}

local extension_name = "no_neck_pain_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "shortcuts/no-neck-pain.nvim",
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "no-neck-pain",
      })
    end,
    inject_to_configure = function()
      return {
        no_neck_pain = require("no-neck-pain"),
      }
    end,
    setup = function(config)
      local no_neck_pain = config.inject.no_neck_pain

      return {
        -- the width of the current buffer. If the available screen size is less than `width`,
        -- the buffer will take the whole screen.
        width = 180,
        -- prints useful logs about what event are triggered, and reasons actions are executed.
        debug = false,
        -- only add a left buffer as "padding", which leave all the current buffer expand
        -- to the right of the screen.
        buffers = {
          -- The background options of the side buffer(s).
          background = {
            colorCode = lvim.ui.colors.bg[100],
          },
          -- When `false`, the `left` padding buffer won't be created.
          left = no_neck_pain.bufferOptions,
          -- When `false`, the `right` padding buffer won't be created.
          right = no_neck_pain.bufferOptions,
        },
      }
    end,
    on_setup = function(config)
      require("no-neck-pain").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.ACTIONS] = {
          ["z"] = {
            function()
              require("no-neck-pain").toggle()
            end,
            "zen mode",
          },
        },
      }
    end,
  })
end

return M
