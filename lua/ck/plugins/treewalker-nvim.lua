-- https://github.com/aaronik/treewalker.nvim
local M = {}

M.name = "aaronik/treewalker.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "aaronik/treewalker.nvim",
        opts = {
          highlight = true,
          highlight_duration = 250,
        },
      }
    end,
    configure = function()
      return {
        highlight = true,
        highlight_duration = 250,
      }
    end,
    on_setup = function(c)
      require("treewalker").setup(c)
    end,
    keymaps = function()
      ---@type KeymapMappings
      return {
        {
          "<BS>",
          function()
            require("treewalker.movement").move_out()
          end,
          desc = "treesitter goto parent node",
          mode = { "n", "v" },
        },
        {
          "<CR>",
          function()
            require("treewalker.movement").move_in()
          end,
          desc = "treesitter goto child node",
          mode = { "n", "v" },
        },
        {
          "H",
          function()
            require("treewalker.movement").move_up()
          end,
          desc = "treesitter goto previous sibling",
          mode = { "n", "v" },
        },
        {
          "L",
          function()
            require("treewalker.movement").move_down()
          end,
          desc = "treesitter goto next sibling",
          mode = { "n", "v" },
        },
        {
          "HH",
          function()
            require("treewalker").swap_up()
          end,
          desc = "treesitter swap with previous sibling",
          mode = "n",
        },
        {
          "LL",
          function()
            require("treewalker").swap_down()
          end,
          desc = "treesitter swap with next sibling",
          mode = "n",
        },
      }
    end,
  })
end

return M
