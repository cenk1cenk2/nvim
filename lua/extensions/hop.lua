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
    to_inject = function()
      return {
        hop = require "hop",
      }
    end,
    keymaps = function(config)
      local hop = config.inject.hop

      return {
        a = {
          ["f"] = {
            function()
              hop.hint_char1 { direction = require("hop.hint").HintDirection.AFTER_CURSOR, current_line_only = true }
            end,
          },
          ["ff"] = {
            function()
              hop.hint_char1 { direction = require("hop.hint").HintDirection.AFTER_CURSOR, current_line_only = false }
            end,
          },
          ["F"] = {
            function()
              hop.hint_char1 { direction = require("hop.hint").HintDirection.BEFORE_CURSOR, current_line_only = true }
            end,
          },
          ["FF"] = {
            function()
              hop.hint_char1 { direction = require("hop.hint").HintDirection.BEFORE_CURSOR, current_line_only = false }
            end,
          },
          ["t"] = {
            function()
              hop.hint_char1 {
                direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                current_line_only = true,
                hint_offset = -1,
              }
            end,
          },
          ["tt"] = {
            function()
              hop.hint_char1 {
                direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                current_line_only = false,
                hint_offset = -1,
              }
            end,
          },
          ["T"] = {
            function()
              hop.hint_char1 {
                direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                current_line_only = true,
                hint_offset = 1,
              }
            end,
          },
          ["TT"] = {
            function()
              hop.hint_char1 {
                direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                current_line_only = false,
                hint_offset = 1,
              }
            end,
          },
        },
        n = {
          ["s"] = { ":HopChar2<cr>" },
          ["ss"] = { ":HopChar1<cr>" },
          ["sw"] = { ":HopPattern<cr>" },
          ["S"] = { ":HopWord<cr>" },
          ["SS"] = { ":HopLine<cr>" },
        },
      }
    end,
  })
end

return M
