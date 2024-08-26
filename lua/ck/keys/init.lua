local M = {}

local log = require("ck.log")

function M.setup()
  log:debug("Initializing keybindings.")

  vim.g.mapleader = nvim.leader
  vim.g.maplocalleader = nvim.localleader

  require("ck.keys.default").load()
end

return M
