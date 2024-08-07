local M = {}

local Log = require("lvim.core.log")

-- Load the default keymappings
function M.load_defaults()
  lvim.keys = require("keys.default")

  return lvim.keys
end

function M.setup()
  Log:debug("Initializing keybindings.")

  vim.g.mapleader = lvim.leader
  vim.g.maplocalleader = lvim.localleader

  require("utils.setup").load_mappings(lvim.keys)
end

return M
