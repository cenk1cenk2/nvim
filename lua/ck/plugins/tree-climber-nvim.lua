-- https://github.com/drybalka/tree-climber.nvim
local M = {}

M.name = "drybalka/tree-climber.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "drybalka/tree-climber.nvim",
      }
    end,
    keymaps = function()
      return {
        {
          "<BS>",
          function()
            require("tree-climber").goto_parent()
          end,
          desc = "treesitter goto parent node",
        },
        {
          "<CR>",
          function()
            require("tree-climber").goto_child()
          end,
          desc = "treesitter goto child node",
        },
        {
          "H",
          function()
            require("tree-climber").goto_prev()
          end,
          desc = "treesitter goto previous sibling",
        },
        {
          "HH",
          function()
            require("tree-climber").swap_prev()
          end,
          desc = "treesitter swap with previous sibling",
        },
        {
          "L",
          function()
            require("tree-climber").goto_next()
          end,
          desc = "treesitter goto next sibling",
        },
        {
          "LL",
          function()
            require("tree-climber").swap_prev()
          end,
          desc = "treesitter swap with next sibling",
        },
      }
    end,
  })
end

return M
