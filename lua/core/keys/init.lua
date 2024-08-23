local M = {}

local log = require("core.log")

-- Load the default keymappings
function M.load_defaults()
  nvim.keys = require("core.keys.default")

  return nvim.keys
end

function M.setup()
  log:debug("Initializing keybindings.")

  vim.g.mapleader = nvim.leader
  vim.g.maplocalleader = nvim.localleader

  require("setup").load_keymaps(nvim.keys)
end

return M
