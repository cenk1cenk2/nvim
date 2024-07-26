local M = {}

local Log = require("lvim.core.log")

-- Load the default keymappings
function M.load_defaults()
  lvim.keys = require("keys.default")

  return lvim.keys
end

function M.setup()
  vim.g.mapleader = (lvim.leader == "space" and " ") or lvim.leader
  Log:debug("Initialized keybindings.")
  M.load(lvim.keys)
end

return M
