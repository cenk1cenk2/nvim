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
    keymaps = function()
      local common = {
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
      }

      return {
        n = vim.tbl_extend("force", {
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
        }, common),
        v = common,
      }
    end,
  })
end

return M
