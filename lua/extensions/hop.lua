-- https://github.com/phaazon/hop.nvim
local M = {}

local extension_name = "hop"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    plugin = function()
      return {
        "phaazon/hop.nvim",
        cmd = {
          "HopChar2",
          "HopChar1",
          "HopPattern",
          "HopWord",
          "HopLine",
        },
      }
    end,
    setup = {},
    on_setup = function(config)
      require("hop").setup(config.setup)
    end,
    on_done = function()
      vim.cmd("highlight HopUnmatched guifg=none guibg=none guisp=none ctermfg=none")
    end,
    keymaps = function()
      return {
        a = {
          ["f"] = {
            function()
              require("hop").hint_char1({ direction = require("hop.hint").HintDirection.AFTER_CURSOR, current_line_only = true })
            end,
          },
          ["ff"] = {
            function()
              require("hop").hint_char1({ direction = require("hop.hint").HintDirection.AFTER_CURSOR, current_line_only = false })
            end,
          },
          ["F"] = {
            function()
              require("hop").hint_char1({ direction = require("hop.hint").HintDirection.BEFORE_CURSOR, current_line_only = true })
            end,
          },
          ["FF"] = {
            function()
              require("hop").hint_char1({ direction = require("hop.hint").HintDirection.BEFORE_CURSOR, current_line_only = false })
            end,
          },
          ["t"] = {
            function()
              require("hop").hint_char1({
                direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                current_line_only = true,
                hint_offset = -1,
              })
            end,
          },
          ["tt"] = {
            function()
              require("hop").hint_char1({
                direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                current_line_only = false,
                hint_offset = -1,
              })
            end,
          },
          ["T"] = {
            function()
              require("hop").hint_char1({
                direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                current_line_only = true,
                hint_offset = 1,
              })
            end,
          },
          ["TT"] = {
            function()
              require("hop").hint_char1({
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
