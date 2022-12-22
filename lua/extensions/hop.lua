-- https://github.com/phaazon/hop.nvim
local M = {}

local extension_name = "hop"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "phaazon/hop.nvim",
        event = "BufReadPost",
        keys = { "f", "ff", "F", "FF", "t", "tt", "T", "TT", "s", "ss", "sw", "S", "SS" },
      }
    end,
    to_inject = function()
      return {
        hop = require("hop"),
      }
    end,
    setup = {},
    on_setup = function(config)
      require("hop").setup(config.setup)
    end,
    on_done = function()
      vim.api.nvim_command("highlight HopUnmatched guifg=none guibg=none guisp=none ctermfg=none")
    end,
    keymaps = function(config)
      local hop = config.inject.hop

      return {
        a = {
          ["f"] = {
            function()
              hop.hint_char1({ direction = require("hop.hint").HintDirection.AFTER_CURSOR, current_line_only = true })
            end,
          },
          ["ff"] = {
            function()
              hop.hint_char1({ direction = require("hop.hint").HintDirection.AFTER_CURSOR, current_line_only = false })
            end,
          },
          ["F"] = {
            function()
              hop.hint_char1({ direction = require("hop.hint").HintDirection.BEFORE_CURSOR, current_line_only = true })
            end,
          },
          ["FF"] = {
            function()
              hop.hint_char1({ direction = require("hop.hint").HintDirection.BEFORE_CURSOR, current_line_only = false })
            end,
          },
          ["t"] = {
            function()
              hop.hint_char1({
                direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                current_line_only = true,
                hint_offset = -1,
              })
            end,
          },
          ["tt"] = {
            function()
              hop.hint_char1({
                direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                current_line_only = false,
                hint_offset = -1,
              })
            end,
          },
          ["T"] = {
            function()
              hop.hint_char1({
                direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                current_line_only = true,
                hint_offset = 1,
              })
            end,
          },
          ["TT"] = {
            function()
              hop.hint_char1({
                direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                current_line_only = false,
                hint_offset = 1,
              })
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
