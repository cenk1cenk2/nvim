-- https://github.com/drybalka/tree-climber.nvim
local M = {}

local extension_name = "tree_climber_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "drybalka/tree-climber.nvim",
      }
    end,
    keymaps = {
      {
        { "n", "v" },

        ["H"] = {
          function()
            require("tree-climber").goto_parent()
          end,
        },
        ["L"] = {
          function()
            require("tree-climber").goto_child()
          end,
        },
        ["LL"] = {
          function()
            require("tree-climber").goto_next()
          end,
        },
        ["HH"] = {
          function()
            require("tree-climber").goto_prev()
          end,
        },
      },

      {
        { "n" },

        ["HHH"] = {
          function()
            require("tree-climber").swap_prev()
          end,
        },
        ["LLL"] = {
          function()
            require("tree-climber").swap_next()
          end,
        },
      },
    },
  })
end

return M
