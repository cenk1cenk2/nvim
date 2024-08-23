local M = {}

local log = require("core.log")

function M.setup()
  log:debug("Initializing keybindings.")

  vim.g.mapleader = nvim.leader
  vim.g.maplocalleader = nvim.localleader

  require("setup").load_keymaps(require("core.keys.default"))
end

return M
