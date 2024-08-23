local M = {}

local log = require("lvim.log")

-- Load the default keymappings
function M.load_defaults()
  lvim.keys = require("keys.default")

  return lvim.keys
end

function M.setup()
  log:debug("Initializing keybindings.")

  vim.g.mapleader = lvim.leader
  vim.g.maplocalleader = lvim.localleader

  require("utils.setup").load_keymaps(lvim.keys)
end

return M
