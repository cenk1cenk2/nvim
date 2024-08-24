-- https://github.com/OXY2DEV/helpview.nvim
local M = {}

M.name = "OXY2DEV/helpview.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "OXY2DEV/helpview.nvim",
        ft = { "help" },
      }
    end,
    hl = function()
      return {
        ["HelpviewHeading1"] = { link = "@markup.heading.1.markdown" },
        ["HelpviewHeading2"] = { link = "@markup.heading.2.markdown" },
        ["HelpviewHeading3"] = { link = "@markup.heading.3.markdown" },
        ["HelpviewHeading4"] = { link = "@markup.heading.4.markdown" },
        ["yyaatt"] = { link = "@markup.heading.4.markdown" },
      }
    end,
  })
end

return M
