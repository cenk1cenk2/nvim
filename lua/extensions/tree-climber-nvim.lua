local M = {}

local extension_name = "tree_climber_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = false,
    on_config_done = nil,
    keymaps = {},
  }
end

function M.setup()
  require("lvim.keymappings").load(lvim.extensions[extension_name].keymaps)
  local extension = require "tree-climber"

  local keyopts = { noremap = true, silent = true }

  vim.keymap.set({ "n", "v", "o" }, "H", extension.goto_parent)
  vim.keymap.set({ "n", "v", "o" }, "L", extension.goto_child, keyopts)
  vim.keymap.set({ "n", "v", "o" }, "LL", extension.goto_next, keyopts)
  vim.keymap.set({ "n", "v", "o" }, "HH", extension.goto_prev, keyopts)
  vim.keymap.set("n", "LLL", extension.swap_prev, keyopts)
  vim.keymap.set("n", "HHH", extension.swap_next, keyopts)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
