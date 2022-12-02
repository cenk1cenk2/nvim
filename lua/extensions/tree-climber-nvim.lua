-- https://github.com/drybalka/tree-climber.nvim
local M = {}

local extension_name = "tree_climber_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "drybalka/tree-climber.nvim",
        config = function()
          require("utils.setup").packer_config "tree_climber_nvim"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        tree_climber = require "tree-climber",
      }
    end,
    keymaps = function(config)
      local tree_climber = config.inject.tree_climber
      local common = {
        ["H"] = { tree_climber.goto_parent },
        ["L"] = { tree_climber.goto_child },
        ["LL"] = { tree_climber.goto_next },
        ["HH"] = { tree_climber.goto_prev },
      }

      return {
        n = vim.tbl_extend("force", {
          ["HHH"] = { tree_climber.swap_prev },
          ["LLL"] = { tree_climber.swap_next },
        }, common),
        v = common,
      }
    end,
  })
end

return M
